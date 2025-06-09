import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/water_intake.dart';

class WaterTrackerProvider with ChangeNotifier {
  List<WaterIntake> _intakes = [];
  double _dailyGoal = 2000.0; // Default goal: 2000ml
  bool _remindersEnabled = false;
  List<TimeOfDay> _reminderTimes = [];

  // Getters
  List<WaterIntake> get intakes => _intakes;
  double get dailyGoal => _dailyGoal;
  bool get remindersEnabled => _remindersEnabled;
  List<TimeOfDay> get reminderTimes => _reminderTimes;

  double get todayIntake {
    final now = DateTime.now();
    return _intakes
        .where(
          (intake) =>
              intake.timestamp.year == now.year &&
              intake.timestamp.month == now.month &&
              intake.timestamp.day == now.day,
        )
        .fold(0.0, (sum, intake) => sum + intake.amount);
  }

  double get progressPercentage => (todayIntake / _dailyGoal).clamp(0.0, 1.0);

  WaterTrackerProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load intakes
    final intakesJson = prefs.getString('water_intakes');
    if (intakesJson != null) {
      final List<dynamic> decoded = json.decode(intakesJson);
      _intakes = decoded.map((item) => WaterIntake.fromJson(item)).toList();
    }

    // Load daily goal
    _dailyGoal = prefs.getDouble('water_daily_goal') ?? 2000.0;

    // Load reminder settings
    _remindersEnabled = prefs.getBool('water_reminders_enabled') ?? false;

    // Load reminder times
    final reminderTimesJson = prefs.getString('water_reminder_times');
    if (reminderTimesJson != null) {
      final List<dynamic> decoded = json.decode(reminderTimesJson);
      _reminderTimes = decoded
          .map((item) => TimeOfDay(hour: item['hour'], minute: item['minute']))
          .toList();
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save intakes
    final intakesJson = json.encode(_intakes.map((e) => e.toJson()).toList());
    await prefs.setString('water_intakes', intakesJson);

    // Save daily goal
    await prefs.setDouble('water_daily_goal', _dailyGoal);

    // Save reminder settings
    await prefs.setBool('water_reminders_enabled', _remindersEnabled);

    // Save reminder times
    final reminderTimesJson = json.encode(
      _reminderTimes
          .map((time) => {'hour': time.hour, 'minute': time.minute})
          .toList(),
    );
    await prefs.setString('water_reminder_times', reminderTimesJson);
  }

  void addIntake(double amount, {String? note}) {
    _intakes.add(
      WaterIntake(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        timestamp: DateTime.now(),
        note: note,
      ),
    );
    _saveData();
    notifyListeners();
  }

  void removeIntake(String id) {
    _intakes.removeWhere((intake) => intake.id == id);
    _saveData();
    notifyListeners();
  }

  void updateDailyGoal(double goal) {
    _dailyGoal = goal;
    _saveData();
    notifyListeners();
  }

  void toggleReminders(bool enabled) {
    _remindersEnabled = enabled;
    _saveData();
    notifyListeners();
  }

  void addReminderTime(TimeOfDay time) {
    if (!_reminderTimes.contains(time)) {
      _reminderTimes.add(time);
      _reminderTimes.sort((a, b) {
        final aMinutes = a.hour * 60 + a.minute;
        final bMinutes = b.hour * 60 + b.minute;
        return aMinutes.compareTo(bMinutes);
      });
      _saveData();
      notifyListeners();
    }
  }

  void removeReminderTime(TimeOfDay time) {
    _reminderTimes.remove(time);
    _saveData();
    notifyListeners();
  }

  void updateReminderTimes(List<TimeOfDay> times) {
    _reminderTimes = times;
    _saveData();
    notifyListeners();
  }
}
