import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../../web3/providers/web3_provider.dart';
import '../../../app_theme.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? gender;
  List<String> goals = [];
  List<String> causes = [];
  String? stressFrequency;
  String? healthyEating;
  String? meditationExperience;
  String? sleepQuality;
  String? happinessLevel;

  final List<String> genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];
  final List<String> stressFrequencyOptions = [
    'Almost daily',
    'A few times a week',
    'A few times a month',
    'Rarely',
    'Never',
  ];
  final List<String> healthyEatingOptions = [
    'Always',
    'Most of the time',
    'Sometimes',
    'Rarely',
    'Never',
  ];
  final List<String> meditationExperienceOptions = [
    'Yes, I practice regularly',
    'I\'ve tried it a few times',
    'No, but I\'m interested',
    'No, not interested',
  ];
  final List<String> sleepQualityOptions = [
    'Excellent - I sleep deeply',
    'Good - Usually restful',
    'Fair - Sometimes restless',
    'Poor - Often tired',
    'Very poor - Chronic issues',
  ];
  final List<String> happinessLevelOptions = [
    'Very content and joyful',
    'Generally happy',
    'Balanced, some ups and downs',
    'Often feeling down',
    'Struggling with sadness',
  ];
  final List<String> goalsOptions = [
    'Manage anxiety',
    'Reduce stress',
    'Improve mood',
    'Better sleep',
    'Build confidence',
    'Enhance relationships',
    'Practice mindfulness',
    'Develop coping skills',
  ];
  final List<String> causesOptions = [
    'Work pressure',
    'Academic stress',
    'Relationship issues',
    'Financial concerns',
    'Health worries',
    'Family situations',
    'Social anxiety',
    'Life transitions',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Load existing profile data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = context.read<UserProfileProvider>().userProfile;
      if (userProfile != null) {
        nameController.text = userProfile.name;
        ageController.text = userProfile.age.toString();
        gender = userProfile.gender;
        goals = List.from(userProfile.goals);
        causes = List.from(userProfile.causes);
        stressFrequency = userProfile.stressFrequency;
        healthyEating = userProfile.healthyEating;
        meditationExperience = userProfile.meditationExperience;
        sleepQuality = userProfile.sleepQuality;
        happinessLevel = userProfile.happinessLevel;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return nameController.text.isNotEmpty &&
            ageController.text.isNotEmpty &&
            gender != null;
      case 1:
        return goals.isNotEmpty;
      case 2:
        return causes.isNotEmpty;
      case 3:
        return stressFrequency != null &&
            sleepQuality != null &&
            happinessLevel != null;
      case 4:
        return healthyEating != null && meditationExperience != null;
      default:
        return false;
    }
  }

  void _nextPage() {
    if (_canProceed()) {
      if (_currentPage < 4) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _saveData();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveData() async {
    try {
      await context.read<UserProfileProvider>().saveUserProfile(
        name: nameController.text,
        age: int.parse(ageController.text),
        gender: gender,
        goals: goals,
        causes: causes,
        stressFrequency: stressFrequency,
        healthyEating: healthyEating,
        meditationExperience: meditationExperience,
        sleepQuality: sleepQuality,
        happinessLevel: happinessLevel,
      );

      // Initialize Web3Auth after profile completion
      if (mounted) {
        final web3Provider = context.read<Web3Provider>();
        await web3Provider.initialize(context);

        // Show a dialog to connect wallet
        if (mounted) {
          final shouldConnectWallet = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Connect Solana Wallet'),
              content: const Text(
                'Would you like to connect your Solana wallet now? You can also do this later from your profile.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Later'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Connect Now'),
                ),
              ],
            ),
          );

          if (shouldConnectWallet == true && mounted) {
            try {
              await web3Provider.connectWallet();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wallet connected successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to connect wallet: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        }
      }

      // Pop back to profile screen
      Navigator.pop(context);
    } catch (e) {
      String errorMessage = 'We encountered an issue saving your profile';
      if (e.toString().contains('unable to start connection')) {
        errorMessage = 'Please check your internet connection and try again.';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'Authentication issue. Please sign in again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade300,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _saveData,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = context.watch<UserProfileProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.05),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: userProfileProvider.isLoading
              ? _buildLoadingScreen()
              : Column(
                  children: [
                    _buildHeader(),
                    _buildProgressIndicator(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: [
                          _buildBasicInfoPage(),
                          _buildGoalsPage(),
                          _buildCausesPage(),
                          _buildWellnessAssessmentPage(),
                          _buildLifestylePage(),
                        ],
                      ),
                    ),
                    _buildNavigationButtons(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Setting up your wellness journey...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This will just take a moment',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
                onPressed: _previousPage,
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Welcome to Auralynn',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Let\'s personalize your wellness experience',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index <= _currentPage
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8),
          Text(
            'Step ${_currentPage + 1} of 5',
            style: TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle('Tell us about yourself', '👋'),
          SizedBox(height: 32),
          _buildTextField(
            'What should we call you?',
            nameController,
            hint: 'Enter your first name',
          ),
          SizedBox(height: 20),
          _buildTextField(
            'What\'s your age?',
            ageController,
            keyboardType: TextInputType.number,
            hint: 'This helps us personalize your experience',
          ),
          SizedBox(height: 20),
          _buildDropdownField(
            'How do you identify?',
            genderOptions,
            gender,
            (value) => setState(() => gender = value),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle('What are your wellness goals?', '🎯'),
          SizedBox(height: 16),
          Text(
            'Select all that apply - we\'ll tailor your experience accordingly',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24),
          _buildMultiSelectField(goalsOptions, goals),
        ],
      ),
    );
  }

  Widget _buildCausesPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle('What affects your mental wellbeing?', '💭'),
          SizedBox(height: 16),
          Text(
            'Understanding your challenges helps us provide better support',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24),
          _buildMultiSelectField(causesOptions, causes),
        ],
      ),
    );
  }

  Widget _buildWellnessAssessmentPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle('How are you feeling lately?', '🌱'),
          SizedBox(height: 32),
          _buildDropdownField(
            'How often do you feel stressed?',
            stressFrequencyOptions,
            stressFrequency,
            (value) => setState(() => stressFrequency = value),
          ),
          SizedBox(height: 20),
          _buildDropdownField(
            'How would you describe your sleep?',
            sleepQualityOptions,
            sleepQuality,
            (value) => setState(() => sleepQuality = value),
          ),
          SizedBox(height: 20),
          _buildDropdownField(
            'How would you describe your mood recently?',
            happinessLevelOptions,
            happinessLevel,
            (value) => setState(() => happinessLevel = value),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestylePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle('Let\'s talk about your lifestyle', '🌿'),
          SizedBox(height: 32),
          _buildDropdownField(
            'How would you rate your eating habits?',
            healthyEatingOptions,
            healthyEating,
            (value) => setState(() => healthyEating = value),
          ),
          SizedBox(height: 20),
          _buildDropdownField(
            'What\'s your experience with meditation?',
            meditationExperienceOptions,
            meditationExperience,
            (value) => setState(() => meditationExperience = value),
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Text(
                  '🎉 You\'re all set!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We\'ll use this information to create a personalized wellness plan just for you.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTitle(String title, String emoji) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontSize: 32)),
        SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
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
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? '$label is required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
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
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.all(16),
            ),
            hint: Text(
              'Select an option',
              style: TextStyle(color: AppColors.textLight),
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectField(
    List<String> options,
    List<String> selectedValues,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((String option) {
        final isSelected = selectedValues.contains(option);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected
                  ? selectedValues.remove(option)
                  : selectedValues.add(option);
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textLight.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? AppColors.surface : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              flex: 1,
              child: Container(
                height: 50,
                child: OutlinedButton(
                  onPressed: _previousPage,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == 4 ? 'Complete Setup' : 'Continue',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
