import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleep/widgets/custom_snackbar.dart';
import '../providers/sleep_provider.dart';
import '../theme/app_theme.dart';
import '../utils/sleep_calculator_utils.dart';
import '../widgets/help_dialog.dart';

class SleepCalculatorPage extends StatefulWidget {
  const SleepCalculatorPage({super.key});

  @override
  State<SleepCalculatorPage> createState() => _SleepCalculatorPageState();
}

class _SleepCalculatorPageState extends State<SleepCalculatorPage> {
  bool isCalculatingWakeTime = true;
  TimeOfDay selectedTime = TimeOfDay.now();
  final sleepCycleDuration = const Duration(minutes: 90); // دورة النوم 90 دقيقة

  List<_SleepCycle> calculateSleepTimes(TimeOfDay time) {
    final now = DateTime.now();
    final baseTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    final times = SleepCalculatorUtils.calculateSleepTimes(
      baseTime,
      isCalculatingWakeTime,
    );
    
    return times.map((time) {
      final cycleCount = SleepCalculatorUtils.calculateSleepQuality(
        isCalculatingWakeTime 
            ? baseTime.difference(time)
            : time.difference(baseTime),
      );
      
      return _SleepCycle(
        time: time,
        cycleCount: (cycleCount * 6).round(),
        quality: cycleCount,
        details: SleepCalculatorUtils.getSleepQualityMessage(cycleCount),
      );
    }).toList();
  }

