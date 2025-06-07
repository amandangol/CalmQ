import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MoodEntry {
  final String emoji;
  final String mood;
  final String? trigger;
  final String? note;
  final DateTime timestamp;
  final String id;

  MoodEntry({
    required this.emoji,
    required this.mood,
    this.trigger,
    this.note,
    required this.timestamp,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'mood': mood,
    'trigger': trigger,
    'note': note,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json, String id) => MoodEntry(
    emoji: json['emoji'] ?? '😐',
    mood: json['mood'] ?? 'Neutral',
    trigger: json['trigger'],
    note: json['note'],
    timestamp: DateTime.parse(json['timestamp']),
    id: id,
  );
}

class MoodProvider extends ChangeNotifier {
  MoodEntry? _todayMood;
  List<MoodEntry> _moodHistory = [];
  bool _isLoading = false;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  MoodProvider() {
    _loadMoodsFromFirestore();
  }

  MoodEntry? get todayMood => _todayMood;
  List<MoodEntry> get moodHistory => _moodHistory;
  bool get isLoading => _isLoading;

  final Map<String, String> moodEmojis = {
    'Angry': '😠',
    'Sad': '😢',
    'Neutral': '😐',
    'Happy': '😊',
    'Very Happy': '😄',
  };

  final Map<String, String> moodImages = {
    'Angry': 'angry',
    'Sad': 'sad',
    'Neutral': 'neutral',
    'Happy': 'happy',
    'Very Happy': 'very-happy',
  };

  String getMoodImage(String mood) {
    return moodImages[mood] ?? 'neutral';
  }

  String getMoodEmoji(String mood) {
    return moodEmojis[mood] ?? '😐';
  }

  bool hasLoggedMoodToday() {
    if (_moodHistory.isEmpty) return false;
    final now = DateTime.now();
    // Find the latest entry for today
    final latestTodayEntry = _moodHistory.firstWhere(
      (e) =>
          e.timestamp.year == now.year &&
          e.timestamp.month == now.month &&
          e.timestamp.day == now.day,
      orElse: () => MoodEntry(
        id: 'placeholder',
        emoji: moodEmojis['Neutral']!,
        mood: 'Neutral',
        timestamp: now,
      ),
    );
    return latestTodayEntry.id != 'placeholder';
  }

  Future<void> addMood(String mood, {String? trigger, String? note}) async {
    _isLoading = true;
    notifyListeners();

    final entry = MoodEntry(
      id: '', // Firestore will generate ID
      emoji: moodEmojis[mood] ?? '😐',
      mood: mood,
      trigger: trigger,
      note: note,
      timestamp: DateTime.now(),
    );

    // Save to Firestore
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .add(entry.toJson());

      // Create a new MoodEntry with the generated ID
      final newEntry = MoodEntry(
        id: docRef.id,
        emoji: entry.emoji,
        mood: entry.mood,
        trigger: entry.trigger,
        note: entry.note,
        timestamp: entry.timestamp,
      );

      // Update local history and todayMood
      _moodHistory.add(newEntry);
      _moodHistory.sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      ); // Sort descending

      final today = DateTime.now();
      if (newEntry.timestamp.year == today.year &&
          newEntry.timestamp.month == today.month &&
          newEntry.timestamp.day == today.day) {
        _todayMood = newEntry;
      } else {
        // If the new entry is not for today, find the latest entry for today
        final todayEntry = _moodHistory.firstWhere(
          (e) =>
              e.timestamp.year == today.year &&
              e.timestamp.month == today.month &&
              e.timestamp.day == today.day,
          orElse: () => MoodEntry(
            id: 'placeholder',
            emoji: moodEmojis['Neutral']!,
            mood: 'Neutral',
            timestamp: today,
          ),
        );
        _todayMood = todayEntry.id == 'placeholder' ? null : todayEntry;
      }

      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadMoodsFromFirestore() async {
    _isLoading = true;
    notifyListeners();
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .orderBy('timestamp', descending: true)
          .get();
      _moodHistory = snapshot.docs
          .map((doc) => MoodEntry.fromJson(doc.data(), doc.id))
          .toList();

      // Set todayMood after loading history
      if (_moodHistory.isNotEmpty) {
        final today = DateTime.now();
        final todayEntry = _moodHistory.firstWhere(
          (e) =>
              e.timestamp.year == today.year &&
              e.timestamp.month == today.month &&
              e.timestamp.day == today.day,
          orElse: () => MoodEntry(
            id: 'placeholder',
            emoji: moodEmojis['Neutral']!,
            mood: 'Neutral',
            timestamp: today,
          ),
        );
        _todayMood = todayEntry.id == 'placeholder' ? null : todayEntry;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  String getMoodSuggestion(String mood) {
    switch (mood) {
      case 'Angry':
        return 'Take deep breaths and try to identify what triggered this emotion.';
      case 'Sad':
        return 'Feeling down? Try a quick breathing exercise to lift your spirits.';
      case 'Neutral':
        return 'Take a moment to reflect on what brings you joy.';
      case 'Happy':
      case 'Very Happy':
        return 'Great mood! Share your positive energy with others.';
      default:
        return 'Take 3 deep breaths before your next task.';
    }
  }

  // Get the latest mood entry for each of the last 7 days (for chart)
  List<MoodEntry> getLatestMoodPerDayForWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(
      Duration(days: now.weekday - 1),
    ); // Assuming Monday is the start of the week

    final Map<String, MoodEntry> dayMap = {};

    // Filter entries for the current week (from startOfWeek to now)
    final weekEntries = _moodHistory
        .where(
          (entry) => entry.timestamp.isAfter(
            startOfWeek.subtract(Duration(days: 1)),
          ), // Include entries from the start of the week
        )
        .toList();

    // Get the latest entry for each day of the week
    for (final entry in weekEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      // Only keep the latest entry for each day
      if (!dayMap.containsKey(dateKey) ||
          entry.timestamp.isAfter(dayMap[dateKey]!.timestamp)) {
        dayMap[dateKey] = entry;
      }
    }

    // Create a list of entries for the last 7 days of the current week
    final List<MoodEntry> week = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(day);
      // Add the mood entry if it exists for the day, otherwise add a placeholder neutral entry
      week.add(
        dayMap[dateKey] ??
            MoodEntry(
              id: 'placeholder',
              emoji: moodEmojis['Neutral']!,
              mood: 'Neutral',
              timestamp: DateTime(
                day.year,
                day.month,
                day.day,
                12,
              ), // Use midday for consistency
            ),
      );
    }

    // Ensure the list has exactly 7 entries for the chart
    return week;
  }

  // Group mood history by date
  Map<String, List<MoodEntry>> getGroupedMoodHistory() {
    final Map<String, List<MoodEntry>> grouped = {};
    final DateFormat formatter = DateFormat(
      'EEEE, MMMM d',
    ); // e.g., Saturday, June 3

    for (final entry in _moodHistory) {
      final dateKey = formatter.format(entry.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(entry);
    }
    return grouped;
  }

  // Calculate the consecutive daily mood logging streak
  int getMoodStreak() {
    if (_moodHistory.isEmpty) {
      return 0; // No streak if no history
    }

    int streak = 0;
    DateTime currentDate = DateTime.now();
    List<MoodEntry> sortedHistory = List.from(
      _moodHistory,
    ); // Create a mutable copy
    sortedHistory.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    ); // Sort descending

    // Remove time component for accurate day comparison
    DateTime latestLogDate = DateTime(
      sortedHistory.first.timestamp.year,
      sortedHistory.first.timestamp.month,
      sortedHistory.first.timestamp.day,
    );

    // Check if the latest log is today or yesterday
    DateTime today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    DateTime yesterday = today.subtract(Duration(days: 1));

    if (latestLogDate.isAtSameMomentAs(today) ||
        latestLogDate.isAtSameMomentAs(yesterday)) {
      // Start counting streak from the latest log if it's today or yesterday
      streak = latestLogDate.isAtSameMomentAs(today)
          ? 1
          : 0; // Start at 1 if today, 0 if yesterday (will be incremented)

      DateTime expectedDate = latestLogDate.isAtSameMomentAs(today)
          ? yesterday
          : today.subtract(Duration(days: 2));

      for (int i = 1; i < sortedHistory.length; i++) {
        DateTime currentLogDate = DateTime(
          sortedHistory[i].timestamp.year,
          sortedHistory[i].timestamp.month,
          sortedHistory[i].timestamp.day,
        );

        if (currentLogDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          expectedDate = expectedDate.subtract(Duration(days: 1));
        } else if (currentLogDate.isBefore(expectedDate)) {
          // Gap in the streak
          break;
        } else if (currentLogDate.isAtSameMomentAs(
          expectedDate.add(Duration(days: 1)),
        )) {
          // Handle multiple logs on the same day - continue checking previous days
        } else {
          // Log is more than one day before expected, streak broken
          break;
        }
      }
    } else {
      // Latest log is older than yesterday, streak is 0
      streak = 0;
    }

    // If the latest log is today and the streak is 0, it should be 1
    if (latestLogDate.isAtSameMomentAs(today) &&
        streak == 0 &&
        sortedHistory.length >= 1) {
      streak = 1;
    }

    return streak;
  }

  Future<void> refreshData() async {
    await _loadMoodsFromFirestore();
  }

  bool hasTodayEntry() {
    return hasLoggedMoodToday();
  }

  Future<void> deleteMoodEntry(String id) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .doc(id)
          .delete();

      _moodHistory.removeWhere((entry) => entry.id == id);
      notifyListeners();
    }
  }

  // Get latest 5 entries
  List<MoodEntry> getLatestEntries({int limit = 5}) {
    return _moodHistory.take(limit).toList();
  }

  // Get all entries for a specific month
  List<MoodEntry> getEntriesForMonth(DateTime month) {
    return _moodHistory
        .where(
          (entry) =>
              entry.timestamp.year == month.year &&
              entry.timestamp.month == month.month,
        )
        .toList();
  }

  // Get entries for a specific date
  List<MoodEntry> getEntriesForDate(DateTime date) {
    return _moodHistory
        .where(
          (entry) =>
              entry.timestamp.year == date.year &&
              entry.timestamp.month == date.month &&
              entry.timestamp.day == date.day,
        )
        .toList();
  }
}
