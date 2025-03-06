import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static const _channelId = 'sleep_channel';
  static const _channelName = 'Sleep Notifications';
  static const _channelDescription = 'Notifications for sleep tracking app';

  static const int bedtimeNotificationId = 1;
  static const int wakeUpNotificationId = 2;
  static const int sleepTipNotificationId = 3;
  static const int sleepQualityNotificationId = 4;

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // إنشاء قناة الإشعارات للأندرويد
    final androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _isInitialized = true;
  }

  static Future<bool> requestPermission() async {
    if (!_isInitialized) await initialize();
    
    final androidStatus = await Permission.notification.status;
    if (androidStatus.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return androidStatus.isGranted;
  }

  static NotificationDetails get _notificationDetails {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableLights: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  // دالة لإرسال إشعار فوري
  static Future<void> showNotification({
    required String title,
    required String body,
    required int id,
  }) async {
    if (!_isInitialized) await initialize();
    await _notifications.show(id, title, body, _notificationDetails);
  }

  // جدولة إشعار موعد النوم
  static Future<void> scheduleBedtimeReminder(TimeOfDay bedtime) async {
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
      bedtimeNotificationId,
      'حان موعد النوم! 😴',
      'للحصول على نوم صحي، حان الوقت للاستعداد للنوم',
      tz.TZDateTime.from(scheduledDate, tz.local),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // جدولة إشعار الاستيقاظ
  static Future<void> scheduleWakeUpReminder(TimeOfDay wakeTime) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      wakeTime.hour,
      wakeTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      wakeUpNotificationId,
      'صباح الخير! 🌅',
      'حان وقت الاستيقاظ للحصول على يوم نشيط',
      tz.TZDateTime.from(scheduledDate, tz.local),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // جدولة نصيحة يومية
  static Future<void> scheduleDailyTip() async {
    final tips = [
      'تجنب استخدام الهاتف قبل النوم بساعة',
      'حافظ على درجة حرارة غرفة النوم معتدلة',
      'مارس تمارين الاسترخاء قبل النوم',
      'تجنب الكافيين في المساء',
      'اجعل غرفة نومك هادئة ومظلمة',
    ];

    final randomTip = tips[DateTime.now().day % tips.length];
    final scheduledDate = DateTime.now().add(const Duration(days: 1))
        .copyWith(hour: 20, minute: 0);

    await _notifications.zonedSchedule(
      sleepTipNotificationId,
      'نصيحة للنوم الجيد 💡',
      randomTip,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // إلغاء إشعار محدد
  static Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await initialize();
    await _notifications.cancel(id);
  }

  // إلغاء جميع الإشعارات
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    await _notifications.cancelAll();
  }

  // معالجة الضغط على الإشعار
  static void _onNotificationTap(NotificationResponse response) {
    // يمكن إضافة منطق التنقل هنا بناءً على نوع الإشعار
    switch (response.id) {
      case bedtimeNotificationId:
        // التنقل إلى شاشة تسجيل النوم
        break;
      case wakeUpNotificationId:
        // التنقل إلى شاشة تسجيل الاستيقاظ
        break;
      case sleepTipNotificationId:
        // التنقل إلى شاشة النصائح
        break;
    }
  }
}
