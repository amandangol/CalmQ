import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ReminderProvider extends ChangeNotifier {
  static const String _journalReminderKey = 'journal_reminder_time';
  static const String _breathingReminderKey = 'breathing_reminder_time';
  static const String _moodReminderKey = 'mood_reminder_time';
  static const String _focusReminderKey = 'focus_reminder_time';
  static const String _affirmationReminderKey = 'affirmation_reminder_time';
  static const String _waterReminderStartKey = 'water_reminder_start_time';
  static const String _waterReminderEndKey = 'water_reminder_end_time';
  static const String _waterReminderIntervalKey = 'water_reminder_interval';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  TimeOfDay? _journalReminderTime;
  TimeOfDay? _breathingReminderTime;
  TimeOfDay? _moodReminderTime;
  TimeOfDay? _focusReminderTime;
  TimeOfDay? _affirmationReminderTime;
  TimeOfDay? _waterReminderStartTime;
  TimeOfDay? _waterReminderEndTime;
  int _waterReminderInterval = 60; // Default interval in minutes
  bool _isLoading = true;
  bool _hasPermission = false;

  TimeOfDay? get journalReminderTime => _journalReminderTime;
  TimeOfDay? get breathingReminderTime => _breathingReminderTime;
  TimeOfDay? get moodReminderTime => _moodReminderTime;
  TimeOfDay? get focusReminderTime => _focusReminderTime;
  TimeOfDay? get affirmationReminderTime => _affirmationReminderTime;
  TimeOfDay? get waterReminderStartTime => _waterReminderStartTime;
  TimeOfDay? get waterReminderEndTime => _waterReminderEndTime;
  int get waterReminderInterval => _waterReminderInterval;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;

  ReminderProvider() {
    initializeNotifications();
    _loadReminders();
  }

  Future<void> initializeNotifications() async {
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request notification permissions
      final androidPermission = await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      final iosPermission = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _hasPermission = androidPermission ?? iosPermission ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _hasPermission = false;
      notifyListeners();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _journalReminderTime = _loadTimeFromPrefs(prefs, _journalReminderKey);
      _breathingReminderTime = _loadTimeFromPrefs(prefs, _breathingReminderKey);
      _moodReminderTime = _loadTimeFromPrefs(prefs, _moodReminderKey);
      _focusReminderTime = _loadTimeFromPrefs(prefs, _focusReminderKey);
      _affirmationReminderTime = _loadTimeFromPrefs(
        prefs,
        _affirmationReminderKey,
      );
      _waterReminderStartTime = _loadTimeFromPrefs(
        prefs,
        _waterReminderStartKey,
      );
      _waterReminderEndTime = _loadTimeFromPrefs(prefs, _waterReminderEndKey);
      _waterReminderInterval = prefs.getInt(_waterReminderIntervalKey) ?? 60;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  TimeOfDay? _loadTimeFromPrefs(SharedPreferences prefs, String key) {
    try {
      final timeString = prefs.getString(key);
      if (timeString == null) return null;

      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      debugPrint('Error loading time from prefs: $e');
      return null;
    }
  }

  Future<void> _saveTimeToPrefs(TimeOfDay? time, String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (time == null) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, '${time.hour}:${time.minute}');
      }
    } catch (e) {
      debugPrint('Error saving time to prefs: $e');
      throw Exception('Failed to save reminder time');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    if (!_hasPermission) {
      throw Exception('Notification permission not granted');
    }

    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Cancel any existing notification with this ID first
      await _cancelNotification(id);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Reminders',
            channelDescription: 'Daily wellness reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableLights: true,
            enableVibration: true,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound(
              'notification_sound',
            ),
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'notification_sound.aiff',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: title,
      );

      // Verify the notification was scheduled
      final pendingNotifications = await _notifications
          .pendingNotificationRequests();
      final isScheduled = pendingNotifications.any(
        (notification) => notification.id == id,
      );

      if (!isScheduled) {
        throw Exception('Failed to verify notification schedule');
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      throw Exception('Failed to schedule notification');
    }
  }

  Future<void> _cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      // Verify the notification was cancelled
      final pendingNotifications = await _notifications
          .pendingNotificationRequests();
      final isStillScheduled = pendingNotifications.any(
        (notification) => notification.id == id,
      );

      if (isStillScheduled) {
        throw Exception('Failed to cancel notification');
      }
    } catch (e) {
      debugPrint('Error canceling notification: $e');
      throw Exception('Failed to cancel notification');
    }
  }

  Future<void> setJournalReminder(TimeOfDay? time) async {
    try {
      if (time != null) {
        await _scheduleNotification(
          id: 1,
          title: 'Journal Reminder',
          body: 'Time to write in your journal!',
          time: time,
        );
      } else {
        await _cancelNotification(1);
      }
      _journalReminderTime = time;
      await _saveTimeToPrefs(time, _journalReminderKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting journal reminder: $e');
      throw Exception('Failed to set journal reminder');
    }
  }

  Future<void> setBreathingReminder(TimeOfDay? time) async {
    try {
      if (time != null) {
        await _scheduleNotification(
          id: 2,
          title: 'Breathing Exercise',
          body: 'Take a moment to practice breathing exercises',
          time: time,
        );
      } else {
        await _cancelNotification(2);
      }
      _breathingReminderTime = time;
      await _saveTimeToPrefs(time, _breathingReminderKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting breathing reminder: $e');
      throw Exception('Failed to set breathing reminder');
    }
  }

  Future<void> setMoodReminder(TimeOfDay? time) async {
    try {
      if (time != null) {
        await _scheduleNotification(
          id: 3,
          title: 'Mood Check-in',
          body: 'How are you feeling today?',
          time: time,
        );
      } else {
        await _cancelNotification(3);
      }
      _moodReminderTime = time;
      await _saveTimeToPrefs(time, _moodReminderKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting mood reminder: $e');
      throw Exception('Failed to set mood reminder');
    }
  }

  Future<void> setFocusReminder(TimeOfDay? time) async {
    try {
      if (time != null) {
        await _scheduleNotification(
          id: 4,
          title: 'Focus Session',
          body: 'Time for your daily focus practice',
          time: time,
        );
      } else {
        await _cancelNotification(4);
      }
      _focusReminderTime = time;
      await _saveTimeToPrefs(time, _focusReminderKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting focus reminder: $e');
      throw Exception('Failed to set focus reminder');
    }
  }

  Future<void> setAffirmationReminder(TimeOfDay? time) async {
    try {
      if (time != null) {
        await _scheduleNotification(
          id: 5,
          title: 'Daily Affirmation',
          body: 'Read your daily affirmations',
          time: time,
        );
      } else {
        await _cancelNotification(5);
      }
      _affirmationReminderTime = time;
      await _saveTimeToPrefs(time, _affirmationReminderKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting affirmation reminder: $e');
      throw Exception('Failed to set affirmation reminder');
    }
  }

  Future<void> setWaterReminder({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? interval,
  }) async {
    try {
      // Cancel all existing water reminders
      await _cancelWaterReminders();

      if (startTime != null && endTime != null && interval != null) {
        _waterReminderStartTime = startTime;
        _waterReminderEndTime = endTime;
        _waterReminderInterval = interval;

        // Schedule reminders at intervals between start and end time
        final now = DateTime.now();
        var currentTime = DateTime(
          now.year,
          now.month,
          now.day,
          startTime.hour,
          startTime.minute,
        );
        final endDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          endTime.hour,
          endTime.minute,
        );

        int reminderId = 60; // Start from ID 60 for water reminders
        while (currentTime.isBefore(endDateTime)) {
          await _scheduleNotification(
            id: reminderId++,
            title: 'Water Reminder',
            body: 'Time to stay hydrated! Take a sip of water.',
            time: TimeOfDay.fromDateTime(currentTime),
          );
          currentTime = currentTime.add(Duration(minutes: interval));
        }
      } else {
        _waterReminderStartTime = null;
        _waterReminderEndTime = null;
        _waterReminderInterval = 60;
      }

      // Save settings
      final prefs = await SharedPreferences.getInstance();
      await _saveTimeToPrefs(_waterReminderStartTime, _waterReminderStartKey);
      await _saveTimeToPrefs(_waterReminderEndTime, _waterReminderEndKey);
      await prefs.setInt(_waterReminderIntervalKey, _waterReminderInterval);

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting water reminders: $e');
      throw Exception('Failed to set water reminders');
    }
  }

  Future<void> _cancelWaterReminders() async {
    try {
      // Cancel all water reminders (IDs 60-99)
      for (int i = 60; i < 100; i++) {
        await _cancelNotification(i);
      }
    } catch (e) {
      debugPrint('Error canceling water reminders: $e');
      throw Exception('Failed to cancel water reminders');
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
