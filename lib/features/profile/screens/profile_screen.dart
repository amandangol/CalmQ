import 'package:auralynn/features/auth/screens/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../../auth/models/user_profile.dart';
import '../../../app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background ?? Colors.grey[50],
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
      floatingActionButton: Consumer<UserProfileProvider>(
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Goals', userProfile.goals.length.toString()),
          _buildStatDivider(),
          _buildStatItem('Focus Areas', userProfile.causes.length.toString()),
          _buildStatDivider(),
          _buildStatItem('Profile', '100%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
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
    return _buildInfoCard(context, [
      _buildInfoRow(Icons.person_rounded, 'Name', userProfile.name),
      _buildInfoRow(Icons.cake_rounded, 'Age', '${userProfile.age} years'),
      if (userProfile.gender != null)
        _buildInfoRow(Icons.wc_rounded, 'Gender', userProfile.gender!),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
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
      ),
    );
  }

  Widget _buildChipRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
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
