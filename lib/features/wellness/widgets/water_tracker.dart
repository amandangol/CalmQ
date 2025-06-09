import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_theme.dart';
import '../providers/water_tracker_provider.dart';
import '../../reminders/providers/reminder_provider.dart';

class WaterTracker extends StatefulWidget {
  @override
  _WaterTrackerState createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  final List<double> _quickAddAmounts = [100, 200, 300, 500];

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterTrackerProvider>(
      builder: (context, provider, child) {
        return Container(
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
            children: [
              _buildHeader(),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildWaterProgress(provider),
                    SizedBox(height: 16),
                    _buildQuickAddButtons(provider),
                    SizedBox(height: 16),
                    _buildIntakeHistory(provider),
                    SizedBox(height: 16),
                    _buildReminderSettings(provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.water_drop, color: AppColors.info, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Intake',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Stay hydrated, stay healthy',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.info),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterProgress(WaterTrackerProvider provider) {
    final todayTotal = provider.getTodayTotal();
    final progressPercentage = (todayTotal / provider.dailyGoal).clamp(
      0.0,
      1.0,
    );

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: progressPercentage,
                backgroundColor: AppColors.info.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                strokeWidth: 12,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$todayTotal',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ml',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Goal: ${provider.dailyGoal} ml',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.info, size: 16),
              onPressed: () => _showGoalEditDialog(context, provider),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddButtons(WaterTrackerProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _quickAddAmounts.map((amount) {
        return GestureDetector(
          onTap: () => provider.addWaterIntake(amount.toInt()),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Text(
              '+$amount ml',
              style: TextStyle(
                color: AppColors.info,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntakeHistory(WaterTrackerProvider provider) {
    final todayIntakes = provider.waterIntakes.where((intake) {
      final now = DateTime.now();
      final timestamp = intake['timestamp'] as DateTime;
      return timestamp.year == now.year &&
          timestamp.month == now.month &&
          timestamp.day == now.day;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Intake',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        if (todayIntakes.isEmpty)
          Center(
            child: Text(
              'No intake recorded today',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          )
        else
          ...todayIntakes.map((intake) {
            final timestamp = intake['timestamp'] as DateTime;
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textLight.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color: AppColors.info,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${intake['amount']} ml',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () =>
                        provider.removeWaterIntake(intake['id'] as String),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildReminderSettings(WaterTrackerProvider provider) {
    final reminderProvider = context.watch<ReminderProvider>();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textLight.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reminders',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: reminderProvider.waterReminderStartTime != null,
                onChanged: (value) {
                  if (value) {
                    _showAddReminderDialog(context, reminderProvider);
                  } else {
                    reminderProvider.setWaterReminder(
                      startTime: null,
                      endTime: null,
                      interval: null,
                    );
                  }
                },
                activeColor: AppColors.info,
              ),
            ],
          ),
          if (reminderProvider.waterReminderStartTime != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: AppColors.info, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Active Hours',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${reminderProvider.waterReminderStartTime!.format(context)} - ${reminderProvider.waterReminderEndTime!.format(context)}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, color: AppColors.info, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Every ${reminderProvider.waterReminderInterval} minutes',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            TextButton.icon(
              onPressed: () =>
                  _showAddReminderDialog(context, reminderProvider),
              icon: Icon(Icons.edit, color: AppColors.info, size: 16),
              label: Text(
                'Change Reminder Settings',
                style: TextStyle(color: AppColors.info, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Water Tracker Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Daily Goal'),
              subtitle: Text(
                '${context.read<WaterTrackerProvider>().dailyGoal.toInt()} ml',
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showGoalEditDialog(
                  context,
                  context.read<WaterTrackerProvider>(),
                );
              },
            ),
            ListTile(
              title: Text('Reminders'),
              subtitle: Text('Manage water intake reminders'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showReminderSettingsDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showGoalEditDialog(
    BuildContext context,
    WaterTrackerProvider provider,
  ) {
    final controller = TextEditingController(
      text: provider.dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Daily Goal (ml)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final goal = int.tryParse(controller.text) ?? 2000;
              provider.updateDailyGoal(goal);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(
    BuildContext context,
    ReminderProvider reminderProvider,
  ) async {
    TimeOfDay startTime =
        reminderProvider.waterReminderStartTime ?? TimeOfDay.now();
    TimeOfDay endTime =
        reminderProvider.waterReminderEndTime ??
        TimeOfDay(hour: startTime.hour + 8, minute: startTime.minute);
    int interval = reminderProvider.waterReminderInterval;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Water Reminder Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Start Time'),
              subtitle: Text(startTime.format(context)),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (picked != null) {
                  startTime = picked;
                  (context as Element).markNeedsBuild();
                }
              },
            ),
            ListTile(
              title: Text('End Time'),
              subtitle: Text(endTime.format(context)),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: endTime,
                );
                if (picked != null) {
                  endTime = picked;
                  (context as Element).markNeedsBuild();
                }
              },
            ),
            ListTile(
              title: Text('Reminder Interval'),
              subtitle: Text('$interval minutes'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: interval > 15
                        ? () {
                            interval -= 15;
                            (context as Element).markNeedsBuild();
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: interval < 180
                        ? () {
                            interval += 15;
                            (context as Element).markNeedsBuild();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              reminderProvider.setWaterReminder(
                startTime: startTime,
                endTime: endTime,
                interval: interval,
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showReminderSettingsDialog(BuildContext context) {
    final reminderProvider = context.read<ReminderProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reminder Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Enable Reminders'),
              value: reminderProvider.waterReminderStartTime != null,
              onChanged: (value) {
                if (value) {
                  Navigator.pop(context);
                  _showAddReminderDialog(context, reminderProvider);
                } else {
                  reminderProvider.setWaterReminder(
                    startTime: null,
                    endTime: null,
                    interval: null,
                  );
                  Navigator.pop(context);
                }
              },
            ),
            if (reminderProvider.waterReminderStartTime != null)
              ListTile(
                title: Text('Change Reminder Time'),
                trailing: Icon(Icons.edit),
                onTap: () {
                  Navigator.pop(context);
                  _showAddReminderDialog(context, reminderProvider);
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
