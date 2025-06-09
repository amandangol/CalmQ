import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../web3/providers/web3_provider.dart';

class BreathingProvider extends ChangeNotifier {
  final Web3Provider _web3Provider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isBreathing = false;
  int _selectedDuration = 3; // Default 3 minutes
  String _selectedSoundscape = 'none';
  double _breathProgress = 0.0;
  bool _isInhale = true;
  int _completedCycles = 0;
  int _totalSessions = 0;
  int _totalBreathingTime = 0; // in seconds
  DateTime? _lastSessionDate;
  bool _isInitialized = false;

  bool get isBreathing => _isBreathing;
  int get selectedDuration => _selectedDuration;
  String get selectedSoundscape => _selectedSoundscape;
  double get breathProgress => _breathProgress;
  bool get isInhale => _isInhale;
  int get completedCycles => _completedCycles;
  int get totalSessions => _totalSessions;
  int get totalBreathingTime => _totalBreathingTime;
  DateTime? get lastSessionDate => _lastSessionDate;
  bool get isInitialized => _isInitialized;

  final List<int> availableDurations = [1, 3, 5];
  final List<String> availableSoundscapes = ['none', 'rain', 'ocean', 'forest'];

  BreathingProvider(this._web3Provider) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      await _loadBreathingStats();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing BreathingProvider: $e');
    }
  }

  Future<void> _loadBreathingStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('breathing_stats')
          .doc('stats')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _completedCycles = data['completedCycles'] ?? 0;
        _totalSessions = data['totalSessions'] ?? 0;
        _totalBreathingTime = data['totalBreathingTime'] ?? 0;
        _lastSessionDate = data['lastSessionDate']?.toDate();
      }
    } catch (e) {
      debugPrint('Error loading breathing stats: $e');
    }
  }

  Future<void> _saveBreathingStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('breathing_stats')
          .doc('stats')
          .set({
            'completedCycles': _completedCycles,
            'totalSessions': _totalSessions,
            'totalBreathingTime': _totalBreathingTime,
            'lastSessionDate': _lastSessionDate,
          });
    } catch (e) {
      debugPrint('Error saving breathing stats: $e');
    }
  }

  void startBreathing() {
    if (!_isInitialized) return;
    _isBreathing = true;
    _lastSessionDate = DateTime.now();
    notifyListeners();
  }

  void stopBreathing() {
    if (!_isInitialized) return;
    _isBreathing = false;
    _totalSessions++;
    _totalBreathingTime += _selectedDuration * 60; // Convert minutes to seconds
    _saveBreathingStats();
    notifyListeners();
  }

  void updateBreathProgress(double progress) {
    if (!_isInitialized) return;
    _breathProgress = progress;
    if (progress >= 1.0) {
      _completedCycles++;
      _saveBreathingStats();
    }
    notifyListeners();
  }

  void setDuration(int minutes) {
    if (!_isInitialized) return;
    _selectedDuration = minutes;
    notifyListeners();
  }

  void setSoundscape(String soundscape) {
    if (!_isInitialized) return;
    _selectedSoundscape = soundscape;
    notifyListeners();
  }

  // Reset stats (for testing purposes)
  Future<void> resetStats() async {
    if (!_isInitialized) return;
    _totalSessions = 0;
    _totalBreathingTime = 0;
    _lastSessionDate = null;
    await _saveBreathingStats();
    notifyListeners();
  }
}
