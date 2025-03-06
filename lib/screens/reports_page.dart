import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/sleep_data.dart';
import '../providers/sleep_provider.dart';
import '../theme/app_theme.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: const Text('تقارير النوم'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'التقرير اليومي'),
            Tab(text: 'التقرير الأسبوعي'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: _DailyReportView(),
            ),
          ),
          Padding(  // تغيير هنا
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: _WeeklyReportView(),
          ),
        ],
      ),
    );
  }
}

class _DailyReportView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleepProvider, _) {
        if (sleepProvider.sleepHistory.isEmpty) {
          return _buildEmptyState(context);
        }

        final today = DateTime.now();
        final todayData = sleepProvider.sleepHistory
            .where((data) => 
              data.bedTime.year == today.year &&
              data.bedTime.month == today.month &&
              data.bedTime.day == today.day)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailySummaryCard(context, todayData),
            const SizedBox(height: 24),
            if (todayData.isNotEmpty) ...[
              Text(
                'جلسات النوم',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayData.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildSleepSessionCard(
                  context,
                  todayData[index],
                ),
              ),
              const SizedBox(height: 24),
            ],
            _buildSleepQualitySection(context, todayData),
          ],
        );
      },
    );
  }

  Widget _buildSleepSessionCard(BuildContext context, SleepData sleep) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeWidget(
                  context,
                  'وقت النوم',
                  sleep.bedTime,
                  Icons.bedtime_outlined,
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: colorScheme.primary,
                ),
                _buildTimeWidget(
                  context,
                  'وقت الاستيقاظ',
                  sleep.wakeTime,
                  Icons.wb_sunny_outlined,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricWidget(
                  context,
                  'مدة النوم',
                  sleep.formattedDuration,
                  Icons.access_time,
                ),
                _buildMetricWidget(
                  context,
                  'جودة النوم',
                  '${sleep.sleepQuality.round()}%',
                  Icons.star_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeWidget(
    BuildContext context,
    String label,
    DateTime time,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                _formatTime(time),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricWidget(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, List<SleepData> data) {
    final colorScheme = Theme.of(context).colorScheme;
    final todayTotal = data.isEmpty ? Duration.zero :
      data.map((e) => e.totalSleepDuration).reduce((a, b) => a + b);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ملخص اليوم',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${todayTotal.inHours}:${(todayTotal.inMinutes % 60).toString().padLeft(2, '0')} ساعة',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (data.isNotEmpty) ...[
              for (var sleep in data) ...[
                _buildSleepSession(context, sleep),
                const SizedBox(height: 12),
              ],
            ] else
              Center(
                child: Text(
                  'لم يتم تسجيل نوم اليوم',
                  style: TextStyle(
                    color: colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepSession(BuildContext context, SleepData sleep) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bedtime,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(sleep.bedTime),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward, size: 16),
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(sleep.wakeTime),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSleepMetric(
                context,
                'المدة',
                sleep.formattedDuration,
                Icons.access_time,
              ),
              _buildSleepMetric(
                context,
                'الجودة',
                '${sleep.sleepQuality.round()}%',
                Icons.star,
              ),
              _buildSleepMetric(
                context,
                'النوم العميق',
                '${sleep.deepSleepMinutes ~/ 60} ساعة',
                Icons.nightlight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepQualitySection(BuildContext context, List<SleepData> data) {
    if (data.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تحليل جودة النوم',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        for (var sleep in data)
          _buildQualityIndicator(context, sleep),
      ],
    );
  }

  Widget _buildQualityIndicator(BuildContext context, SleepData sleep) {
    final colorScheme = Theme.of(context).colorScheme;
    final quality = sleep.sleepQuality;
    final color = quality > 80 
        ? AppColors.success 
        : quality > 60 
            ? AppColors.warning 
            : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatTimeRange(sleep.bedTime, sleep.wakeTime)),
            Text(
              '${quality.round()}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: quality / 100,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSleepPhaseCard(BuildContext context, List<SleepData> data) {
    if (data.isEmpty) return const SizedBox();
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مراحل النوم',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (var sleep in data) ...[
              _buildPhaseChart(context, sleep),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseChart(BuildContext context, SleepData sleep) {
    final totalMinutes = sleep.totalSleepDuration.inMinutes;
    final deepSleepPercentage = sleep.deepSleepMinutes / totalMinutes;
    final lightSleepPercentage = sleep.lightSleepMinutes / totalMinutes;
    
    return Column(
      children: [
        Text(_formatTimeRange(sleep.bedTime, sleep.wakeTime)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 30,
              sections: [
                PieChartSectionData(
                  color: AppColors.primary,
                  value: deepSleepPercentage * 100,
                  title: 'عميق',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.secondary,
                  value: lightSleepPercentage * 100,
                  title: 'خفيف',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات نوم مسجلة',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل نومك لمشاهدة التقارير التفصيلية',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyReportView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleepProvider, _) {
        final weeklyData = _processWeeklyData(sleepProvider.sleepHistory);
        
        if (weeklyData.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(  // تغيير من ListView إلى Column
          children: [
            _buildWeeklySummaryCard(context, weeklyData),
            const SizedBox(height: 16),
            _buildWeeklyTrendCard(context, weeklyData),
            const SizedBox(height: 16),
            Expanded(  // إضافة Expanded لمؤشرات الجودة
              child: SingleChildScrollView(
                child: _buildWeeklyQualityCard(context, weeklyData),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _processWeeklyData(List<SleepData> history) {
    final weeklyData = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayData = history.where((data) =>
        data.bedTime.year == date.year &&
        data.bedTime.month == date.month &&
        data.bedTime.day == date.day).toList();
      
      if (dayData.isNotEmpty) {
        weeklyData.add({
          'date': date,
          'hours': dayData.map((d) => d.hours).reduce((a, b) => a + b) / dayData.length,
          'quality': dayData.map((d) => d.quality).reduce((a, b) => a + b) / dayData.length,
          'sessions': dayData.length,
        });
      }
    }
    
    return weeklyData;
  }

  Widget _buildWeeklySummaryCard(
    BuildContext context,
    List<Map<String, dynamic>> weeklyData
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final avgHours = weeklyData.map((d) => d['hours']).reduce((a, b) => a + b) / weeklyData.length;
    final avgQuality = weeklyData.map((d) => d['quality']).reduce((a, b) => a + b) / weeklyData.length;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'ملخص الأسبوع',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryMetric(
                  context,
                  'متوسط ساعات النوم',
                  '${avgHours.toStringAsFixed(1)} ساعة',
                  Icons.access_time,
                ),
                _buildSummaryMetric(
                  context,
                  'متوسط جودة النوم',
                  '${avgQuality.round()}%',
                  Icons.star,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrendCard(
    BuildContext context,
    List<Map<String, dynamic>> weeklyData
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اتجاه النوم الأسبوعي',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                _createWeeklyChart(context, weeklyData),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createWeeklyChart(
    BuildContext context,
    List<Map<String, dynamic>> weeklyData
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) => FlLine(
          color: colorScheme.outline.withOpacity(0.1),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= weeklyData.length) return const Text('');
              final date = weeklyData[value.toInt()]['date'] as DateTime;
              return Text(
                _getShortDayName(date.weekday),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            reservedSize: 28,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(weeklyData.length, (index) {
            return FlSpot(index.toDouble(), weeklyData[index]['hours']);
          }),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.5),
              colorScheme.primary,
            ],
          ),
          barWidth: 4,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 6,
              color: colorScheme.primary,
              strokeWidth: 2,
              strokeColor: colorScheme.surface,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withOpacity(0.2),
                colorScheme.primary.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyQualityCard(
    BuildContext context,
    List<Map<String, dynamic>> weeklyData
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,  // إضافة هذا السطر
          children: [
            Text(
              'جودة النوم الأسبوعية',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...weeklyData.map((day) => _buildDayQualityIndicator(context, day)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayQualityIndicator(BuildContext context, Map<String, dynamic> day) {
    final colorScheme = Theme.of(context).colorScheme;
    final quality = day['quality'] as double;
    final date = day['date'] as DateTime;
    final color = quality > 80 
        ? AppColors.success 
        : quality > 60 
            ? AppColors.warning 
            : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getFullDayName(date.weekday),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${quality.round()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: quality / 100,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getShortDayName(int weekday) {
    const days = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
    return days[weekday - 1];
  }

  String _getFullDayName(int weekday) {
    const days = [
      'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد'
    ];
    return days[weekday - 1];
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات أسبوعية',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل نومك لمدة أسبوع لرؤية التحليل الأسبوعي',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
