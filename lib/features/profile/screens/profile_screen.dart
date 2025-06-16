import 'package:auralynn/features/auth/screens/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../../auth/models/user_profile.dart';
import '../../../app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../web3/providers/web3_provider.dart';
import '../../settings/screens/settings_screen.dart';
import 'package:flutter/services.dart';
import '../../../widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditMode = false;
  Map<String, dynamic> _editedValues = {};
  bool _isSaving = false;
  bool _showWeb3Profile = false;

  @override
  void initState() {
    super.initState();

    // Initialize the providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().initialize();
      context.read<Web3Provider>().initialize(context);
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _editedValues.clear();
      }
    });
  }

  void _updateField(String field, dynamic value) {
    setState(() {
      _editedValues[field] = value;
    });
  }

  void _toggleProfile() {
    setState(() {
      _showWeb3Profile = !_showWeb3Profile;
    });
  }

  Future<void> _saveChanges() async {
    if (_editedValues.isEmpty) {
      _toggleEditMode();
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userProfile = context.read<UserProfileProvider>().userProfile;
      if (userProfile == null) return;

      final updatedProfile = userProfile.copyWith(
        name: _editedValues['name'] ?? userProfile.name,
        age: _editedValues['age'] ?? userProfile.age,
        gender: _editedValues['gender'] ?? userProfile.gender,
        goals: _editedValues['goals'] ?? userProfile.goals,
        causes: _editedValues['causes'] ?? userProfile.causes,
        stressFrequency:
            _editedValues['stressFrequency'] ?? userProfile.stressFrequency,
        healthyEating:
            _editedValues['healthyEating'] ?? userProfile.healthyEating,
        meditationExperience:
            _editedValues['meditationExperience'] ??
            userProfile.meditationExperience,
        sleepQuality: _editedValues['sleepQuality'] ?? userProfile.sleepQuality,
        happinessLevel:
            _editedValues['happinessLevel'] ?? userProfile.happinessLevel,
      );

      await context.read<UserProfileProvider>().updateUserProfile(
        updatedProfile,
      );
      _editedValues.clear();
      _toggleEditMode();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomAppBar(
            title: 'My Profile',
            showBackButton: false,
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    _isEditMode ? Icons.close_rounded : Icons.edit_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _isEditMode ? _toggleEditMode : _toggleEditMode,
                ),
              ),
              if (_isEditMode) ...[
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    onPressed: _isSaving ? null : _saveChanges,
                  ),
                ),
              ],
            ],
          ),
          // Body content
          Expanded(
            child: Consumer<UserProfileProvider>(
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
          ),
        ],
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your profile...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please wait a moment',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to CalmQ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Let\'s create your personalized wellness profile to get started on your journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
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
    return Column(
      children: [
        // Profile Switch Buttons
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildProfileSwitchButton(
                  icon: Icons.person_rounded,
                  label: 'Personal Profile',
                  isSelected: !_showWeb3Profile,
                  onTap: () {
                    if (_showWeb3Profile) _toggleProfile();
                  },
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.primary.withOpacity(0.1),
              ),
              Expanded(
                child: _buildProfileSwitchButton(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Web3 Profile',
                  isSelected: _showWeb3Profile,
                  onTap: () {
                    if (!_showWeb3Profile) _toggleProfile();
                  },
                ),
              ),
            ],
          ),
        ),
        // Profile Content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showWeb3Profile
                ? _buildWeb3ProfileContent(context)
                : _buildPersonalProfileContent(context, userProfile),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSwitchButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalProfileContent(
    BuildContext context,
    UserProfile userProfile,
  ) {
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

  Widget _buildWeb3ProfileContent(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildWeb3Section(context),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeb3Section(BuildContext context) {
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) {
        if (!web3Provider.isConnected) {
          return _buildWeb3ConnectCard(context, web3Provider);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Wallet Information'),
            _buildWeb3StatsCard(context, web3Provider),
          ],
        );
      },
    );
  }

  Widget _buildWeb3ConnectCard(
    BuildContext context,
    Web3Provider web3Provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect Your Wallet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connect your wallet to manage your ETH balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (web3Provider.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 20, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      web3Provider.error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton.icon(
                onPressed: web3Provider.isConnecting
                    ? null
                    : () async {
                        try {
                          await web3Provider.connectWallet();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to connect wallet: ${e.toString()}',
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                icon: web3Provider.isConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                      ),
                label: Text(
                  web3Provider.isConnecting
                      ? 'Connecting...'
                      : 'Connect Wallet',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeb3StatsCard(BuildContext context, Web3Provider web3Provider) {
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
          children: [
            // Header with wallet info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected Wallet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _copyToClipboard(
                          context,
                          web3Provider.walletAddress!,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${web3Provider.walletAddress!.substring(0, 6)}...${web3Provider.walletAddress!.substring(web3Provider.walletAddress!.length - 4)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Network status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.public_rounded, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Sepolia Testnet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Connected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Balance card
            _buildBalanceCard(
              icon: Icons.currency_exchange_rounded,
              label: 'ETH Balance',
              value: web3Provider.ethBalance,
              color: AppColors.primary,
              isFullWidth: true,
            ),

            const SizedBox(height: 24),

            // Disconnect button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDisconnectDialog(context, web3Provider),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Disconnect Wallet'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.trending_up, size: 12, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Address copied to clipboard'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, Web3Provider web3Provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Disconnect Wallet'),
        content: const Text(
          'Are you sure you want to disconnect your wallet? You won\'t be able to earn NFT achievements until you reconnect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              web3Provider.disconnectWallet();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(UserProfile userProfile) {
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
              _buildStatItem(
                'Profile',
                '$completionPercentage%',
                Icons.person_rounded,
              ),
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
    final email = authProvider.user?.email ?? 'Not set';

    return _buildInfoCard(context, [
      _buildEditableInfoRow(
        Icons.person_rounded,
        'Name',
        userProfile.name.isNotEmpty ? userProfile.name : 'Not set',
        'name',
        (value) => _updateField('name', value),
      ),
      _buildInfoRow(Icons.email_rounded, 'Email', email),
      _buildEditableInfoRow(
        Icons.cake_rounded,
        'Age',
        userProfile.age > 0 ? '${userProfile.age} years' : 'Not set',
        'age',
        (value) => _updateField('age', int.tryParse(value) ?? userProfile.age),
        keyboardType: TextInputType.number,
      ),
      _buildEditableDropdownRow(
        Icons.wc_rounded,
        'Gender',
        userProfile.gender ?? 'Not set',
        'gender',
        ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
        (value) => _updateField('gender', value),
      ),
      if (userProfile.createdAt != null)
        _buildInfoRow(
          Icons.calendar_today_rounded,
          'Member Since',
          _formatDate(userProfile.createdAt!),
        ),
      if (web3Provider.isConnected)
        _buildInfoRow(
          Icons.account_balance_wallet,
          'Wallet Address',
          '${web3Provider.walletAddress!.substring(0, 6)}...${web3Provider.walletAddress!.substring(web3Provider.walletAddress!.length - 4)}',
        ),
    ]);
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildEditableInfoRow(
    IconData icon,
    String label,
    String value,
    String field,
    ValueChanged<String> onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
              _isEditMode
                  ? Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        initialValue: _editedValues[field]?.toString() ?? value,
                        keyboardType: keyboardType,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          hintText: value,
                          hintStyle: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                        onChanged: onChanged,
                      ),
                    )
                  : Text(
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

  Widget _buildEditableDropdownRow(
    IconData icon,
    String label,
    String value,
    String field,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
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
              _isEditMode
                  ? Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _editedValues[field] ?? value,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        items: options.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) onChanged(newValue);
                        },
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                        ),
                        dropdownColor: AppColors.surface,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  : Text(
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

  Widget _buildGoalsCard(BuildContext context, List<String> goals) {
    return _buildInfoCard(context, [
      if (_isEditMode)
        _buildMultiSelectField(
          'Wellness Goals',
          _editedValues['goals'] ?? goals,
          (newGoals) => _updateField('goals', newGoals),
          [
            'Manage anxiety',
            'Reduce stress',
            'Improve mood',
            'Better sleep',
            'Build confidence',
            'Enhance relationships',
            'Practice mindfulness',
            'Develop coping skills',
          ],
        )
      else if (goals.isEmpty)
        _buildEmptyState('No wellness goals set yet')
      else
        ...goals.map((goal) => _buildChipRow(goal)).toList(),
    ]);
  }

  Widget _buildCausesCard(BuildContext context, List<String> causes) {
    return _buildInfoCard(context, [
      if (_isEditMode)
        _buildMultiSelectField(
          'Areas of Focus',
          _editedValues['causes'] ?? causes,
          (newCauses) => _updateField('causes', newCauses),
          [
            'Work pressure',
            'Academic stress',
            'Relationship issues',
            'Financial concerns',
            'Health worries',
            'Family situations',
            'Social anxiety',
            'Life transitions',
            'Other',
          ],
        )
      else if (causes.isEmpty)
        _buildEmptyState('No areas of focus set yet')
      else
        ...causes.map((cause) => _buildChipRow(cause)).toList(),
    ]);
  }

  Widget _buildMultiSelectField(
    String label,
    List<String> selectedValues,
    ValueChanged<List<String>> onChanged,
    List<String> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select all that apply',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((option) {
                  final isSelected = selectedValues.contains(option);
                  return InkWell(
                    onTap: () {
                      final newValues = List<String>.from(selectedValues);
                      if (isSelected) {
                        newValues.remove(option);
                      } else {
                        newValues.add(option);
                      }
                      onChanged(newValues);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.white,
                            )
                          else
                            Icon(
                              Icons.circle_outlined,
                              size: 18,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          SizedBox(width: 8),
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(BuildContext context, UserProfile userProfile) {
    final assessmentItems = <Widget>[];

    assessmentItems.add(
      _buildEditableDropdownRow(
        Icons.psychology_rounded,
        'Stress Level',
        userProfile.stressFrequency ?? 'Not set',
        'stressFrequency',
        [
          'Almost daily',
          'A few times a week',
          'A few times a month',
          'Rarely',
          'Never',
        ],
        (value) => _updateField('stressFrequency', value),
      ),
    );

    assessmentItems.add(
      _buildEditableDropdownRow(
        Icons.bedtime_rounded,
        'Sleep Quality',
        userProfile.sleepQuality ?? 'Not set',
        'sleepQuality',
        [
          'Excellent - I sleep deeply',
          'Good - Usually restful',
          'Fair - Sometimes restless',
          'Poor - Often tired',
          'Very poor - Chronic issues',
        ],
        (value) => _updateField('sleepQuality', value),
      ),
    );

    assessmentItems.add(
      _buildEditableDropdownRow(
        Icons.sentiment_very_satisfied_rounded,
        'Happiness Level',
        userProfile.happinessLevel ?? 'Not set',
        'happinessLevel',
        [
          'Very content and joyful',
          'Generally happy',
          'Balanced, some ups and downs',
          'Often feeling down',
          'Struggling with sadness',
        ],
        (value) => _updateField('happinessLevel', value),
      ),
    );

    assessmentItems.add(
      _buildEditableDropdownRow(
        Icons.restaurant_rounded,
        'Eating Habits',
        userProfile.healthyEating ?? 'Not set',
        'healthyEating',
        ['Always', 'Most of the time', 'Sometimes', 'Rarely', 'Never'],
        (value) => _updateField('healthyEating', value),
      ),
    );

    assessmentItems.add(
      _buildEditableDropdownRow(
        Icons.self_improvement_rounded,
        'Meditation Experience',
        userProfile.meditationExperience ?? 'Not set',
        'meditationExperience',
        [
          'Yes, I practice regularly',
          'I\'ve tried it a few times',
          'No, but I\'m interested',
          'No, not interested',
        ],
        (value) => _updateField('meditationExperience', value),
      ),
    );

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

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 32,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
