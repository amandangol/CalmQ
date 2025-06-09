import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/water_intake.dart';

class WaterTrackerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _waterIntakes = [];
  int _dailyGoal = 2000; // ml
  bool _remindersEnabled = false;
  List<String> _reminderTimes = [];

  // Getters
  List<Map<String, dynamic>> get waterIntakes => _waterIntakes;
  int get dailyGoal => _dailyGoal;
  bool get remindersEnabled => _remindersEnabled;
  List<String> get reminderTimes => _reminderTimes;

  // Initialize data
  Future<void> initialize() async {
    await _loadPreferences();
    await _loadWaterIntakes();
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyGoal = prefs.getInt('daily_goal') ?? 2000;
    _remindersEnabled = prefs.getBool('reminders_enabled') ?? false;
    _reminderTimes = List<String>.from(
      jsonDecode(prefs.getString('reminder_times') ?? '[]'),
    );
    notifyListeners();
  }

  // Save preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal', _dailyGoal);
    await prefs.setBool('reminders_enabled', _remindersEnabled);
    await prefs.setString('reminder_times', jsonEncode(_reminderTimes));
  }

  // Load water intakes from Firebase
  Future<void> _loadWaterIntakes() async {
    if (_auth.currentUser == null) return;

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('water_intakes')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .orderBy('timestamp', descending: true)
          .get();

      _waterIntakes = snapshot.docs.map((doc) => doc.data()).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading water intakes: $e');
    }
  }

  // Add water intake
  Future<void> addWaterIntake(int amount) async {
    if (_auth.currentUser == null) return;

    try {
      final intake = {
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add to Firebase
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('water_intakes')
          .add(intake);

      // Update local state
      _waterIntakes.insert(0, {...intake, 'timestamp': DateTime.now()});

      notifyListeners();
    } catch (e) {
      print('Error adding water intake: $e');
      rethrow;
    }
  }

  // Remove water intake
  Future<void> removeWaterIntake(String id) async {
    if (_auth.currentUser == null) return;

    try {
      // Remove from Firebase
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('water_intakes')
          .doc(id)
          .delete();

      // Update local state
      _waterIntakes.removeWhere((intake) => intake['id'] == id);

      notifyListeners();
    } catch (e) {
      print('Error removing water intake: $e');
      rethrow;
    }
  }

  // Update daily goal
  Future<void> updateDailyGoal(int goal) async {
    _dailyGoal = goal;
    await _savePreferences();
    notifyListeners();
  }

  // Toggle reminders
  Future<void> toggleReminders(bool enabled) async {
    _remindersEnabled = enabled;
    await _savePreferences();
    notifyListeners();
  }

  // Add reminder time
  Future<void> addReminderTime(String time) async {
    _reminderTimes.add(time);
    _reminderTimes.sort();
    await _savePreferences();
    notifyListeners();
  }

  // Remove reminder time
  Future<void> removeReminderTime(String time) async {
    _reminderTimes.remove(time);
    await _savePreferences();
    notifyListeners();
  }

  // Get today's total water intake
  int getTodayTotal() {
    final today = DateTime.now();
    return _waterIntakes
        .where((intake) {
          final timestamp = intake['timestamp'] as DateTime;
          return timestamp.year == today.year &&
              timestamp.month == today.month &&
              timestamp.day == today.day;
        })
        .fold(0, (sum, intake) => sum + (intake['amount'] as int));
  }
}
