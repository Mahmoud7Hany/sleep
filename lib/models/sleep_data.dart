class SleepData {
  final DateTime bedTime;
  final DateTime wakeTime;
  final double sleepQuality;
  final int deepSleepMinutes;
  final int lightSleepMinutes;

  SleepData({
    required this.bedTime,
    required this.wakeTime,
    required this.sleepQuality,
    required this.deepSleepMinutes,
    required this.lightSleepMinutes,
  });

  Duration get totalSleepDuration => wakeTime.difference(bedTime);
  
  // إضافة getters جديدة
  int get day => bedTime.day;
  double get hours => totalSleepDuration.inMinutes / 60.0;
  double get quality => sleepQuality;

  String get formattedDuration {
    final duration = totalSleepDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours == 0) {
      return '$minutes دقيقة';
    } else if (minutes == 0) {
      return '$hours ساعة';
    } else {
      String hourString = hours == 1 ? 'ساعة' : 'ساعات';
      return '$hours $hourString و $minutes دقيقة';
    }
  }

  String get shortDuration {
    final duration = totalSleepDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  double get exactHours => totalSleepDuration.inMinutes / 60;

  Map<String, dynamic> toJson() {
    return {
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'sleepQuality': sleepQuality,
      'deepSleepMinutes': deepSleepMinutes,
      'lightSleepMinutes': lightSleepMinutes,
    };
  }
}
