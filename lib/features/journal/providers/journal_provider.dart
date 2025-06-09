import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry.dart';

class JournalProvider with ChangeNotifier {
  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<JournalEntry> get entries => _entries.reversed.toList();
  bool get isLoading => _isLoading;

  JournalProvider() {
    _loadEntries();
  }

  // Load entries from Firestore
  Future<void> _loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('journals')
            .orderBy('createdAt', descending: true)
            .get();

        _entries = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return JournalEntry.fromJson(data);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add new entry
  Future<void> addEntry(JournalEntry entry) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docRef = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('journals')
            .add(entry.toJson());

        // Create a new entry with the Firestore document ID
        final newEntry = entry.copyWith(id: docRef.id);
        _entries.add(newEntry);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding journal entry: $e');
      rethrow;
    }
  }

  // Update existing entry
  Future<void> updateEntry(String id, JournalEntry updatedEntry) async {
    try {
      final user = _auth.currentUser;
      if (user != null && id.isNotEmpty) {
        // First update Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('journals')
            .doc(id)
            .update(updatedEntry.toJson());

        // Then update local state
        final index = _entries.indexWhere((entry) => entry.id == id);
        if (index != -1) {
          _entries[index] = updatedEntry.copyWith(
            id: id,
            updatedAt: DateTime.now(),
          );
          // Force a refresh of the entries list
          _entries = List.from(_entries);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating journal entry: $e');
      rethrow;
    }
  }

  // Delete entry
  Future<void> deleteEntry(String id) async {
    try {
      final user = _auth.currentUser;
      if (user != null && id.isNotEmpty) {
        // First delete from Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('journals')
            .doc(id)
            .delete();

        // Then update local state
        _entries.removeWhere((entry) => entry.id == id);
        // Force a refresh of the entries list
        _entries = List.from(_entries);
        notifyListeners();
      } else {
        throw Exception('Invalid document ID or user not authenticated');
      }
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
      rethrow;
    }
  }

  // Get entries by date range
  List<JournalEntry> getEntriesByDateRange(DateTime start, DateTime end) {
    return _entries.where((entry) {
      return entry.createdAt.isAfter(start.subtract(Duration(days: 1))) &&
          entry.createdAt.isBefore(end.add(Duration(days: 1)));
    }).toList();
  }

  // Get entries by mood
  List<JournalEntry> getEntriesByMood(String mood) {
    return _entries.where((entry) => entry.mood == mood).toList();
  }

  // Get entries by tag
  List<JournalEntry> getEntriesByTag(String tag) {
    return _entries.where((entry) => entry.tags.contains(tag)).toList();
  }

  // Get weekly entry count
  int getWeeklyEntryCount() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    return getEntriesByDateRange(weekAgo, now).length;
  }

  // Get monthly entry count
  int getMonthlyEntryCount() {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    return getEntriesByDateRange(monthAgo, now).length;
  }

  // Get average mood score
  double getAverageMoodScore() {
    if (_entries.isEmpty) return 0.0;

    final moodScores = {
      'Terrible': 1,
      'Bad': 2,
      'Okay': 3,
      'Neutral': 4,
      'Good': 5,
      'Great': 6,
      'Amazing': 7,
    };

    final totalScore = _entries.fold(0, (sum, entry) {
      return sum + (moodScores[entry.mood] ?? 4);
    });

    return totalScore / _entries.length;
  }

  // Get average gratitude level
  double getAverageGratitudeLevel() {
    if (_entries.isEmpty) return 0.0;

    final totalGratitude = _entries.fold(
      0,
      (sum, entry) => sum + entry.gratitudeItems.length,
    );
    return totalGratitude / _entries.length;
  }

  // Get writing streak with bonus points
  Map<String, dynamic> getWritingStreak() {
    if (_entries.isEmpty) return {'streak': 0, 'bonus': 0};

    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    int bonus = 0;
    DateTime currentDate = DateTime.now();

    for (var entry in _entries) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      final checkDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      if (entryDate.isAtSameMomentAs(checkDate) ||
          entryDate.isAtSameMomentAs(checkDate.subtract(Duration(days: 1)))) {
        streak++;
        // Add bonus points for consecutive days
        if (streak > 3) bonus += 5;
        if (streak > 7) bonus += 10;
        if (streak > 14) bonus += 20;
        currentDate = currentDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }

    return {'streak': streak, 'bonus': bonus, 'total': streak + bonus};
  }

  // Get emotional insights
  Map<String, dynamic> getEmotionalInsights() {
    if (_entries.isEmpty) {
      return {'mood_trend': [], 'gratitude_trend': [], 'insights': []};
    }

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));
    final recentEntries = getEntriesByDateRange(thirtyDaysAgo, now);

    // Calculate trends
    final moodTrend = <Map<String, dynamic>>[];
    final gratitudeTrend = <Map<String, dynamic>>[];
    final insights = <String>[];

    // Analyze mood patterns
    final moodCounts = <String, int>{};
    for (var entry in recentEntries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    final dominantMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Generate insights
    if (moodCounts['Great'] != null && moodCounts['Great']! > 5) {
      insights.add(
        'You\'ve been feeling great lately! Keep up the positive energy.',
      );
    }

    if (moodCounts['Bad'] != null && moodCounts['Bad']! > 3) {
      insights.add(
        'You\'ve had some challenging days. Remember to practice self-care.',
      );
    }

    // Analyze gratitude patterns
    final totalGratitudeItems = recentEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.gratitudeItems.length,
    );

    if (totalGratitudeItems > 20) {
      insights.add(
        'You\'ve been practicing gratitude regularly. This is great for your well-being!',
      );
    }

    return {
      'mood_trend': moodTrend,
      'gratitude_trend': gratitudeTrend,
      'insights': insights,
    };
  }

  // Get writing prompts based on mood and patterns
  List<String> getWritingPrompts() {
    final insights = getEmotionalInsights();
    final moodTrend = insights['mood_trend'] as List<Map<String, dynamic>>;
    final prompts = <String>[];

    if (moodTrend.isNotEmpty) {
      final recentMood = moodTrend.last['mood'] as String;

      switch (recentMood) {
        case 'Terrible':
        case 'Bad':
          prompts.addAll([
            'What small steps can you take today to improve your mood?',
            'Write about a time when you overcame a difficult situation.',
            'What are three things you\'re grateful for right now?',
          ]);
          break;
        case 'Okay':
        case 'Neutral':
          prompts.addAll([
            'What would make today a great day?',
            'Write about something you\'re looking forward to.',
            'What\'s one thing you\'d like to improve about your day?',
          ]);
          break;
        case 'Good':
        case 'Great':
        case 'Amazing':
          prompts.addAll([
            'What made today special?',
            'How can you maintain this positive energy?',
            'Write about someone who contributed to your good mood.',
          ]);
          break;
      }
    }

    // Add general prompts
    prompts.addAll([
      'What\'s the most important thing you learned today?',
      'Write about a moment that made you smile.',
      'What are your goals for tomorrow?',
    ]);

    return prompts;
  }

  // Get writing achievements
  Map<String, dynamic> getWritingAchievements() {
    final achievements = <String, dynamic>{
      'total_entries': _entries.length,
      'current_streak': getWritingStreak()['streak'],
      'longest_streak': _calculateLongestStreak(),
      'consistency': getWritingConsistency(),
      'mood_insights': getEmotionalInsights()['insights'],
      'prompts': getWritingPrompts(),
    };

    return achievements;
  }

  int _calculateLongestStreak() {
    if (_entries.isEmpty) return 0;

    _entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    int longestStreak = 0;
    int currentStreak = 1;
    DateTime? lastDate;

    for (var entry in _entries) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );

      if (lastDate != null) {
        final difference = entryDate.difference(lastDate).inDays;
        if (difference == 1) {
          currentStreak++;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        } else if (difference > 1) {
          currentStreak = 1;
        }
      }

      lastDate = entryDate;
    }

    return longestStreak;
  }

  // Get writing consistency (percentage of days with entries in last 30 days)
  double getWritingConsistency() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));
    final entriesLast30Days = getEntriesByDateRange(thirtyDaysAgo, now);

    final uniqueDays = <String>{};
    for (var entry in entriesLast30Days) {
      final dayKey =
          '${entry.createdAt.year}-${entry.createdAt.month}-${entry.createdAt.day}';
      uniqueDays.add(dayKey);
    }

    return (uniqueDays.length / 30) * 100;
  }

  void clearData() {
    _entries = [];
    notifyListeners();
  }

  @override
  void dispose() {
    clearData();
    super.dispose();
  }
}
