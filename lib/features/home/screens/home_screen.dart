import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../mood/providers/mood_provider.dart';
import '../../affirmations/providers/affirmation_provider.dart';
import '../../reminders/screens/reminders_screen.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../../focus/screens/focus_screen.dart';
import '../../journal/screens/journal_screen.dart';
import '../../sos/screens/sos_screen.dart';
import '../../affirmations/screens/affirmation_screen.dart';
import '../../../app_theme.dart';
import '../../mood/screens/mood_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final theme = Theme.of(context);
    final user = authProvider.user;

    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Auralynn',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.logout, color: AppColors.textLight),
              onPressed: () => authProvider.signOut(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context, user?.displayName ?? 'Friend'),
              SizedBox(height: 24),

              // Today's Check-in Section (Streak)
              _buildTodayCheckinSection(context, moodProvider, theme),
              SizedBox(height: 24),

              // Today's Mood Section (Log Mood)
              _buildTodaysMoodSection(context, moodProvider, theme),
              SizedBox(height: 24),

              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildQuickActionsGrid(context),
              ),
              SizedBox(height: 24),

              // Daily Inspiration Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildDailyInspirationSection(context, theme),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.secondaryLight],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withOpacity(0.5),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showMoodPicker(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Icon(Icons.favorite, color: Colors.white),
          label: Text(
            'Log Mood',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String userName) {
    final now = DateTime.now();
    final theme = Theme.of(context);
    String greeting;
    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.secondaryLight],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, $userName!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
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
                        Icons.favorite,
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
              Icon(Icons.favorite, color: AppColors.secondary, size: 20),
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
          if (moodProvider.hasLoggedMoodToday()) ...[
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

  Widget _buildQuickActionsGrid(BuildContext context) {
    final quickActions = [
      QuickActionData(
        icon: Icons.calendar_month,
        label: 'Your history',
        color: AppColors.primary,
        description: 'View past entries',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MoodScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.air,
        label: 'Breathing',
        color: AppColors.secondary,
        description: 'Guided exercises',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BreathingScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.timer,
        label: 'Focus',
        color: AppColors.accent,
        description: 'Meditation timer',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FocusScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.book,
        label: 'Journal',
        color: AppColors.secondaryLight,
        description: 'Express thoughts',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JournalScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.notifications_active,
        label: 'Reminders',
        color: AppColors.error,
        description: 'Self-care alerts',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RemindersScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.emergency,
        label: 'SOS',
        color: AppColors.accentWarm,
        description: 'Crisis support',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SOSScreen()),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: quickActions.length,
      itemBuilder: (context, index) {
        final action = quickActions[index];
        return _QuickActionCard(action: action);
      },
    );
  }

  Widget _buildDailyInspirationSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Daily Inspiration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            context.watch<AffirmationProvider>().dailyAffirmation?.text ??
                'Loading your daily inspiration...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondaryLight, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AffirmationScreen()),
                  );
                },
                icon: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.surface,
                ),
                label: Text(
                  'More Affirmations',
                  style: TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [action.color, action.color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: action.color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(action.icon, size: 32, color: AppColors.surface),
              ),
              SizedBox(height: 16),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                action.description,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
              gradient: _selectedMood == null
                  ? null
                  : LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
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
