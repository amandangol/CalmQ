import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';

class RemindersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
              ],
            ),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time != null
                      ? 'Reminder set for ${time!.format(context)}'
                      : 'No reminder set',
                  style: TextStyle(
                    color: time != null ? Colors.blue : Colors.grey[600],
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: time ?? TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      onTimeSelected(selectedTime);
                    }
                  },
                  icon: Icon(
                    time != null ? Icons.edit : Icons.add_alarm,
                    size: 16,
                  ),
                  label: Text(time != null ? 'Change' : 'Set Reminder'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ],
            ),
            if (time != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => onTimeSelected(null),
                  child: Text('Remove Reminder'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
