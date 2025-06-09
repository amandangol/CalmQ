import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementProvider extends ChangeNotifier {
  final List<Achievement> _achievements = [];
  final Map<String, int> _activityCounts = {};

  List<Achievement> get achievements => _achievements;

  AchievementProvider() {
    _initializeAchievements();
  }

  void _initializeAchievements() {
    _achievements.addAll([
      Achievement(
        id: 'breathing_beginner',
        title: 'Breathing Beginner',
        description: 'Complete 5 breathing sessions',
        iconPath: 'assets/icons/breathing.png',
        type: AchievementType.breathing,
        requiredCount: 5,
      ),
      Achievement(
        id: 'mood_tracker',
        title: 'Mood Tracker',
        description: 'Track your mood for 7 days',
        iconPath: 'assets/icons/mood.png',
        type: AchievementType.mood,
        requiredCount: 7,
      ),
      Achievement(
        id: 'journal_master',
        title: 'Journal Master',
        description: 'Write 10 journal entries',
        iconPath: 'assets/icons/journal.png',
        type: AchievementType.journal,
        requiredCount: 10,
      ),
      Achievement(
        id: 'water_champion',
        title: 'Water Champion',
        description: 'Track water intake for 14 days',
        iconPath: 'assets/icons/water.png',
        type: AchievementType.water,
        requiredCount: 14,
      ),
      Achievement(
        id: 'focus_pro',
        title: 'Focus Pro',
        description: 'Complete 20 focus sessions',
        iconPath: 'assets/icons/focus.png',
        type: AchievementType.focus,
        requiredCount: 20,
      ),
    ]);
  }

  void incrementActivityCount(AchievementType type) {
    final typeString = type.toString().split('.').last;
    _activityCounts[typeString] = (_activityCounts[typeString] ?? 0) + 1;
    _checkAchievements();
    notifyListeners();
  }

  void _checkAchievements() {
    for (var i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      final typeString = achievement.type.toString().split('.').last;
      final currentCount = _activityCounts[typeString] ?? 0;

      if (!achievement.isUnlocked &&
          currentCount >= achievement.requiredCount) {
        _achievements[i] = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
    }
  }

  Future<void> claimAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 &&
        _achievements[index].isUnlocked &&
        !_achievements[index].isClaimed) {
      _achievements[index] = _achievements[index].copyWith(
        isClaimed: true,
        claimedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  int getActivityCount(AchievementType type) {
    final typeString = type.toString().split('.').last;
    return _activityCounts[typeString] ?? 0;
  }
}
