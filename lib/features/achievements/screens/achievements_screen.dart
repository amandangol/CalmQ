import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';
import '../../web3/providers/web3_provider.dart';
import '../../../app_theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _isClaiming = false;
  String? _claimingAchievementId;

  @override
  void initState() {
    super.initState();
    // Set up Web3Provider in AchievementProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final web3Provider = context.read<Web3Provider>();
      context.read<AchievementProvider>().setWeb3Provider(web3Provider);
    });
  }

  Future<void> _claimAchievement(String achievementId) async {
    setState(() {
      _isClaiming = true;
      _claimingAchievementId = achievementId;
    });

    try {
      await context.read<AchievementProvider>().claimAchievement(achievementId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Achievement claimed and NFT minted successfully!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim achievement: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClaiming = false;
          _claimingAchievementId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<AchievementProvider>().notifyListeners();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AchievementProvider>().notifyListeners();
        },
        child: Consumer<AchievementProvider>(
          builder: (context, achievementProvider, child) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: achievementProvider.achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievementProvider.achievements[index];
                return _buildAchievementCard(achievement);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isClaiming = _isClaiming && _claimingAchievementId == achievement.id;
    final web3Provider = context.watch<Web3Provider>();
    final isWalletConnected = web3Provider.isConnected;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: achievement.isUnlocked ? AppColors.primary : Colors.grey,
              ),
            ),
            title: Text(
              achievement.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked
                    ? AppColors.textPrimary
                    : Colors.grey,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: achievement.isUnlocked
                        ? AppColors.textSecondary
                        : Colors.grey,
                  ),
                ),
                if (achievement.isUnlocked && !achievement.isClaimed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Connect your wallet to claim this achievement as an NFT',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            trailing: _buildAchievementStatus(
              achievement,
              isClaiming,
              isWalletConnected,
            ),
          ),
          if (achievement.isUnlocked && !achievement.isClaimed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress: ${context.read<AchievementProvider>().getActivityCount(achievement.type)}/${achievement.requiredCount}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value:
                          context.read<AchievementProvider>().getActivityCount(
                            achievement.type,
                          ) /
                          achievement.requiredCount,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementStatus(
    Achievement achievement,
    bool isClaiming,
    bool isWalletConnected,
  ) {
    if (!achievement.isUnlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Locked',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      );
    }

    if (achievement.isClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            const Text(
              'Claimed',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (!isWalletConnected) {
      return TextButton(
        onPressed: () {
          context.read<Web3Provider>().connectWallet();
        },
        child: const Text('Connect Wallet'),
      );
    }

    return ElevatedButton(
      onPressed: isClaiming ? null : () => _claimAchievement(achievement.id),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isClaiming
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Claim NFT'),
    );
  }
}
