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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final theme = Theme.of(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Wellness'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Mood Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Mood", style: theme.textTheme.titleLarge),
                      SizedBox(height: 8),
                      if (moodProvider.todayMood != null) ...[
                        Row(
                          children: [
                            Text(
                              moodProvider.todayMood!.emoji,
                              style: TextStyle(fontSize: 32),
                            ),
                            SizedBox(width: 8),
                            Text(
                              moodProvider.todayMood!.mood,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          moodProvider.getMoodSuggestion(
                            moodProvider.todayMood!.mood,
                          ),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ] else
                        Text(
                          'How are you feeling today?',
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Quick Access Section
              Text('Quick Access', style: theme.textTheme.titleLarge),
              SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _QuickAccessButton(
                    icon: Icons.self_improvement,
                    label: 'Breathing',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BreathingScreen()),
                    ),
                  ),
                  _QuickAccessButton(
                    icon: Icons.timer,
                    label: 'Focus',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FocusScreen()),
                    ),
                  ),
                  _QuickAccessButton(
                    icon: Icons.book,
                    label: 'Journal',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => JournalScreen()),
                    ),
                  ),
                  _QuickAccessButton(
                    icon: Icons.notifications,
                    label: 'Reminders',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RemindersScreen()),
                    ),
                  ),
                  _QuickAccessButton(
                    icon: Icons.emergency,
                    label: 'SOS',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SOSScreen()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Daily Tip Section
              Card(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_quote,
                            color: theme.colorScheme.secondary,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context
                                      .watch<AffirmationProvider>()
                                      .dailyAffirmation
                                      ?.text ??
                                  'Loading...',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AffirmationScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.auto_awesome, size: 16),
                          label: Text('More Affirmations'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showMoodPicker(context);
        },
        icon: Icon(Icons.add),
        label: Text('Log Mood'),
      ),
    );
  }

  void _showMoodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MoodPickerSheet(),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              SizedBox(height: 8),
              Text(label, style: theme.textTheme.titleMedium),
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
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How are you feeling?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          SizedBox(height: 16),
          TextField(
            controller: _triggerController,
            decoration: InputDecoration(
              labelText: 'What triggered this? (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Quick note (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
          ),
          SizedBox(height: 16),
          ElevatedButton(
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
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Save Mood'),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 32)),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
