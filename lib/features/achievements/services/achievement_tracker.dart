import 'package:flutter/foundation.dart';
import '../providers/achievement_provider.dart';
import '../../breathing/providers/breathing_provider.dart';

class AchievementTracker {
  final AchievementProvider _achievementProvider;

  AchievementTracker(this._achievementProvider);

  void trackBreathingAchievements(BreathingProvider breathingProvider) {
    debugPrint('AchievementTracker: Tracking breathing achievements...');

    // First Breath Achievement
    if (breathingProvider.completedCycles > 0) {
      _achievementProvider.updateAchievementProgress('first_breathe', 1);
    }

    // Consistent Breather Achievement (5 sessions)
    if (breathingProvider.totalSessions >= 5) {
      _achievementProvider.updateAchievementProgress('breathing_streak_5', 1);
    }

    // Consistent Breather Achievement (25 sessions)
    if (breathingProvider.totalSessions >= 25) {
      _achievementProvider.updateAchievementProgress('breathing_streak_25', 1);
    }

    // Breathing Master Achievement (1 hour total)
    if (breathingProvider.totalBreathingTime >= 3600) {
      _achievementProvider.updateAchievementProgress('breathing_master', 1);
    }

    // Breathing Expert Achievement (5 hours total)
    if (breathingProvider.totalBreathingTime >= 18000) {
      _achievementProvider.updateAchievementProgress('breathing_expert', 1);
    }

    // Daily Streak Achievement
    if (breathingProvider.lastSessionDate != null) {
      final now = DateTime.now();
      final lastSession = breathingProvider.lastSessionDate!;
      if (now.difference(lastSession).inDays == 1) {
        _achievementProvider.updateAchievementProgress('daily_streak', 1);
      }
    }

    // Long Session Achievement (30 minutes)
    if (breathingProvider.selectedDuration >= 1800) {
      _achievementProvider.updateAchievementProgress('long_session', 1);
    }

    // Soundscape Explorer Achievement
    if (breathingProvider.selectedSoundscape != 'none') {
      _achievementProvider.updateAchievementProgress('soundscape_explorer', 1);
    }
  }
}
