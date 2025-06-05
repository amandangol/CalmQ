import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/screens/user_info_screen.dart';
import '../../../app_theme.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController ageController;
  bool isEditing = false;
  String? gender;
  List<String> goals = [];
  List<String> causes = [];
  String? stressFrequency;
  String? sleepQuality;
  String? happinessLevel;
  String? healthyEating;
  String? meditationExperience;

  // Options lists
  final List<String> genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
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

  final List<String> stressFrequencyOptions = [
    'Almost daily',
    'A few times a week',
    'A few times a month',
    'Rarely',
    'Never',
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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    ageController = TextEditingController();
    // Initialize with default values that match the options
    stressFrequency = stressFrequencyOptions.first;
    sleepQuality = sleepQualityOptions.first;
    happinessLevel = happinessLevelOptions.first;
    healthyEating = healthyEatingOptions.first;
    meditationExperience = meditationExperienceOptions.first;
    // Use Future.microtask to avoid setState during build
    Future.microtask(() => _loadUserProfile());
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    await context.read<UserProfileProvider>().loadUserProfile();
    final profile = context.read<UserProfileProvider>().userProfile;
    if (profile != null) {
      setState(() {
        nameController.text = profile.name;
        ageController.text = profile.age.toString();
        gender = profile.gender ?? genderOptions.first;
        goals = profile.goals;
        causes = profile.causes;
        // Ensure values match exactly with options
        stressFrequency =
            profile.stressFrequency ?? stressFrequencyOptions.first;
        sleepQuality = profile.sleepQuality ?? sleepQualityOptions.first;
        happinessLevel = profile.happinessLevel ?? happinessLevelOptions.first;
        healthyEating = profile.healthyEating ?? healthyEatingOptions.first;
        meditationExperience =
            profile.meditationExperience ?? meditationExperienceOptions.first;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<UserProfileProvider>().saveUserProfile(
        name: nameController.text,
        age: int.parse(ageController.text),
        gender: gender,
        goals: goals,
        causes: causes,
        stressFrequency: stressFrequency,
        sleepQuality: sleepQuality,
        happinessLevel: happinessLevel,
        healthyEating: healthyEating,
        meditationExperience: meditationExperience,
      );

      setState(() => isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, _) {
        final profile = userProfileProvider.userProfile;

        if (userProfileProvider.isLoading) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.background,
                  ],
                  stops: [0.0, 0.3, 1.0],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        if (profile == null) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.background,
                  ],
                  stops: [0.0, 0.3, 1.0],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 80,
                      color: AppColors.textLight,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No profile data available',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: 200,
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserInfoScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Create Profile',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Let\'s personalize your wellness journey',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                  AppColors.background,
                ],
                stops: [0.0, 0.3, 1.0],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Your Profile',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      centerTitle: true,
                    ),
                    actions: [
                      Container(
                        margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isEditing ? Icons.save : Icons.edit_outlined,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            if (isEditing) {
                              _saveProfile();
                            } else {
                              setState(() => isEditing = true);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildProfileHeader(profile, theme),
                            SizedBox(height: 32),
                            _buildPersonalInformationSection(profile, theme),
                            SizedBox(height: 24),
                            _buildWellnessGoalsSection(profile, theme),
                            SizedBox(height: 24),
                            _buildMentalHealthSection(profile, theme),
                            SizedBox(height: 24),
                            _buildLifestyleSection(profile, theme),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfile profile, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surface,
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            profile.name,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${profile.age} years old',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationSection(
    UserProfile profile,
    ThemeData theme,
  ) {
    return _buildSection('Personal Information', Icons.person_outline, [
      _buildEditableField(
        'Name',
        nameController,
        Icons.badge_outlined,
        isEditing: isEditing,
      ),
      SizedBox(height: 16),
      _buildEditableField(
        'Age',
        ageController,
        Icons.cake_outlined,
        isEditing: isEditing,
        keyboardType: TextInputType.number,
      ),
      SizedBox(height: 16),
      _buildEditableDropdown(
        'Gender',
        genderOptions,
        gender,
        (value) => setState(() => gender = value),
        isEditing: isEditing,
      ),
    ], theme);
  }

  Widget _buildWellnessGoalsSection(UserProfile profile, ThemeData theme) {
    return _buildSection('Wellness Goals', Icons.flag_outlined, [
      _buildEditableMultiSelect(
        'Goals',
        goalsOptions,
        goals,
        isEditing: isEditing,
      ),
    ], theme);
  }

  Widget _buildMentalHealthSection(UserProfile profile, ThemeData theme) {
    return _buildSection('Mental Health', Icons.psychology_outlined, [
      _buildEditableDropdown(
        'Stress Frequency',
        stressFrequencyOptions,
        stressFrequency,
        (value) {
          if (value != null) {
            setState(() => stressFrequency = value);
          }
        },
        isEditing: isEditing,
      ),
      SizedBox(height: 16),
      _buildEditableDropdown(
        'Sleep Quality',
        sleepQualityOptions,
        sleepQuality,
        (value) {
          if (value != null) {
            setState(() => sleepQuality = value);
          }
        },
        isEditing: isEditing,
      ),
      SizedBox(height: 16),
      _buildEditableDropdown(
        'Happiness Level',
        happinessLevelOptions,
        happinessLevel,
        (value) {
          if (value != null) {
            setState(() => happinessLevel = value);
          }
        },
        isEditing: isEditing,
      ),
    ], theme);
  }

  Widget _buildLifestyleSection(UserProfile profile, ThemeData theme) {
    return _buildSection('Lifestyle', Icons.local_florist_outlined, [
      _buildEditableDropdown(
        'Healthy Eating',
        healthyEatingOptions,
        healthyEating,
        (value) {
          if (value != null) {
            setState(() => healthyEating = value);
          }
        },
        isEditing: isEditing,
      ),
      SizedBox(height: 16),
      _buildEditableDropdown(
        'Meditation Experience',
        meditationExperienceOptions,
        meditationExperience,
        (value) {
          if (value != null) {
            setState(() => meditationExperience = value);
          }
        },
        isEditing: isEditing,
      ),
    ], theme);
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<Widget> children,
    ThemeData theme,
  ) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isEditing = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isEditing ? AppColors.surface : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: isEditing
                ? Border.all(color: AppColors.primary.withOpacity(0.3))
                : Border.all(color: Colors.transparent),
            boxShadow: isEditing
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            enabled: isEditing,
            keyboardType: keyboardType,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isEditing ? AppColors.primary : AppColors.textLight,
              ),
              prefixIcon: Icon(
                icon,
                color: isEditing ? AppColors.primary : AppColors.textLight,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? '$label is required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableDropdown(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged, {
    required bool isEditing,
  }) {
    final theme = Theme.of(context);
    // Ensure value is in options list
    final currentValue = options.contains(value) ? value : options.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isEditing ? AppColors.surface : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: isEditing
                ? Border.all(color: AppColors.primary.withOpacity(0.3))
                : Border.all(color: Colors.transparent),
            boxShadow: isEditing
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: DropdownButtonFormField<String>(
            value: currentValue,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.all(16),
            ),
            hint: Text(
              'Select an option',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
              ),
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              );
            }).toList(),
            onChanged: isEditing ? onChanged : null,
            validator: (value) {
              if (isEditing && (value == null || value.isEmpty)) {
                return 'Please select an option';
              }
              return null;
            },
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: isEditing ? AppColors.primary : AppColors.textLight,
            ),
            dropdownColor: AppColors.surface,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableMultiSelect(
    String label,
    List<String> options,
    List<String> selectedValues, {
    required bool isEditing,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((String option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? AppColors.surface : AppColors.accent,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: isEditing
                  ? (bool selected) {
                      setState(() {
                        selected
                            ? selectedValues.add(option)
                            : selectedValues.remove(option);
                      });
                    }
                  : null,
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              checkmarkColor: AppColors.surface,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textLight.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
