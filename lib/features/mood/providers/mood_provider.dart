import 'package:flutter/material.dart';

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
}

class MoodProvider extends ChangeNotifier {
  MoodEntry? _todayMood;
  List<MoodEntry> _moodHistory = [];
  bool _isLoading = false;

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

  void addMood(String mood, {String? trigger, String? note}) {
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
}
