import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderProvider extends ChangeNotifier {
  static const String _journalReminderKey = 'journal_reminder_time';
  static const String _breathingReminderKey = 'breathing_reminder_time';
  static const String _moodReminderKey = 'mood_reminder_time';

  TimeOfDay? _journalReminderTime;
  TimeOfDay? _breathingReminderTime;
  TimeOfDay? _moodReminderTime;
  bool _isLoading = true;

  TimeOfDay? get journalReminderTime => _journalReminderTime;
  TimeOfDay? get breathingReminderTime => _breathingReminderTime;
  TimeOfDay? get moodReminderTime => _moodReminderTime;
  bool get isLoading => _isLoading;

  ReminderProvider() {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();

    _journalReminderTime = _loadTimeFromPrefs(prefs, _journalReminderKey);
    _breathingReminderTime = _loadTimeFromPrefs(prefs, _breathingReminderKey);
    _moodReminderTime = _loadTimeFromPrefs(prefs, _moodReminderKey);

    _isLoading = false;
    notifyListeners();
  }

  TimeOfDay? _loadTimeFromPrefs(SharedPreferences prefs, String key) {
    final timeString = prefs.getString(key);
    if (timeString == null) return null;

    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _saveTimeToPrefs(TimeOfDay? time, String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (time == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, '${time.hour}:${time.minute}');
    }
  }

  Future<void> setJournalReminder(TimeOfDay? time) async {
    _journalReminderTime = time;
    await _saveTimeToPrefs(time, _journalReminderKey);
    notifyListeners();
  }

  Future<void> setBreathingReminder(TimeOfDay? time) async {
    _breathingReminderTime = time;
    await _saveTimeToPrefs(time, _breathingReminderKey);
    notifyListeners();
  }

  Future<void> setMoodReminder(TimeOfDay? time) async {
    _moodReminderTime = time;
    await _saveTimeToPrefs(time, _moodReminderKey);
    notifyListeners();
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
