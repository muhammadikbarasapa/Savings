import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleDailyReminder() async {
    await _notifications.zonedSchedule(
      1,
      'Daily Reminder',
      'Jangan lupa catat transaksi hari ini!',
      _nextInstanceOfTime(21, 0), // 9 PM daily
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily reminder to log transactions',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleBudgetAlert(String budgetId, String category, double spent, double limit) async {
    final percentage = (spent / limit) * 100;
    
    if (percentage >= 90) {
      await _notifications.show(
        budgetId.hashCode,
        'Budget Alert: $category',
        'Anda telah menghabiskan ${percentage.toStringAsFixed(0)}% dari budget $category',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'budget_alerts',
            'Budget Alerts',
            channelDescription: 'Notifications for budget alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  Future<void> scheduleGoalReminder(String goalId, String title, int daysRemaining) async {
    if (daysRemaining <= 7 && daysRemaining > 0) {
      await _notifications.show(
        goalId.hashCode,
        'Goal Reminder: $title',
        'Tinggal $daysRemaining hari lagi untuk mencapai tujuan Anda!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'goal_reminders',
            'Goal Reminders',
            channelDescription: 'Notifications for savings goal reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
      );
    }
  }

  Future<void> scheduleMonthlyReport() async {
    await _notifications.zonedSchedule(
      2,
      'Monthly Report',
      'Lihat laporan keuangan bulanan Anda',
      _nextInstanceOfMonthly(1, 9, 0), // 1st of every month at 9 AM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'monthly_reports',
          'Monthly Reports',
          channelDescription: 'Monthly financial reports',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showWelcomeNotification() async {
    await _notifications.show(
      0,
      'Selamat Datang di SmartSaving Pro!',
      'Mulai catat keuangan Anda untuk kontrol yang lebih baik',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'welcome',
          'Welcome',
          channelDescription: 'Welcome notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showAchievementNotification(String title, String message) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.hashCode,
      title,
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'Achievement notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  // Helper methods
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfMonthly(int day, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(tz.local, now.year, now.month + 1, day, hour, minute);
    }
    
    return scheduledDate;
  }

  // Settings
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_settings', jsonEncode(settings));
  }

  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString('notification_settings');
    
    if (settingsString != null) {
      return Map<String, bool>.from(jsonDecode(settingsString));
    }
    
    return {
      'daily_reminders': true,
      'budget_alerts': true,
      'goal_reminders': true,
      'monthly_reports': true,
      'achievements': true,
    };
  }
}

