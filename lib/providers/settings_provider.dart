import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';  // إضافة هذا السطر

class SettingsProvider with ChangeNotifier {
  static const String _autoDarkModeKey = 'auto_dark_mode';
  static const String _sleepRemindersKey = 'sleep_reminders';
  static const String _dailyTipsKey = 'daily_tips';
  static const String _bedtimeReminderKey = 'bedtime_reminder';
  static const String _sleepGoalKey = 'sleep_goal';
  static const String _trackSleepQualityKey = 'track_sleep_quality';

  bool _autoDarkMode = false;
  bool _sleepReminders = true;
  bool _dailyTips = true;
  TimeOfDay _bedtimeReminder = const TimeOfDay(hour: 22, minute: 0);
  Duration _sleepGoal = const Duration(hours: 8);
  bool _trackSleepQuality = true;

  SettingsProvider() {
    _loadSettings();
  }

  // Getters
  bool get autoDarkMode => _autoDarkMode;
  bool get sleepReminders => _sleepReminders;
  bool get dailyTips => _dailyTips;
  TimeOfDay get bedtimeReminder => _bedtimeReminder;
  Duration get sleepGoal => _sleepGoal;
  bool get trackSleepQuality => _trackSleepQuality;

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _autoDarkMode = prefs.getBool(_autoDarkModeKey) ?? false;
      _sleepReminders = prefs.getBool(_sleepRemindersKey) ?? true;
      _dailyTips = prefs.getBool(_dailyTipsKey) ?? true;
      
      final reminderMinutes = prefs.getInt(_bedtimeReminderKey) ?? (22 * 60);
      _bedtimeReminder = TimeOfDay(
        hour: reminderMinutes ~/ 60,
        minute: reminderMinutes % 60,
      );
      
      _sleepGoal = Duration(minutes: prefs.getInt(_sleepGoalKey) ?? (8 * 60));
      _trackSleepQuality = prefs.getBool(_trackSleepQualityKey) ?? true;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_autoDarkModeKey, _autoDarkMode);
      await prefs.setBool(_sleepRemindersKey, _sleepReminders);
      await prefs.setBool(_dailyTipsKey, _dailyTips);
      await prefs.setInt(
        _bedtimeReminderKey,
        _bedtimeReminder.hour * 60 + _bedtimeReminder.minute,
      );
      await prefs.setInt(_sleepGoalKey, _sleepGoal.inMinutes);
      await prefs.setBool(_trackSleepQualityKey, _trackSleepQuality);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Setters with auto-save
  Future<void> setAutoDarkMode(bool value) async {
    _autoDarkMode = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSleepReminders(bool value) async {
    _sleepReminders = value;
    await _saveSettings();
    
    if (value) {
      // طلب الإذن وتفعيل الإشعارات
      final hasPermission = await NotificationService.requestPermission();
      if (hasPermission) {
        await NotificationService.scheduleBedtimeReminder(_bedtimeReminder);
        if (_dailyTips) {
          await NotificationService.scheduleDailyTip();
        }
      }
    } else {
      // إلغاء جميع الإشعارات
      await NotificationService.cancelAllNotifications();
    }
    
    notifyListeners();
  }

  Future<void> setDailyTips(bool value) async {
    _dailyTips = value;
    await _saveSettings();
    
    if (_sleepReminders) {
      if (value) {
        await NotificationService.scheduleDailyTip();
      } else {
        await NotificationService.cancelNotification(
          NotificationService.sleepTipNotificationId,
        );
      }
    }
    
    notifyListeners();
  }

  Future<void> setBedtimeReminder(TimeOfDay time) async {
    _bedtimeReminder = time;
    await _saveSettings();
    
    if (_sleepReminders) {
      await NotificationService.cancelNotification(
        NotificationService.bedtimeNotificationId,
      );
      await NotificationService.scheduleBedtimeReminder(time);
    }
    
    notifyListeners();
  }

  Future<void> setSleepGoal(Duration duration) async {
    _sleepGoal = duration;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setTrackSleepQuality(bool value) async {
    _trackSleepQuality = value;
    await _saveSettings();
    notifyListeners();
  }
}
