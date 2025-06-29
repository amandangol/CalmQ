import 'package:auralynn/features/affirmations/screens/affirmations_screen.dart';
import 'package:auralynn/features/wellness/screens/water_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../mood/providers/mood_provider.dart';
import '../../reminders/screens/reminders_screen.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../../focus/screens/focus_screen.dart';
import '../../journal/screens/journal_screen.dart';
import '../../../app_theme.dart';
import '../../mood/screens/mood_screen.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../../chat/screens/chat_screen.dart';
import '../../../widgets/custom_confirmation_dialog.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../affirmations/providers/affirmation_provider.dart';
import 'package:intl/intl.dart';
import '../../chat/providers/chat_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize profile in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfile();
    });
  }

  Future<void> _initializeProfile() async {
    if (mounted) {
      await context.read<UserProfileProvider>().initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final theme = Theme.of(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF5F7FA), Color(0xFFE8ECF4)],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context, authProvider),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    _buildWelcomeSection(
                      context,
                      user?.displayName ?? 'Friend',
                    ),
                    SizedBox(height: 16),
                    _buildDailyInspirationSection(context, theme),
                    SizedBox(height: 16),
                    _buildTodayCheckinSection(context, moodProvider, theme),
                    SizedBox(height: 16),
                    _buildTodaysMoodSection(context, moodProvider, theme),
                    SizedBox(height: 16),
                    _buildQuickActionsHeader(context, theme),
                    SizedBox(height: 12),
                    _buildQuickActionsGrid(context),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthProvider authProvider) {
    return CustomAppBar(
      title: 'Serenara',
      showBackButton: false,
      leadingIcon: Icons.self_improvement_rounded,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () => _handleSignOut(context),
        ),
      ],
      subtitle: Text(
        'Your wellness companion',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmationDialog(
        title: 'Sign Out',
        message: 'Are you sure you want to sign out?',
        confirmText: 'Sign Out',
        cancelText: 'Cancel',
        confirmColor: AppColors.error,
        onConfirm: () async {
          try {
            context.read<MoodProvider>().clearData();
            context.read<UserProfileProvider>().clearProfile();
            context.read<ChatProvider>().clearChat();
            await context.read<AuthProvider>().signOut();
            if (context.mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error signing out: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String userName) {
    final now = DateTime.now();
    final theme = Theme.of(context);
    final userProfile = context.watch<UserProfileProvider>().userProfile;

    final greeting = _getTimeBasedGreeting(now.hour);
    final name = userProfile?.name ?? userName;
    final dateFormat = DateFormat('EEEE, MMMM d');
    final today = dateFormat.format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.surface,

          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.textPrimary,
                        AppColors.textPrimary.withOpacity(0.8),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      '$greeting,',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Name with emphasis
                  Text(
                    name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      fontSize: 24,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date with enhanced styling
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          today,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Decorative element
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getTimeBasedColor(now.hour).withOpacity(0.2),
                    _getTimeBasedColor(now.hour).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getTimeBasedIcon(now.hour),
                size: 28,
                color: _getTimeBasedColor(now.hour),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeBasedGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData _getTimeBasedIcon(int hour) {
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_rounded;
  }

  Color _getTimeBasedColor(int hour) {
    if (hour < 12) return Colors.orange.shade400;
    if (hour < 17) return Colors.blue.shade400;
    return Colors.indigo.shade400;
  }

  Widget _buildTodayCheckinSection(
    BuildContext context,
    MoodProvider moodProvider,
    ThemeData theme,
  ) {
    final int streak = moodProvider.getMoodStreak();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's check-in",
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Check-in Streak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '$streak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.local_fire_department,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysMoodSection(
    BuildContext context,
    MoodProvider moodProvider,
    ThemeData theme,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_emotions, color: AppColors.secondary, size: 20),
              SizedBox(width: 8),
              Text(
                "Today's Mood",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (moodProvider.hasLoggedMoodToday() &&
              moodProvider.todayMood != null) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Image.asset(
                    'assets/images/${moodProvider.getMoodImage(moodProvider.todayMood!.mood)}.png',
                    width: 32,
                    height: 32,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moodProvider.todayMood!.mood,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        moodProvider.getMoodSuggestion(
                          moodProvider.todayMood!.mood,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showMoodPicker(context),
                  icon: Icon(Icons.edit, color: AppColors.primary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ] else ...[
            _MoodSelectionGrid(
              onMoodSelected: (mood) {
                moodProvider.addMood(mood);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final quickActions = [
      QuickActionData(
        icon: Icons.psychology,
        label: 'Serenity',
        color: AppColors.accent,
        description: 'AI Chat',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.calendar_month,
        label: 'Mood',
        color: AppColors.primary,
        description: 'Tracker',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MoodScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.air,
        label: 'Breathing',
        color: AppColors.secondary,
        description: 'Exercises',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BreathingScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.water_drop,
        label: 'Water',
        color: AppColors.info,
        description: 'Tracker',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WaterTrackerScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.timer,
        label: 'Focus',
        color: AppColors.accent,
        description: 'Timer',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FocusScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.book,
        label: 'Journal',
        color: AppColors.secondaryLight,
        description: 'Write',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JournalScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.notifications_active,
        label: 'Reminders',
        color: AppColors.error,
        description: 'Alerts',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RemindersScreen()),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
        ),
        itemCount: quickActions.length,
        itemBuilder: (context, index) {
          final action = quickActions[index];
          return _QuickActionCard(action: action);
        },
      ),
    );
  }

  Widget _buildDailyInspirationSection(BuildContext context, ThemeData theme) {
    final affirmationProvider = context.watch<AffirmationProvider>();
    final dailyAffirmation = affirmationProvider.getDailyAffirmation();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Daily Inspiration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AffirmationsScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'More',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              '"${dailyAffirmation.text}"',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: MoodPickerSheet(),
      ),
    );
  }
}

class QuickActionData {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  QuickActionData({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final QuickActionData action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: action.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(action.icon, size: 24, color: AppColors.surface),
              ),
              SizedBox(height: 12),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                action.description,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoodPickerSheet extends StatefulWidget {
  @override
  _MoodPickerSheetState createState() => _MoodPickerSheetState();
}

class _MoodPickerSheetState extends State<MoodPickerSheet> {
  final _triggerController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedMood;

  final Map<String, String> _moodImages = {
    'Angry': 'angry',
    'Sad': 'sad',
    'Neutral': 'neutral',
    'Happy': 'happy',
    'Very Happy': 'very-happy',
  };

  @override
  void dispose() {
    _triggerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
          ),
          Text(
            'How are you feeling?',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _moodImages.entries.map((entry) {
              final isSelected = _selectedMood == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = entry.key;
                  });
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.6,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textLight.withOpacity(0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/${entry.value}.png',
                            width: 48,
                            height: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            entry.key,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textLight,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24),
          TextField(
            controller: _triggerController,
            decoration: InputDecoration(
              labelText: 'What triggered this? (Optional)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Quick note (Optional)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
            ),
            maxLines: 2,
          ),
          SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: _selectedMood == null
                  ? AppColors.surfaceVariant
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: _selectedMood == null
                  ? null
                  : () {
                      moodProvider.addMood(
                        _selectedMood!,
                        trigger: _triggerController.text.isEmpty
                            ? null
                            : _triggerController.text,
                        note: _noteController.text.isEmpty
                            ? null
                            : _noteController.text,
                      );
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedMood == null
                    ? AppColors.surfaceVariant
                    : Colors.transparent,
                foregroundColor: _selectedMood == null
                    ? AppColors.textLight
                    : AppColors.surface,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Mood',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodSelectionGrid extends StatefulWidget {
  final Function(String) onMoodSelected;

  const _MoodSelectionGrid({required this.onMoodSelected});

  @override
  State<_MoodSelectionGrid> createState() => _MoodSelectionGridState();
}

class _MoodSelectionGridState extends State<_MoodSelectionGrid> {
  String? _selectedMood;

  final Map<String, String> _moodImages = {
    'Angry': 'angry',
    'Sad': 'sad',
    'Neutral': 'neutral',
    'Happy': 'happy',
    'Very Happy': 'very-happy',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How do you feel today?',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _moodImages.entries.map((entry) {
            final isSelected = _selectedMood == entry.key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = entry.key;
                });
                widget.onMoodSelected(entry.key);
              },
              child: AnimatedScale(
                scale: isSelected ? 1.2 : 1.0,
                duration: Duration(milliseconds: 300),
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.6,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textLight.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/${entry.value}.png',
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textLight,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
