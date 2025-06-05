import 'package:flutter/material.dart';

class BreathingProvider extends ChangeNotifier {
  bool _isBreathing = false;
  int _selectedDuration = 3; // Default 3 minutes
  String _selectedSoundscape = 'none';
  double _breathProgress = 0.0;
  bool _isInhale = true;

  bool get isBreathing => _isBreathing;
  int get selectedDuration => _selectedDuration;
  String get selectedSoundscape => _selectedSoundscape;
  double get breathProgress => _breathProgress;
  bool get isInhale => _isInhale;

  final List<int> availableDurations = [1, 3, 5];
  final List<String> availableSoundscapes = ['none', 'rain', 'ocean', 'forest'];

  void startBreathing() {
    _isBreathing = true;
    _breathProgress = 0.0;
    _isInhale = true;
    notifyListeners();
  }

  void stopBreathing() {
    _isBreathing = false;
    _breathProgress = 0.0;
    notifyListeners();
  }

  void updateBreathProgress(double progress) {
    _breathProgress = progress;
    if (progress >= 1.0) {
      _isInhale = !_isInhale;
      _breathProgress = 0.0;
    }
    notifyListeners();
  }

  void setDuration(int minutes) {
    _selectedDuration = minutes;
    notifyListeners();
  }

  void setSoundscape(String soundscape) {
    _selectedSoundscape = soundscape;
    notifyListeners();
  }
}
