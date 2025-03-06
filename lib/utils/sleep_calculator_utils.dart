import 'package:flutter/material.dart';

class SleepCalculatorUtils {
  static const sleepCycleDuration = Duration(minutes: 90);
  static const avgTimeToFallAsleep = Duration(minutes: 14);
  
  static List<DateTime> calculateSleepTimes(DateTime baseTime, bool isWakeTime) {
    final adjustedTime = baseTime.subtract(avgTimeToFallAsleep);
    
    return List.generate(6, (index) {
      final cycleCount = index + 4; // 4-9 دورات
      final duration = sleepCycleDuration * cycleCount;
      
      return isWakeTime
          ? adjustedTime.subtract(duration)
          : adjustedTime.add(duration);
    }).reversed.toList();
  }

  static double calculateSleepQuality(Duration sleepDuration) {
    final totalMinutes = sleepDuration.inMinutes;
    final cycles = totalMinutes / 90;
    
    if (cycles >= 5.5) return 1.0;      // ممتاز (8+ ساعات)
    if (cycles >= 5) return 0.9;        // جيد جداً
    if (cycles >= 4) return 0.7;        // جيد
    if (cycles >= 3) return 0.5;        // مقبول
    return 0.3;                         // غير كافي
  }

  static String getSleepQualityMessage(double quality) {
    if (quality >= 0.9) return 'نوم مثالي للصحة والنشاط 💪';
    if (quality >= 0.7) return 'نوم جيد للنشاط اليومي ⭐';
    if (quality >= 0.5) return 'نوم مقبول للراحة القصيرة 😊';
    return 'نوم قصير، قد تشعر بالتعب 😴';
  }
}
