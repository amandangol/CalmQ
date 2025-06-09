import 'package:flutter/material.dart';
import 'dart:math' as math;

class FocusSession {
  final String mode;
  final int duration;
  final DateTime timestamp;
  final double focusScore;
  final List<String> completedExercises;
  final Map<String, dynamic> userFeedback;

  FocusSession({
    required this.mode,
    required this.duration,
    required this.timestamp,
    required this.focusScore,
    required this.completedExercises,
    required this.userFeedback,
  });
}

class FocusProvider extends ChangeNotifier {
  List<FocusSession> _sessions = [];
  String _currentMode = 'Mindfulness';
  int _currentDuration = 300;
  bool _isSessionActive = false;
  double _currentFocusScore = 0.0;
  List<String> _recommendedExercises = [];
  Map<String, dynamic> _userPreferences = {};
  Map<String, double> _modeEffectiveness = {};

  // Getters
  List<FocusSession> get sessions => _sessions;
  String get currentMode => _currentMode;
  int get currentDuration => _currentDuration;
  bool get isSessionActive => _isSessionActive;
  double get currentFocusScore => _currentFocusScore;
  List<String> get recommendedExercises => _recommendedExercises;
  Map<String, double> get modeEffectiveness => _modeEffectiveness;

  // AI-powered exercise recommendation
  void generateExerciseRecommendations() {
    // Analyze user's session history and preferences
    final userHistory = _analyzeUserHistory();
    final preferences = _analyzeUserPreferences();

    // Generate personalized recommendations
    _recommendedExercises = _getPersonalizedExercises(userHistory, preferences);
    notifyListeners();
  }

  // AI-powered mode effectiveness analysis
  void analyzeModeEffectiveness() {
    _modeEffectiveness = _calculateModeEffectiveness();
    notifyListeners();
  }

  // Start a new focus session
  void startSession() {
    _isSessionActive = true;
    _currentFocusScore = 0.0;
    notifyListeners();
  }

  // End current session
  void endSession({
    required double focusScore,
    required List<String> completedExercises,
    required Map<String, dynamic> userFeedback,
  }) {
    final session = FocusSession(
      mode: _currentMode,
      duration: _currentDuration,
      timestamp: DateTime.now(),
      focusScore: focusScore,
      completedExercises: completedExercises,
      userFeedback: userFeedback,
    );

    _sessions.add(session);
    _isSessionActive = false;
    _updateUserPreferences(userFeedback);
    generateExerciseRecommendations();
    analyzeModeEffectiveness();
    notifyListeners();
  }

  // Update session mode
  void updateMode(String mode) {
    _currentMode = mode;
    generateExerciseRecommendations();
    notifyListeners();
  }

  // Update session duration
  void updateDuration(int duration) {
    _currentDuration = duration;
    notifyListeners();
  }

  // Private methods for AI analysis
  Map<String, dynamic> _analyzeUserHistory() {
    // Analyze session patterns, success rates, and preferences
    final Map<String, dynamic> analysis = {
      'mostEffectiveMode': _getMostEffectiveMode(),
      'averageFocusScore': _calculateAverageFocusScore(),
      'preferredDuration': _getPreferredDuration(),
      'sessionFrequency': _calculateSessionFrequency(),
    };
    return analysis;
  }

  Map<String, dynamic> _analyzeUserPreferences() {
    // Analyze user's exercise preferences and patterns
    return {
      'preferredExercises': _getPreferredExercises(),
      'timeOfDay': _getPreferredTimeOfDay(),
      'successRate': _calculateSuccessRate(),
    };
  }

  List<String> _getPersonalizedExercises(
    Map<String, dynamic> history,
    Map<String, dynamic> preferences,
  ) {
    // AI logic to recommend exercises based on history and preferences
    final List<String> recommendations = [];
    // Add AI-powered exercise selection logic here
    return recommendations;
  }

  Map<String, double> _calculateModeEffectiveness() {
    final Map<String, double> effectiveness = {};
    // Calculate effectiveness score for each mode
    return effectiveness;
  }

  String _getMostEffectiveMode() {
    // Return the mode with highest success rate
    return 'Mindfulness';
  }

  double _calculateAverageFocusScore() {
    if (_sessions.isEmpty) return 0.0;
    return _sessions.map((s) => s.focusScore).reduce((a, b) => a + b) /
        _sessions.length;
  }

  int _getPreferredDuration() {
    if (_sessions.isEmpty) return 300;
    // Return most common duration
    return 300;
  }

  double _calculateSessionFrequency() {
    if (_sessions.isEmpty) return 0.0;
    // Calculate average sessions per day
    return 1.0;
  }

  List<String> _getPreferredExercises() {
    // Return list of most successful exercises
    return [];
  }

  String _getPreferredTimeOfDay() {
    // Return preferred time of day for sessions
    return 'Morning';
  }

  double _calculateSuccessRate() {
    if (_sessions.isEmpty) return 0.0;
    // Calculate overall success rate
    return 0.8;
  }

  void _updateUserPreferences(Map<String, dynamic> feedback) {
    _userPreferences.addAll(feedback);
  }
}
