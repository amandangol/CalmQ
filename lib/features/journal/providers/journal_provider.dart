import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/journal_entry.dart';

class JournalProvider with ChangeNotifier {
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  List<JournalEntry> get entries => _entries.reversed.toList();
  bool get isLoading => _isLoading;

  JournalProvider() {
    _loadEntries();
  }

  // Load entries from local storage
  Future<void> _loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString('journal_entries');

      if (entriesJson != null) {
        final List<dynamic> entriesList = json.decode(entriesJson);
        _entries = entriesList
            .map((entry) => JournalEntry.fromJson(entry))
            .toList();
      }
    } catch (e) {
      print('Error loading journal entries: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save entries to local storage
  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String entriesJson = json.encode(
        _entries.map((entry) => entry.toJson()).toList(),
      );
      await prefs.setString('journal_entries', entriesJson);
    } catch (e) {
      print('Error saving journal entries: $e');
    }
  }

  // Add new entry
  Future<void> addEntry(JournalEntry entry) async {
    _entries.add(entry);
    await _saveEntries();
    notifyListeners();
  }

  // Update existing entry
  Future<void> updateEntry(String id, JournalEntry updatedEntry) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = updatedEntry.copyWith(updatedAt: DateTime.now());
      await _saveEntries();
      notifyListeners();
    }
  }

  // Delete entry
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _saveEntries();
    notifyListeners();
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

  // Export entries as JSON
  String exportEntriesAsJson() {
    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'total_entries': _entries.length,
      'entries': _entries.map((entry) => entry.toJson()).toList(),
    };

    return json.encode(exportData);
  }

  // Import entries from JSON
  Future<bool> importEntriesFromJson(String jsonData) async {
    try {
      final data = json.decode(jsonData);
      final List<dynamic> entriesList = data['entries'];

      final importedEntries = entriesList
          .map((entry) => JournalEntry.fromJson(entry))
          .toList();

      // Add imported entries (avoiding duplicates by ID)
      for (var importedEntry in importedEntries) {
        if (!_entries.any((entry) => entry.id == importedEntry.id)) {
          _entries.add(importedEntry);
        }
      }

      await _saveEntries();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error importing entries: $e');
      return false;
    }
  }

  // Clear all entries (with confirmation)
  Future<void> clearAllEntries() async {
    _entries.clear();
    await _saveEntries();
    notifyListeners();
  }

  // Get mood trend (last 7 days)
  List<Map<String, dynamic>> getMoodTrend() {
    final moodScores = {
      'Terrible': 1,
      'Bad': 2,
      'Okay': 3,
      'Neutral': 4,
      'Good': 5,
      'Great': 6,
      'Amazing': 7,
    };

    final now = DateTime.now();
    final trend = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(Duration(days: 1));

      final dayEntries = _entries.where((entry) {
        return entry.createdAt.isAfter(dateStart) &&
            entry.createdAt.isBefore(dateEnd);
      }).toList();

      double avgMood = 4.0; // Default neutral
      if (dayEntries.isNotEmpty) {
        final totalScore = dayEntries.fold(0, (sum, entry) {
          return sum + (moodScores[entry.mood] ?? 4);
        });
        avgMood = totalScore / dayEntries.length;
      }

      trend.add({
        'date': dateStart,
        'mood_score': avgMood,
        'entry_count': dayEntries.length,
      });
    }

    return trend;
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
