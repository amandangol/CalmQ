import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../achievements/services/achievement_tracker.dart';

class BreathingProvider extends ChangeNotifier {
  bool _isBreathing = false;
  int _selectedDuration = 300; // 5 minutes in seconds
  String _selectedSoundscape = 'none';
  double _breathProgress = 0.0;
  bool _isInhale = true;
  int _completedCycles = 0;
  int _totalSessions = 0;
  int _totalBreathingTime = 0; // in seconds
  DateTime? _lastSessionDate;
  bool _isInitialized = false;
  bool _isSessionActive = false;
  int _totalCycles = 0;
  DateTime? _sessionStartTime;
  int _currentCycle = 0;
  AchievementTracker? _achievementTracker;

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
  bool get isSessionActive => _isSessionActive;
  int get totalCycles => _totalCycles;
  int get currentCycle => _currentCycle;

  final List<int> availableDurations = [1, 3, 5];
  final List<String> availableSoundscapes = ['none', 'rain', 'ocean', 'forest'];

  void updateBreathProgress(double progress, BuildContext context) {
    debugPrint(
      'BreathingProvider: updateBreathProgress entered. _isInitialized: $_isInitialized',
    );
    if (!_isInitialized) {
      debugPrint(
        'BreathingProvider: updateBreathProgress returning early because not initialized.',
      );
      return;
    }
    _breathProgress = progress;
    if (progress >= 1.0) {
      _completedCycles++;
      _totalCycles++;
      debugPrint(
        'BreathingProvider: Completed cycle! Total completed cycles: $_completedCycles',
      );

      // Track achievements when a cycle is completed
      _trackAchievements(context);
    }

    notifyListeners();
  }

  void _trackAchievements(BuildContext context) {
    if (_achievementTracker == null) {
      final achievementProvider = Provider.of<AchievementProvider>(
        context,
        listen: false,
      );
      _achievementTracker = AchievementTracker(achievementProvider);
    }

    // Track breathing achievements
    _achievementTracker?.trackBreathingAchievements(this);
  }

  void startSession() {
    if (!_isInitialized) return;
    _isSessionActive = true;
    _sessionStartTime = DateTime.now();
    _totalSessions++;
    notifyListeners();
  }

  void endSession() {
    if (!_isInitialized || !_isSessionActive) return;
    _isSessionActive = false;
    if (_sessionStartTime != null) {
      final sessionDuration = DateTime.now()
          .difference(_sessionStartTime!)
          .inSeconds;
      _totalBreathingTime += sessionDuration;
      _lastSessionDate = DateTime.now();
    }
    notifyListeners();
  }

  void setDuration(int seconds) {
    if (!_isInitialized) return;
    _selectedDuration = seconds;
    notifyListeners();
  }

  void setSoundscape(String soundscape) {
    if (!_isInitialized) return;
    _selectedSoundscape = soundscape;
    notifyListeners();
  }

  void initialize() {
    _isInitialized = true;
    debugPrint('BreathingProvider: Initialized!');
    notifyListeners();
  }
}
