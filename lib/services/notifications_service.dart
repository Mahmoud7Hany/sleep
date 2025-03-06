import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    
    await _notifications.initialize(initSettings);
  }

  static Future<void> scheduleBedtimeReminder(TimeOfDay bedtime) async {
    if (!await requestPermission()) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      bedtime.hour,
      bedtime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0,
      'تذكير وقت النوم',
      'حان وقت التحضير للنوم للحصول على راحة مثالية',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sleep_reminders',
          'تذكيرات النوم',
          channelDescription: 'تنبيهات بمواعيد النوم',
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

  static Future<void> showDailyTip(String tip) async {
    if (!await requestPermission()) return;

    await _notifications.show(
      1,
      'نصيحة النوم اليومية',
      tip,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_tips',
          'النصائح اليومية',
          channelDescription: 'نصائح يومية لتحسين النوم',
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
    );
  }

  static Future<bool> requestPermission() async {
    final platform = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      final result = await platform.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
