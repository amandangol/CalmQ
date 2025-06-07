import 'package:auralynn/features/auth/screens/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../../auth/models/user_profile.dart';
import '../../../app_theme.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../web3/providers/web3_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize the providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().initialize();
      context.read<Web3Provider>().initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Consumer<UserProfileProvider>(
          builder: (context, userProfileProvider, child) {
            final userProfile = userProfileProvider.userProfile;
            if (userProfile == null) return const SizedBox.shrink();

            return CustomAppBar(
              title: 'My Profile',
              leadingIcon: Icons.person_rounded,
              actions: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    onPressed: () =>
                        _navigateToEditProfile(context, userProfile),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Consumer<Web3Provider>(
            builder: (context, web3Provider, child) {
              return FloatingActionButton.extended(
                onPressed: web3Provider.isConnected
                    ? () => web3Provider.disconnectWallet()
                    : () => web3Provider.connectWallet(),
                backgroundColor: web3Provider.isConnected
                    ? AppColors.error
                    : AppColors.secondary,
                icon: Icon(
                  web3Provider.isConnected
                      ? Icons.hourglass_empty
                      : Icons.account_balance_wallet,
                  color: Colors.white,
                ),
                label: Text(
                  web3Provider.isConnected
                      ? 'Disconnect Wallet'
                      : 'Connect Wallet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Consumer<UserProfileProvider>(
            builder: (context, userProfileProvider, child) {
              final userProfile = userProfileProvider.userProfile;
              if (userProfile == null) return const SizedBox.shrink();

              return FloatingActionButton.extended(
                onPressed: () => _navigateToEditProfile(context, userProfile),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, userProfileProvider, child) {
          // Show loading screen if provider is not initialized or loading
          if (!userProfileProvider.isInitialized ||
              userProfileProvider.isLoading) {
            return _buildLoadingScreen();
          }

          final userProfile = userProfileProvider.userProfile;

          // Show no profile screen if user is not authenticated or has no profile
          if (userProfile == null) {
            return _buildNoProfileScreen(context);
          }

          return _buildProfileContent(context, userProfile);
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Loading your profile...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait a moment',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProfileScreen(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to CalmQ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Let\'s create your personalized wellness profile to get started on your journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => UserInfoScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile userProfile) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsSection(userProfile),
                const SizedBox(height: 24),
                _buildSectionTitle('Personal Information'),
                _buildPersonalInfoCard(context, userProfile),
                const SizedBox(height: 24),
                _buildSectionTitle('Wellness Goals'),
                _buildGoalsCard(context, userProfile.goals),
                const SizedBox(height: 24),
                _buildSectionTitle('Areas of Focus'),
                _buildCausesCard(context, userProfile.causes),
                const SizedBox(height: 24),
                _buildSectionTitle('Wellness Assessment'),
                _buildAssessmentCard(context, userProfile),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEditProfile(BuildContext context, UserProfile userProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserInfoScreen()),
    ).then((_) {
      // Refresh the profile data when returning from edit screen
      context.read<UserProfileProvider>().loadUserProfile();
    });
  }

  Widget _buildStatsSection(UserProfile userProfile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.secondary.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Goals',
                userProfile.goals.length.toString(),
                Icons.flag_rounded,
              ),
              _buildStatDivider(),
              _buildStatItem(
                'Focus Areas',
                userProfile.causes.length.toString(),
                Icons.category_rounded,
              ),
              _buildStatDivider(),
              _buildStatItem('Profile', '100%', Icons.person_rounded),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileCompletionIndicator(userProfile),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionIndicator(UserProfile userProfile) {
    final completedFields = [
      userProfile.name.isNotEmpty,
      userProfile.age > 0,
      userProfile.gender != null,
      userProfile.goals.isNotEmpty,
      userProfile.causes.isNotEmpty,
      userProfile.stressFrequency != null,
      userProfile.sleepQuality != null,
      userProfile.happinessLevel != null,
    ].where((field) => field).length;

    final totalFields = 8;
    final completionPercentage = (completedFields / totalFields * 100).round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completion',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$completionPercentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: completedFields / totalFields,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.primary.withOpacity(0.3),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, UserProfile userProfile) {
    final authProvider = context.read<AuthProvider>();
    final web3Provider = context.watch<Web3Provider>();
    final email = authProvider.user?.email ?? '';

    return _buildInfoCard(context, [
      _buildInfoRow(Icons.person_rounded, 'Name', userProfile.name),
      _buildInfoRow(Icons.email_rounded, 'Email', email),
      _buildInfoRow(Icons.cake_rounded, 'Age', '${userProfile.age} years'),
      if (userProfile.gender != null)
        _buildInfoRow(Icons.wc_rounded, 'Gender', userProfile.gender!),
      if (web3Provider.isConnected)
        _buildInfoRow(
          Icons.account_balance_wallet,
          'Wallet Address',
          '${web3Provider.walletAddress!.substring(0, 6)}...${web3Provider.walletAddress!.substring(web3Provider.walletAddress!.length - 4)}',
        ),
    ]);
  }

  Widget _buildGoalsCard(BuildContext context, List<String> goals) {
    return _buildInfoCard(
      context,
      goals.map((goal) => _buildChipRow(goal)).toList(),
    );
  }

  Widget _buildCausesCard(BuildContext context, List<String> causes) {
    return _buildInfoCard(
      context,
      causes.map((cause) => _buildChipRow(cause)).toList(),
    );
  }

  Widget _buildAssessmentCard(BuildContext context, UserProfile userProfile) {
    final assessmentItems = <Widget>[];

    if (userProfile.stressFrequency != null) {
      assessmentItems.add(
        _buildInfoRow(
          Icons.psychology_rounded,
          'Stress Level',
          userProfile.stressFrequency!,
        ),
      );
    }
    if (userProfile.sleepQuality != null) {
      assessmentItems.add(
        _buildInfoRow(
          Icons.bedtime_rounded,
          'Sleep Quality',
          userProfile.sleepQuality!,
        ),
      );
    }
    if (userProfile.happinessLevel != null) {
      assessmentItems.add(
        _buildInfoRow(
          Icons.sentiment_very_satisfied_rounded,
          'Happiness Level',
          userProfile.happinessLevel!,
        ),
      );
    }
    if (userProfile.healthyEating != null) {
      assessmentItems.add(
        _buildInfoRow(
          Icons.restaurant_rounded,
          'Eating Habits',
          userProfile.healthyEating!,
        ),
      );
    }
    if (userProfile.meditationExperience != null) {
      assessmentItems.add(
        _buildInfoRow(
          Icons.self_improvement_rounded,
          'Meditation Experience',
          userProfile.meditationExperience!,
        ),
      );
    }

    return _buildInfoCard(context, assessmentItems);
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: children.map((child) {
            final isLast = child == children.last;
            return Column(
              children: [
                child,
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      color: AppColors.primary.withOpacity(0.1),
                      height: 1,
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