  String _getCycleDetails(int cycles) {
    final hours = (cycles * 90 / 60).toStringAsFixed(1);
    switch (cycles) {
      case 6:
        return 'مثالي - $hours ساعات من النوم العميق 💪';
      case 5:
        return 'جيد جداً - $hours ساعات للنشاط اليومي ⭐';
      case 4:
        return 'مقبول - $hours ساعات للراحة القصيرة 😊';
      default:
        return '$hours ساعات من النوم 💤';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    int hour = time.hour;
    final period = hour >= 12 ? 'م' : 'ص';
    
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDateTime(DateTime dateTime) {
    int hour = dateTime.hour;
    final period = hour >= 12 ? 'م' : 'ص';
    
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final times = calculateSleepTimes(selectedTime);
    final sleepProvider = Provider.of<SleepProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: 'مساعدة',
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const HelpDialog(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isCalculatingWakeTime 
                    ? 'اختر وقت استيقاظك المفضل'
                    : 'اختر وقت نومك المفضل',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildTimeSelector(context),
                if (sleepProvider.selectedBedTime != null || 
                    sleepProvider.selectedWakeTime != null)
                  _buildSelectedTimesCard(context, sleepProvider),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        isCalculatingWakeTime 
                            ? 'أوقات النوم المناسبة للاستيقاظ في الوقت المحدد'
                            : 'أوقات الاستيقاظ المثالية إذا نمت في هذا الوقت',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isCalculatingWakeTime
                            ? 'اضغط على الوقت المناسب لك للنوم'
                            : 'اضغط على وقت الاستيقاظ المناسب لك',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                ...times.map((cycle) => _buildCycleCard(cycle)),
                _buildToggleButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTimesCard(BuildContext context, SleepProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الأوقات المحددة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (provider.selectedBedTime != null)
              Text('وقت النوم: ${_formatDateTime(provider.selectedBedTime!)}'),
            if (provider.selectedWakeTime != null)
              Text('وقت الاستيقاظ: ${_formatDateTime(provider.selectedWakeTime!)}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => provider.clearSelectedTimes(),
                  child: const Text('إلغاء'),
                ),
                if (provider.selectedBedTime != null && 
                    provider.selectedWakeTime != null)
                  ElevatedButton(
                    onPressed: () {
                      provider.confirmSelectedTime();
                      Navigator.pop(context);
                    },
                    child: const Text('تأكيد وحفظ'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'مساعدة',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const HelpDialog(),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          isCalculatingWakeTime ? 'متى تريد الاستيقاظ؟' : 'متى تريد النوم؟',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context) {
    final now = TimeOfDay.now();
    bool isCurrentTime = selectedTime.hour == now.hour && 
                        selectedTime.minute == now.minute;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            isCalculatingWakeTime
                ? 'في أي وقت تريد الاستيقاظ غداً؟'
                : 'في أي وقت تريد النوم الليلة؟',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // زر اختيار الوقت
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.surface,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => _selectTime(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCalculatingWakeTime ? Icons.wb_sunny : Icons.bedtime,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text(
                          _formatTimeOfDay(selectedTime),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCurrentTime ? 'الوقت الحالي' : 'اضغط للتغيير',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // أزرار الوقت السريعة
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              _buildQuickTimeButton(
                'الآن',
                Icons.schedule,
                () => _setTime(TimeOfDay.now()),
                isSelected: isCurrentTime,
              ),
              _buildQuickTimeButton(
                isCalculatingWakeTime ? '6:00 ص' : '10:00 م',
                isCalculatingWakeTime ? Icons.wb_sunny : Icons.bedtime,
                () => _setTime(TimeOfDay(
                  hour: isCalculatingWakeTime ? 6 : 22,
                  minute: 0,
                )),
                isSelected: selectedTime.hour == (isCalculatingWakeTime ? 6 : 22) && 
                           selectedTime.minute == 0,
              ),
              _buildQuickTimeButton(
                isCalculatingWakeTime ? '7:00 ص' : '11:00 م',
                isCalculatingWakeTime ? Icons.wb_sunny : Icons.bedtime,
                () => _setTime(TimeOfDay(
                  hour: isCalculatingWakeTime ? 7 : 23,
                  minute: 0,
                )),
                isSelected: selectedTime.hour == (isCalculatingWakeTime ? 7 : 23) && 
                           selectedTime.minute == 0,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isCalculatingWakeTime
                ? 'سنقترح عليك أفضل الأوقات للنوم لتستيقظ منتعشاً في الوقت المحدد'
                : 'سنقترح عليك أفضل الأوقات للاستيقاظ بناءً على وقت نومك',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTimeButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isSelected = false,
  }) {
    return Material(
      color: isSelected 
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setTime(TimeOfDay time) {
    setState(() => selectedTime = time);
  }

  Widget _buildCycleCard(_SleepCycle cycle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: _isTimeSelected(cycle.time) ? 4 : 1,
      child: InkWell(
        onTap: () => _handleCycleSelection(cycle),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: _isTimeSelected(cycle.time)
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getQualityColor(cycle.quality).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCalculatingWakeTime ? Icons.bedtime : Icons.wb_sunny,
                      color: _getQualityColor(cycle.quality),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatDateTime(cycle.time),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isTimeSelected(cycle.time)) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cycle.details,
                          style: TextStyle(
                            color: _getQualityColor(cycle.quality),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isCalculatingWakeTime
                              ? '${(cycle.cycleCount * 1.5).toStringAsFixed(1)} ساعات من النوم'
                              : 'تستيقظ بعد ${(cycle.cycleCount * 1.5).toStringAsFixed(1)} ساعات',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isTimeSelected(DateTime time) {
    final provider = Provider.of<SleepProvider>(context, listen: false);
    return isCalculatingWakeTime
        ? provider.selectedBedTime?.hour == time.hour && 
          provider.selectedBedTime?.minute == time.minute
        : provider.selectedWakeTime?.hour == time.hour && 
          provider.selectedWakeTime?.minute == time.minute;
  }

  void _handleCycleSelection(_SleepCycle cycle) {
    final provider = Provider.of<SleepProvider>(context, listen: false);
    
    if (isCalculatingWakeTime) {
      _showConfirmationDialog(
        cycle,
        isWakeTime: false,
        onConfirm: () {
          provider.setSelectedTimes(bedTime: cycle.time);
          CustomSnackBar.show(
            context,
            message: 'تم تحديد وقت النوم، يمكنك الآن تحديد وقت الاستيقاظ',
            isSuccess: true,
          );
          setState(() {
            isCalculatingWakeTime = false;
          });
        },
      );
    } else {
      if (provider.selectedBedTime == null) {
        CustomSnackBar.show(
          context,
          message: 'الرجاء اختيار وقت النوم أولاً',
          isSuccess: false,
        );
        return;
      }
      _showConfirmationDialog(
        cycle,
        isWakeTime: true,
        onConfirm: () {
          provider.setSelectedTimes(
            bedTime: provider.selectedBedTime,
            wakeTime: cycle.time,
          );
          provider.confirmSelectedTime();
          Navigator.pop(context);
          CustomSnackBar.show(
            context,
            message: 'تم حفظ أوقات النوم بنجاح',
            isSuccess: true,
          );
        },
      );
    }
  }

  Future<void> _showConfirmationDialog(
    _SleepCycle cycle, {
    required bool isWakeTime,
    required VoidCallback onConfirm,
  }) async {
    final provider = Provider.of<SleepProvider>(context, listen: false);
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // منع الإغلاق عند الضغط خارج مربع الحوار
      builder: (context) => AlertDialog(
        title: Text(
          isWakeTime ? 'تأكيد وقت الاستيقاظ' : 'تأكيد وقت النوم',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isWakeTime 
                ? 'هل تريد الاستيقاظ في هذا الوقت؟'
                : 'هل تريد النوم في هذا الوقت؟'
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isWakeTime ? Icons.wb_sunny : Icons.bedtime,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateTime(cycle.time),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(cycle.details),
                    ],
                  ),
                ],
              ),
            ),
            if (isWakeTime && provider.selectedBedTime != null) ...[
              const SizedBox(height: 16),
              Text(
                'وقت النوم: ${_formatDateTime(provider.selectedBedTime!)}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'مدة النوم المتوقعة: ${cycle.cycleCount * 1.5} ساعات',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!isWakeTime) {
                provider.clearSelectedTimes();
              }
              Navigator.pop(context, false);
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              onConfirm();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (result != true && !isWakeTime) {
      provider.clearSelectedTimes();
    }
  }

  Widget _buildToggleButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          setState(() {
            isCalculatingWakeTime = !isCalculatingWakeTime;
          });
        },
        icon: Icon(isCalculatingWakeTime ? Icons.bedtime : Icons.wb_sunny),
        label: Text(
          isCalculatingWakeTime
              ? 'تبديل إلى تحديد وقت النوم أولاً'
              : 'تبديل إلى تحديد وقت الاستيقاظ أولاً',
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Color _getQualityColor(double quality) {
    if (quality > 0.8) return AppColors.success;
    if (quality > 0.5) return AppColors.warning;
    return AppColors.error;
  }
}

class _SleepCycle {
  final DateTime time;
  final int cycleCount;
  final double quality;
  final String details;

  _SleepCycle({
    required this.time,
    required this.cycleCount,
    required this.quality,
    required this.details,
  });
}
