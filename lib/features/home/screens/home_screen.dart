import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../mood/providers/mood_provider.dart';
import '../../breathing/providers/breathing_provider.dart';
import '../../affirmations/providers/affirmation_provider.dart';
import '../../reminders/screens/reminders_screen.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../../focus/screens/focus_screen.dart';
import '../../journal/screens/journal_screen.dart';
import '../../sos/screens/sos_screen.dart';
import '../../affirmations/screens/affirmation_screen.dart';
import '../../../app_theme.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final theme = Theme.of(context);
    final user = authProvider.user;

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
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context, user?.displayName ?? 'Friend'),
              SizedBox(height: 24),

              // Wellness Score Section
              _buildWellnessScore(context),
              SizedBox(height: 24),

              // Today's Mood Section
              _buildTodaysMoodSection(context, moodProvider, theme),
              SizedBox(height: 24),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              _buildQuickActionsGrid(context),
              SizedBox(height: 24),

              // Daily Inspiration Section
              _buildDailyInspirationSection(context, theme),
              SizedBox(height: 24),

              // Progress Tracking Section
              _buildProgressSection(context, moodProvider),
              SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[400]!, Colors.blue[400]!],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.surface.withOpacity(0.7),
                  ),
                ),
                Text(
                  userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'How are you taking care of yourself today?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.surface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.spa, color: AppColors.surface, size: 48),
        ],
      ),
    );
  }

  Widget _buildWellnessScore(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.trending_up, color: Colors.green[600], size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '78%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Great progress!',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
              Icon(Icons.favorite, color: AppColors.secondary, size: 24),
              SizedBox(width: 8),
              Text(
                "Today's Mood",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (moodProvider.todayMood != null) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    moodProvider.todayMood!.emoji,
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moodProvider.todayMood!.mood,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        moodProvider.getMoodSuggestion(
                          moodProvider.todayMood!.mood,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: moodProvider.moodEmojis.entries.map((entry) {
                return GestureDetector(
                  onTap: () => _showMoodPicker(context),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(entry.value, style: TextStyle(fontSize: 24)),
                        SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () => _showMoodPicker(context),
                icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
                label: Text(
                  'Log your mood',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final quickActions = [
      QuickActionData(
        icon: Icons.air,
        label: 'Breathing',
        color: Colors.blue,
        description: 'Guided exercises',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BreathingScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.timer,
        label: 'Focus',
        color: Colors.orange,
        description: 'Meditation timer',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FocusScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.book,
        label: 'Journal',
        color: Colors.green,
        description: 'Express thoughts',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JournalScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.notifications_active,
        label: 'Reminders',
        color: Colors.purple,
        description: 'Self-care alerts',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RemindersScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.emergency,
        label: 'SOS',
        color: Colors.red,
        description: 'Crisis support',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SOSScreen()),
        ),
      ),
      QuickActionData(
        icon: Icons.auto_awesome,
        label: 'Affirmations',
        color: Colors.pink,
        description: 'Daily positivity',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AffirmationScreen()),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink[50]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.pink[400], size: 24),
              SizedBox(width: 8),
              Text(
                'Daily Inspiration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            context.watch<AffirmationProvider>().dailyAffirmation?.text ??
                'Loading your daily inspiration...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AffirmationScreen()),
                );
              },
              icon: Icon(Icons.arrow_forward, size: 16),
              label: Text('More Affirmations'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink[600],
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    MoodProvider moodProvider,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Icon(Icons.analytics, color: Colors.blue[400], size: 24),
              SizedBox(width: 8),
              Text(
                'This Week\'s Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProgressStat(
                icon: Icons.favorite,
                label: 'Mood Logs',
                value: '5',
                color: Colors.pink,
              ),
              _ProgressStat(
                icon: Icons.self_improvement,
                label: 'Meditation',
                value: '120min',
                color: Colors.blue,
              ),
              _ProgressStat(
                icon: Icons.book,
                label: 'Journal',
                value: '3',
                color: Colors.green,
              ),
            ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(action.icon, size: 28, color: action.color),
              ),
              SizedBox(height: 12),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                action.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProgressStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
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

  @override
  void dispose() {
    _triggerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();

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
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
          ),
          Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 16,
            runSpacing: 16,
            children: [
              for (var entry in moodProvider.moodEmojis.entries)
                _MoodEmojiButton(
                  emoji: entry.value,
                  label: entry.key,
                  isSelected: _selectedMood == entry.key,
                  onTap: () {
                    setState(() {
                      _selectedMood = entry.key;
                    });
                  },
                ),
            ],
          ),
          SizedBox(height: 24),
          TextField(
            controller: _triggerController,
            decoration: InputDecoration(
              labelText: 'What triggered this? (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[400]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Quick note (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[400]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 2,
          ),
          SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: _selectedMood == null
                  ? null
                  : LinearGradient(
                      colors: [Colors.purple[400]!, Colors.blue[400]!],
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
                    ? Colors.grey[300]
                    : Colors.transparent,
                foregroundColor: Colors.white,
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

class _MoodEmojiButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodEmojiButton({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textLight.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
