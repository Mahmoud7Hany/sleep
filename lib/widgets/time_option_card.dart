import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../models/sleep_data.dart';

class TimeOptionCard extends StatelessWidget {
  final DateTime time;
  final double quality;
  final bool isWakeTime;

  const TimeOptionCard({
    super.key,
    required this.time,
    required this.quality,
    required this.isWakeTime,
  });

  String _getQualityMessage() {
    if (quality > 0.8) {
      return 'مثالي للحصول على نوم صحي 🟢';
    } else if (quality > 0.5) {
      return 'جيد ولكن قد تشعر بالتعب قليلاً 🟡';
    } else {
      return 'قد يؤثر على جودة نومك 🔴';
    }
  }

  Color _getQualityColor() {
    if (quality > 0.8) return Colors.green;
    if (quality > 0.5) return Colors.orange;
    return Colors.red;
  }

  String _formatTime() {
    int hour = time.hour;
    final period = hour >= 12 ? 'م' : 'ص';
    
    // تحويل إلى نظام 12 ساعة
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sleepData = SleepData(
      bedTime: isWakeTime ? time : now,
      wakeTime: isWakeTime ? now : time,
      sleepQuality: quality * 100,
      deepSleepMinutes: ((quality * 100) * 2.4).round(), // تقريبي
      lightSleepMinutes: ((quality * 100) * 3.6).round(), // تقريبي
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.read<SleepProvider>().selectSleepTime(sleepData);
          _showConfirmationDialog(context, sleepData);
        },
        child: ListTile(
          leading: Icon(
            isWakeTime ? Icons.wb_sunny : Icons.bedtime,
            color: _getQualityColor(),
          ),
          title: Text(
            _formatTime(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(_getQualityMessage()),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, SleepData sleepData) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isWakeTime ? 'تأكيد وقت النوم' : 'تأكيد وقت الاستيقاظ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد ${isWakeTime ? "النوم" : "الاستيقاظ"} في هذا الوقت؟'),
            const SizedBox(height: 8),
            Text(_formatTime()),
            Text(_getQualityMessage()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (isWakeTime) {
        context.read<SleepProvider>().setSelectedTimes(wakeTime: time);
      } else {
        context.read<SleepProvider>().setSelectedTimes(bedTime: time);
      }
      
      // التحقق من اكتمال الوقتين
      _checkAndConfirmSleepRecord(context);
    }
  }

  void _checkAndConfirmSleepRecord(BuildContext context) {
    final provider = context.read<SleepProvider>();
    if (provider.selectedBedTime != null && provider.selectedWakeTime != null) {
      provider.confirmSelectedTime();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل وقت النوم بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isWakeTime 
                ? 'الرجاء اختيار وقت النوم'
                : 'الرجاء اختيار وقت الاستيقاظ'
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
