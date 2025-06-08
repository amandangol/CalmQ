import 'package:auralynn/features/achievements/models/achievement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app_theme.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../web3/providers/web3_provider.dart';
import '../providers/achievements_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementsProvider>().loadAchievements();
      context.read<Web3Provider>().initialize(context);
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Achievements',
        leadingIcon: Icons.workspace_premium_rounded,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Consumer<AchievementsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return _buildLoadingState();
                }

                final achievements = provider.allAchievements;
                if (achievements.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadAchievements(),
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildStatsRow(context),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Achievements',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showAllAchievements(context),
                                icon: const Icon(Icons.grid_view_rounded),
                                label: const Text('View All'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildAchievementsList(
                          achievements.take(3).toList(),
                          provider,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<AchievementsProvider>(
      builder: (context, provider, _) {
        final achievements = provider.allAchievements;
        final earnedCount = achievements.where((a) => a.isEarned).length;
        final totalCount = achievements.length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Earned',
                  '$earnedCount',
                  Icons.workspace_premium_rounded,
                  AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.primary.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total',
                  '$totalCount',
                  Icons.emoji_events_rounded,
                  AppColors.secondary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.primary.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  'Progress',
                  totalCount > 0
                      ? '${((earnedCount / totalCount) * 100).round()}%'
                      : '0%',
                  Icons.trending_up_rounded,
                  Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading achievements...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(
    List<Achievement> achievements,
    AchievementsProvider provider,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: _AchievementCard(
            achievement: achievements[index],
            web3Provider: context.watch<Web3Provider>(),
            index: index,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Achievements Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.watch<Web3Provider>().isConnected
                  ? 'Complete wellness activities to earn your first NFT achievement and start building your collection!'
                  : 'Connect your wallet to start earning NFT achievements and wellness tokens.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (!context.watch<Web3Provider>().isConnected)
              ElevatedButton.icon(
                onPressed: () => context.read<Web3Provider>().connectWallet(),
                icon: const Icon(Icons.account_balance_wallet_rounded),
                label: const Text('Connect Wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAllAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllAchievementsScreen()),
    );
  }
}

class AllAchievementsScreen extends StatelessWidget {
  const AllAchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Achievements'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AchievementsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final achievements = provider.allAchievements;
          if (achievements.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAchievements(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return _AchievementCard(
                  achievement: achievements[index],
                  web3Provider: context.watch<Web3Provider>(),
                  index: index,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 64,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Achievements Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete activities to earn achievements',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatefulWidget {
  final Achievement achievement;
  final Web3Provider web3Provider;
  final int index;

  const _AchievementCard({
    required this.achievement,
    required this.web3Provider,
    required this.index,
  });

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEarned = widget.achievement.isEarned;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => _showAchievementDetails(context),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isEarned
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isEarned ? 20 : 10,
                offset: const Offset(0, 8),
              ),
            ],
            border: isEarned
                ? Border.all(color: AppColors.primary.withOpacity(0.3))
                : null,
          ),
          child: Column(
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isEarned
                      ? LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.1),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.withOpacity(0.05),
                            Colors.grey.withOpacity(0.02),
                          ],
                        ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    // Achievement icon/image
                    Hero(
                      tag: 'achievement_${widget.achievement.title}',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isEarned
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                )
                              : LinearGradient(
                                  colors: [Colors.grey, Colors.grey.shade300],
                                ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isEarned
                                  ? AppColors.primary.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: widget.achievement.imageUrl != null
                            ? ClipOval(
                                child: Image.asset(
                                  widget.achievement.imageUrl!,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.workspace_premium_rounded,
                                      size: 32,
                                      color: isEarned
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.workspace_premium_rounded,
                                size: 32,
                                color: isEarned
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Achievement info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.achievement.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isEarned
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.achievement.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    if (isEarned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'NFT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Locked',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Progress section
              if (widget.achievement.progress != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.achievement.progress!.current}/${widget.achievement.progress!.total}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor:
                                widget.achievement.progress!.current /
                                widget.achievement.progress!.total,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((widget.achievement.progress!.current / widget.achievement.progress!.total) * 100).round()}% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AchievementDetailsSheet(
        achievement: widget.achievement,
        web3Provider: widget.web3Provider,
      ),
    );
  }
}

class _AchievementDetailsSheet extends StatelessWidget {
  final Achievement achievement;
  final Web3Provider web3Provider;

  const _AchievementDetailsSheet({
    required this.achievement,
    required this.web3Provider,
  });

  @override
  Widget build(BuildContext context) {
    final isEarned = achievement.isEarned;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Achievement header
                  Center(
                    child: Column(
                      children: [
                        Hero(
                          tag: 'achievement_${achievement.title}',
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: isEarned
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.secondary,
                                      ],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey,
                                        Colors.grey.shade300,
                                      ],
                                    ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isEarned
                                      ? AppColors.primary.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: achievement.imageUrl != null
                                ? ClipOval(
                                    child: Image.asset(
                                      achievement.imageUrl!,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.workspace_premium_rounded,
                                              size: 64,
                                              color: isEarned
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                            );
                                          },
                                    ),
                                  )
                                : Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 64,
                                    color: isEarned
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isEarned
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isEarned
                                  ? AppColors.primary.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isEarned
                                    ? Icons.workspace_premium_rounded
                                    : Icons.lock_rounded,
                                size: 16,
                                color: isEarned
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isEarned ? 'NFT Earned' : 'Locked',
                                style: TextStyle(
                                  color: isEarned
                                      ? AppColors.primary
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  // Progress section
                  if (achievement.progress != null) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${achievement.progress!.current}/${achievement.progress!.total}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Stack(
                            children: [
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor:
                                    achievement.progress!.current /
                                    achievement.progress!.total,
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${((achievement.progress!.current / achievement.progress!.total) * 100).round()}% Complete',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Blockchain info for earned achievements
                  if (isEarned && web3Provider.isConnected) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Blockchain Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'NFT minted on Sepolia Testnet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Stored in your connected wallet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
