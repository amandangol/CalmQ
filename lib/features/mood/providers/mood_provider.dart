import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodEntry {
  final String emoji;
  final String mood;
  final String? trigger;
  final String? note;
  final DateTime timestamp;

  MoodEntry({
    required this.emoji,
    required this.mood,
    this.trigger,
    this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'mood': mood,
    'trigger': trigger,
    'note': note,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    emoji: json['emoji'] ?? '😐',
    mood: json['mood'] ?? 'Neutral',
    trigger: json['trigger'],
    note: json['note'],
    timestamp: DateTime.parse(json['timestamp']),
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
    'Very Sad': '😔',
    'Sad': '😢',
    'Neutral': '😐',
    'Happy': '😊',
    'Very Happy': '😄',
  };

  final Map<String, String> moodImages = {
    'Very Sad': 'angry',
    'Sad': 'sad',
    'Neutral': 'neutral',
    'Happy': 'happy',
    'Very Happy': 'very-happy',
  };

  String getMoodImage(String mood) {
    return moodImages[mood] ?? 'neutral';
  }

  bool hasLoggedMoodToday() {
    if (_todayMood == null) return false;
    final now = DateTime.now();
    return _todayMood!.timestamp.year == now.year &&
        _todayMood!.timestamp.month == now.month &&
        _todayMood!.timestamp.day == now.day;
  }

  Future<void> addMood(String mood, {String? trigger, String? note}) async {
    _isLoading = true;
    notifyListeners();

    final entry = MoodEntry(
      emoji: moodEmojis[mood] ?? '😐',
      mood: mood,
      trigger: trigger,
      note: note,
      timestamp: DateTime.now(),
    );

    _todayMood = entry;
    _moodHistory.add(entry);
    notifyListeners();

    // Save to Firestore
    final user = _auth.currentUser;
    if (user != null) {
      final docId = entry.timestamp.toIso8601String();
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .doc(docId)
          .set(entry.toJson());
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
          .orderBy('timestamp', descending: false)
          .get();
      _moodHistory = snapshot.docs
          .map((doc) => MoodEntry.fromJson(doc.data()))
          .toList();
      if (_moodHistory.isNotEmpty) {
        final today = DateTime.now();
        final todayEntry = _moodHistory.lastWhere(
          (e) =>
              e.timestamp.year == today.year &&
              e.timestamp.month == today.month &&
              e.timestamp.day == today.day,
          orElse: () => _moodHistory.last,
        );
        _todayMood = todayEntry;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  String getMoodSuggestion(String mood) {
    switch (mood) {
      case 'Very Sad':
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
    final Map<String, MoodEntry> dayMap = {};
    for (final entry in _moodHistory.reversed) {
      final key =
          '${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}';
      if (!dayMap.containsKey(key)) {
        dayMap[key] = entry;
      }
    }
    final week = <MoodEntry>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      if (dayMap.containsKey(key)) {
        week.add(dayMap[key]!);
      } else {
        week.add(
          MoodEntry(
            emoji: '😐',
            mood: 'Neutral',
            trigger: null,
            note: null,
            timestamp: DateTime(day.year, day.month, day.day),
          ),
        );
      }
    }
    return week;
  }
}
