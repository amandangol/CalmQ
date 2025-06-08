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
      (sum, entry) => sum + entry.gratitudeLevel,
    );
    return totalGratitude / _entries.length;
  }

  // Get average stress level
  double getAverageStressLevel() {
    if (_entries.isEmpty) return 0.0;

    final totalStress = _entries.fold(
      0,
      (sum, entry) => sum + entry.stressLevel,
    );
    return totalStress / _entries.length;
  }

  // Get current writing streak
  int getCurrentStreak() {
    if (_entries.isEmpty) return 0;

    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
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
        currentDate = currentDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Get most used tags
  List<String> getMostUsedTags({int limit = 10}) {
    final tagCounts = <String, int>{};

    for (var entry in _entries) {
      for (var tag in entry.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.take(limit).map((e) => e.key).toList();
  }

  // Get mood distribution
  Map<String, int> getMoodDistribution() {
    final moodCounts = <String, int>{};

    for (var entry in _entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return moodCounts;
  }

  // Search entries
  List<JournalEntry> searchEntries(String query) {
    if (query.isEmpty) return _entries;

    final lowercaseQuery = query.toLowerCase();
    return _entries.where((entry) {
      return entry.title.toLowerCase().contains(lowercaseQuery) ||
          entry.content.toLowerCase().contains(lowercaseQuery) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Get entries for today
  List<JournalEntry> getTodayEntries() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(Duration(days: 1));

    return _entries.where((entry) {
      return entry.createdAt.isAfter(todayStart) &&
          entry.createdAt.isBefore(todayEnd);
    }).toList();
  }

  // Check if user has written today
  bool hasWrittenToday() {
    return getTodayEntries().isNotEmpty;
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
