import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sleep_data.dart';

class SleepProvider with ChangeNotifier {
  static const String _sleepHistoryKey = 'sleep_history';
  
  SleepData? _selectedSleepTime;
  List<SleepData> _sleepHistory = [];
  DateTime? _selectedBedTime;
  DateTime? _selectedWakeTime;

  SleepProvider() {
    _loadSavedData();
  }

  SleepData? get selectedSleepTime => _selectedSleepTime;
  List<SleepData> get sleepHistory => _sleepHistory;
  DateTime? get selectedBedTime => _selectedBedTime;
  DateTime? get selectedWakeTime => _selectedWakeTime;

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedHistory = prefs.getStringList(_sleepHistoryKey);
      
      if (savedHistory != null) {
        _sleepHistory = savedHistory.map((item) {
          final Map<String, dynamic> data = json.decode(item);
          return SleepData(
            bedTime: DateTime.parse(data['bedTime']),
            wakeTime: DateTime.parse(data['wakeTime']),
            sleepQuality: data['sleepQuality'].toDouble(),
            deepSleepMinutes: data['deepSleepMinutes'],
            lightSleepMinutes: data['lightSleepMinutes'],
          );
        }).toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading sleep data: $e');
    }
  }

  Future<void> _saveSleepHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _sleepHistory.map((item) => 
        json.encode(item.toJson())
      ).toList();
      
      await prefs.setStringList(_sleepHistoryKey, historyJson);
    } catch (e) {
      debugPrint('Error saving sleep data: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sleepHistoryKey);
      
      _sleepHistory.clear();
      _selectedBedTime = null;
      _selectedWakeTime = null;
      _selectedSleepTime = null;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing sleep data: $e');
    }
  }

  void selectSleepTime(SleepData sleepData) {
    _selectedSleepTime = sleepData;
    notifyListeners();
  }

  void addSleepRecord(SleepData sleepData) {
    _sleepHistory.add(sleepData);
    _saveSleepHistory(); // حفظ البيانات عند الإضافة
    notifyListeners();
  }

  void setSelectedTimes({DateTime? bedTime, DateTime? wakeTime}) {
    _selectedBedTime = bedTime;
    _selectedWakeTime = wakeTime;
    notifyListeners();
  }

  void confirmSelectedTime() {
    if (_selectedBedTime != null && _selectedWakeTime != null) {
      final sleepData = SleepData(
        bedTime: _selectedBedTime!,
        wakeTime: _selectedWakeTime!,
        sleepQuality: 85, // يمكن حسابها بناءً على مدة النوم
        deepSleepMinutes: 120, // تقريبي
        lightSleepMinutes: 240, // تقريبي
      );
      addSleepRecord(sleepData);
      _selectedBedTime = null;
      _selectedWakeTime = null;
      notifyListeners();
    }
  }

  void clearSelectedTimes() {
    _selectedBedTime = null;
    _selectedWakeTime = null;
    notifyListeners();
  }

  // حساب متوسط جودة النوم للأسبوع الحالي
  double getWeeklyAverageSleepQuality() {
    if (_sleepHistory.isEmpty) return 0;
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final weeklyRecords = _sleepHistory.where((record) => 
      record.bedTime.isAfter(weekStart));
    
    if (weeklyRecords.isEmpty) return 0;
    
    return weeklyRecords.map((e) => e.sleepQuality).reduce((a, b) => a + b) / 
           weeklyRecords.length;
  }

  // حساب متوسط ساعات النوم
  Duration getAverageSleepDuration() {
    if (_sleepHistory.isEmpty) return Duration.zero;
    
    final totalMinutes = _sleepHistory
        .map((record) => record.totalSleepDuration.inMinutes)
        .reduce((a, b) => a + b);
    
    return Duration(minutes: totalMinutes ~/ _sleepHistory.length);
  }
}
