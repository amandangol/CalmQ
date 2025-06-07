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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Reminders',
        leadingIcon: Icons.notifications_active_rounded,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            color: AppColors.surface,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Reminders',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Set reminders for your wellness activities',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.surface.withOpacity(0.9),
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
              SizedBox(height: 24),
              // Reminders List
              Expanded(
                child: ListView(
                  children: [
                    _ReminderCard(
                      title: 'Journal Reminder',
                      subtitle: 'Set a daily reminder to write in your journal',
                      icon: Icons.edit_note,
                      time: reminderProvider.journalReminderTime,
                      onTimeSelected: (time) =>
                          reminderProvider.setJournalReminder(time),
                    ),
                    SizedBox(height: 16),
                    _ReminderCard(
                      title: 'Breathing Exercise',
                      subtitle: 'Set a daily reminder for breathing exercises',
                      icon: Icons.air,
                      time: reminderProvider.breathingReminderTime,
                      onTimeSelected: (time) =>
                          reminderProvider.setBreathingReminder(time),
                    ),
                    SizedBox(height: 16),
                    _ReminderCard(
                      title: 'Mood Check-in',
                      subtitle: 'Set a daily reminder to log your mood',
                      icon: Icons.mood,
                      time: reminderProvider.moodReminderTime,
                      onTimeSelected: (time) =>
                          reminderProvider.setMoodReminder(time),
                    ),
                    SizedBox(height: 16),
                    _ReminderCard(
                      title: 'Focus Session',
                      subtitle: 'Set a daily reminder for your focus practice',
                      icon: Icons.psychology,
                      time: reminderProvider.focusReminderTime,
                      onTimeSelected: (time) =>
                          reminderProvider.setFocusReminder(time),
                    ),
                    SizedBox(height: 16),
                    _ReminderCard(
                      title: 'Daily Affirmation',
                      subtitle:
                          'Set a daily reminder to read your affirmations',
                      icon: Icons.auto_awesome,
                      time: reminderProvider.affirmationReminderTime,
                      onTimeSelected: (time) =>
                          reminderProvider.setAffirmationReminder(time),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
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
                        size: 18,
                        color: time != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        time != null
                            ? 'Reminder set for ${time!.format(context)}'
                            : 'No reminder set',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: time != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 13,
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
                          size: 16,
                        ),
                        label: Text(
                          time != null ? 'Change' : 'Set Reminder',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      if (time != null) ...[
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: () => onTimeSelected(null),
                          icon: Icon(Icons.close, size: 18),
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
