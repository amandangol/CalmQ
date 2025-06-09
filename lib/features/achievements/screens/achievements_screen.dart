import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements'), centerTitle: true),
      body: Consumer<AchievementProvider>(
        builder: (context, achievementProvider, _) {
          final achievements = achievementProvider.achievements;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return AchievementCard(achievement: achievement);
            },
          );
        },
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({Key? key, required this.achievement})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(achievement.iconPath, width: 48, height: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value:
                  context.read<AchievementProvider>().getActivityCount(
                    achievement.type,
                  ) /
                  achievement.requiredCount,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                achievement.isUnlocked
                    ? Colors.green
                    : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${context.read<AchievementProvider>().getActivityCount(achievement.type)}/${achievement.requiredCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (achievement.isUnlocked && !achievement.isClaimed)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AchievementProvider>().claimAchievement(
                      achievement.id,
                    );
                  },
                  child: const Text('Claim Achievement'),
                ),
              ),
            if (achievement.isClaimed)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Claimed on ${achievement.claimedAt?.toString().split('.')[0] ?? ''}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
