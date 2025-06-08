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
  int _currentStreak = 0;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  MoodProvider() {
    _loadMoodsFromFirestore();
  }

  MoodEntry? get todayMood => _todayMood;
  List<MoodEntry> get moodHistory => _moodHistory;
  bool get isLoading => _isLoading;
  int get currentStreak => _currentStreak;

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

      // Update streak in Firestore
      int newStreak = getMoodStreak();
      await _firestore.collection('users').doc(user.uid).update({
        'mood_streak': newStreak,
        'last_mood_date': today.toIso8601String(),
      });
      _currentStreak = newStreak;

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
      // Load mood history
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .orderBy('timestamp', descending: true)
          .get();
      _moodHistory = snapshot.docs
          .map((doc) => MoodEntry.fromJson(doc.data(), doc.id))
          .toList();

      // Load streak from user document
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      _currentStreak = userDoc.data()?['mood_streak'] ?? 0;

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

      notifyListeners();
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
    List<MoodEntry> weekMoods = [];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final entry = _moodHistory.firstWhere(
        (e) =>
            e.timestamp.year == day.year &&
            e.timestamp.month == day.month &&
            e.timestamp.day == day.day,
        orElse: () => MoodEntry(
          id: 'placeholder',
          emoji: moodEmojis['Neutral']!,
          mood: 'Neutral',
          timestamp: day,
        ),
      );
      weekMoods.add(entry);
    }
    return weekMoods;
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
      return 0;
    }

    // Sort history by date in descending order
    List<MoodEntry> sortedHistory = List.from(_moodHistory);
    sortedHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Get today's date at midnight for comparison
    DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Get the latest entry's date at midnight
    DateTime latestEntryDate = DateTime(
      sortedHistory.first.timestamp.year,
      sortedHistory.first.timestamp.month,
      sortedHistory.first.timestamp.day,
    );

    // If the latest entry is not today or yesterday, streak is broken
    if (latestEntryDate.isBefore(today.subtract(Duration(days: 1)))) {
      return 0;
    }

    int streak = 1; // Start with 1 for the latest entry
    DateTime currentDate = latestEntryDate;

    // Check previous entries for consecutive days
    for (int i = 1; i < sortedHistory.length; i++) {
      DateTime entryDate = DateTime(
        sortedHistory[i].timestamp.year,
        sortedHistory[i].timestamp.month,
        sortedHistory[i].timestamp.day,
      );

      // If this entry is from the previous day, increment streak
      if (entryDate.isAtSameMomentAs(currentDate.subtract(Duration(days: 1)))) {
        streak++;
        currentDate = entryDate;
      } else if (entryDate.isBefore(currentDate.subtract(Duration(days: 1)))) {
        // If there's a gap, break the streak
        break;
      }
      // If entry is from the same day, continue checking
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

  // Sentiment analysis methods
  Map<String, dynamic> analyzeSentimentTrends() {
    if (_moodHistory.isEmpty) {
      return {
        'overall_sentiment': 'neutral',
        'trend': 'stable',
        'insights': [],
        'weekly_average': 0.0,
      };
    }

    // Get entries from the last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    final recentEntries = _moodHistory
        .where((entry) => entry.timestamp.isAfter(weekAgo))
        .toList();

    // Calculate sentiment scores
    List<double> sentimentScores = recentEntries.map((entry) {
      return _getMoodScore(entry.mood);
    }).toList();

    // Calculate weekly average
    double weeklyAverage = sentimentScores.isEmpty
        ? 0.0
        : sentimentScores.reduce((a, b) => a + b) / sentimentScores.length;

    // Determine overall sentiment
    String overallSentiment = _getSentimentFromScore(weeklyAverage);

    // Determine trend
    String trend = 'stable';
    if (sentimentScores.length >= 2) {
      double firstHalf =
          sentimentScores
              .take(sentimentScores.length ~/ 2)
              .reduce((a, b) => a + b) /
          (sentimentScores.length ~/ 2);
      double secondHalf =
          sentimentScores
              .skip(sentimentScores.length ~/ 2)
              .reduce((a, b) => a + b) /
          (sentimentScores.length - (sentimentScores.length ~/ 2));

      if (secondHalf > firstHalf + 0.5) {
        trend = 'improving';
      } else if (secondHalf < firstHalf - 0.5) {
        trend = 'declining';
      }
    }

    // Generate insights
    List<String> insights = _generateInsights(recentEntries, weeklyAverage);

    return {
      'overall_sentiment': overallSentiment,
      'trend': trend,
      'insights': insights,
      'weekly_average': weeklyAverage,
    };
  }

  double _getMoodScore(String mood) {
    switch (mood.toLowerCase()) {
      case 'very happy':
        return 5.0;
      case 'happy':
        return 4.0;
      case 'neutral':
        return 3.0;
      case 'sad':
        return 2.0;
      case 'angry':
        return 1.0;
      default:
        return 3.0;
    }
  }

  String _getSentimentFromScore(double score) {
    if (score >= 4.5) return 'very positive';
    if (score >= 3.5) return 'positive';
    if (score >= 2.5) return 'neutral';
    if (score >= 1.5) return 'negative';
    return 'very negative';
  }

  List<String> _generateInsights(List<MoodEntry> entries, double averageScore) {
    List<String> insights = [];

    // Analyze mood patterns
    Map<String, int> moodFrequency = {};
    for (var entry in entries) {
      moodFrequency[entry.mood] = (moodFrequency[entry.mood] ?? 0) + 1;
    }

    // Most frequent mood
    String mostFrequentMood = moodFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    insights.add('Most frequent mood: $mostFrequentMood');

    // Trend analysis
    if (entries.length >= 3) {
      double recentAverage =
          entries
              .take(3)
              .map((e) => _getMoodScore(e.mood))
              .reduce((a, b) => a + b) /
          3;

      if (recentAverage > averageScore + 0.5) {
        insights.add('Your mood has been improving recently');
      } else if (recentAverage < averageScore - 0.5) {
        insights.add('Your mood has been declining recently');
      }
    }

    // Trigger analysis
    Map<String, int> triggerFrequency = {};
    for (var entry in entries) {
      if (entry.trigger != null && entry.trigger!.isNotEmpty) {
        triggerFrequency[entry.trigger!] =
            (triggerFrequency[entry.trigger!] ?? 0) + 1;
      }
    }

    if (triggerFrequency.isNotEmpty) {
      String mostFrequentTrigger = triggerFrequency.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      insights.add('Most common trigger: $mostFrequentTrigger');
    }

    return insights;
  }
}
