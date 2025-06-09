import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../../../app_theme.dart';
import '../../../widgets/custom_app_bar.dart';

class RemindersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    final theme = Theme.of(context);

    if (reminderProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (!reminderProvider.hasPermission) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
                SizedBox(height: 16),
                Text(
                  'Notification Permission Required',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Please enable notifications in your device settings to use reminders.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    reminderProvider.initializeNotifications();
                  },
                  icon: Icon(Icons.settings, size: 18),
                  label: Text('Open Settings', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomAppBar(
            title: 'Reminders',
            leadingIcon: Icons.notifications_active_rounded,
          ),
          // Body content
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.notifications_active,
                                  color: AppColors.surface,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Reminders',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: AppColors.surface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Set reminders for your wellness activities',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.surface
                                                .withOpacity(0.9),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Reminders List
                    Expanded(
                      child: ListView(
                        children: [
                          _ReminderCard(
                            title: 'Journal Reminder',
                            subtitle:
                                'Set a daily reminder to write in your journal',
                            icon: Icons.edit_note,
                            time: reminderProvider.journalReminderTime,
                            onTimeSelected: (time) => _handleTimeSelection(
                              context,
                              time,
                              reminderProvider.setJournalReminder,
                              'Journal',
                            ),
                          ),
                          SizedBox(height: 16),
                          _ReminderCard(
                            title: 'Breathing Exercise',
                            subtitle:
                                'Set a daily reminder for breathing exercises',
                            icon: Icons.air,
                            time: reminderProvider.breathingReminderTime,
                            onTimeSelected: (time) => _handleTimeSelection(
                              context,
                              time,
                              reminderProvider.setBreathingReminder,
                              'Breathing',
                            ),
                          ),
                          SizedBox(height: 16),
                          _ReminderCard(
                            title: 'Mood Check-in',
                            subtitle: 'Set a daily reminder to log your mood',
                            icon: Icons.mood,
                            time: reminderProvider.moodReminderTime,
                            onTimeSelected: (time) => _handleTimeSelection(
                              context,
                              time,
                              reminderProvider.setMoodReminder,
                              'Mood',
                            ),
                          ),
                          SizedBox(height: 16),
                          _ReminderCard(
                            title: 'Focus Session',
                            subtitle:
                                'Set a daily reminder for your focus practice',
                            icon: Icons.psychology,
                            time: reminderProvider.focusReminderTime,
                            onTimeSelected: (time) => _handleTimeSelection(
                              context,
                              time,
                              reminderProvider.setFocusReminder,
                              'Focus',
                            ),
                          ),
                          SizedBox(height: 16),
                          _ReminderCard(
                            title: 'Daily Affirmation',
                            subtitle:
                                'Set a daily reminder to read your affirmations',
                            icon: Icons.auto_awesome,
                            time: reminderProvider.affirmationReminderTime,
                            onTimeSelected: (time) => _handleTimeSelection(
                              context,
                              time,
                              reminderProvider.setAffirmationReminder,
                              'Affirmation',
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTimeSelection(
    BuildContext context,
    TimeOfDay? time,
    Future<void> Function(TimeOfDay?) setReminder,
    String reminderType,
  ) async {
    try {
      await setReminder(time);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              time != null
                  ? '$reminderType reminder set for ${time.format(context)}'
                  : '$reminderType reminder removed',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set reminder. Please try again.'),
            backgroundColor: Colors.red.shade300,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

class _ReminderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final TimeOfDay? time;
  final Function(TimeOfDay?) onTimeSelected;

  const _ReminderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.time,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: time != null
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.textLight.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: time != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        time != null
                            ? 'Reminder set for ${time!.format(context)}'
                            : 'No reminder set',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: time != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: time ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor: AppColors.surface,
                                    hourMinuteTextColor: AppColors.textPrimary,
                                    dayPeriodTextColor: AppColors.textPrimary,
                                    dialHandColor: AppColors.primary,
                                    dialBackgroundColor: AppColors.background,
                                    dialTextColor: AppColors.textPrimary,
                                    entryModeIconColor: AppColors.primary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (selectedTime != null) {
                            onTimeSelected(selectedTime);
                          }
                        },
                        icon: Icon(
                          time != null ? Icons.edit : Icons.add_alarm,
                          size: 14,
                        ),
                        label: Text(
                          time != null ? 'Change' : 'Set Reminder',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      if (time != null) ...[
                        SizedBox(width: 6),
                        IconButton(
                          onPressed: () => onTimeSelected(null),
                          icon: Icon(Icons.close, size: 16),
                          color: AppColors.error,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
