import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../providers/sleep_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notifications_service.dart';
import '../providers/theme_provider.dart' as theme_provider;
import '../widgets/help_tooltip.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _formatTime(Duration duration) {
    int hour = duration.inHours;
    final period = hour >= 12 ? 'م' : 'ص';
    
    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }
    
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hour:$minutes $period';
  }

  Future<void> _launchDeveloperPage(BuildContext context) async {
    final Uri url = Uri.parse('https://mahmoud29hany.blogspot.com/');
    try {
      final canLaunch = await canLaunchUrl(url);
      if (canLaunch) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'لا يمكن فتح الرابط');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'حدث خطأ أثناء فتح الرابط');
      }
      debugPrint('Error launching URL: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, SettingsProvider settingsProvider) {
    return _buildSection(
      context,
      'المظهر',
      [
        _buildThemeSelector(context),
        Stack(
          children: [
            _buildSwitchItem(
              context,
              'الوضع المظلم تلقائياً',
              'تبديل المظهر حسب وقت اليوم',
              Icons.dark_mode_outlined,
              settingsProvider.autoDarkMode,
              (value) => settingsProvider.setAutoDarkMode(value),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: HelpTooltip(
                title: 'الوضع المظلم التلقائي',
                description: 'عند تفعيل هذه الخاصية، سيتم تغيير مظهر التطبيق تلقائياً بين الوضع الفاتح والداكن حسب وقت اليوم.',
                examples: [
                  'من 6 صباحاً حتى 7 مساءً: الوضع الفاتح',
                  'من 7 مساءً حتى 6 صباحاً: الوضع الداكن',
                  'يساعد على راحة العين في الأوقات المختلفة',
                ],
                icon: Icons.dark_mode_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Theme(
      data: Theme.of(context).copyWith(
        listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          subtitleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: isDark ? 179 : 153,
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            _buildThemeSection(context, settingsProvider),
            _buildSection(
              context,
              'التنبيهات',
              [
                _buildSwitchItem(
                  context,
                  'تنبيهات النوم',
                  'تذكير بموعد النوم',
                  Icons.notifications_active,
                  settingsProvider.sleepReminders,
                  (value) {
                    settingsProvider.setSleepReminders(value);
                    if (value) {
                      NotificationsService.requestPermission();
                    }
                  },
                ),
                _buildTimePickerItem(
                  context,
                  'وقت التذكير',
                  'تحديد وقت تذكير النوم',
                  Icons.alarm,
                  Duration(
                    hours: settingsProvider.bedtimeReminder.hour,
                    minutes: settingsProvider.bedtimeReminder.minute,
                  ),
                  (duration) {
                    settingsProvider.setBedtimeReminder(
                      TimeOfDay(
                        hour: duration.inHours,
                        minute: duration.inMinutes % 60,
                      ),
                    );
                    NotificationsService.scheduleBedtimeReminder(
                      settingsProvider.bedtimeReminder,
                    );
                  },
                ),
                _buildSwitchItem(
                  context,
                  'نصائح يومية',
                  'عرض نصيحة جديدة كل يوم',
                  Icons.tips_and_updates,
                  settingsProvider.dailyTips,
                  (value) => settingsProvider.setDailyTips(value),
                ),
              ],
            ),
            _buildSection(
              context,
              'تخصيص',
              [
                _buildSleepGoalItem(
                  context,
                  'هدف ساعات النوم',
                  'عدد ساعات النوم المثالية',
                  Icons.hourglass_empty,
                  settingsProvider.sleepGoal,
                  (duration) => settingsProvider.setSleepGoal(duration),
                ),
                _buildSwitchItem(
                  context,
                  'تتبع جودة النوم',
                  'تسجيل وتحليل جودة النوم',
                  Icons.monitor_heart,
                  settingsProvider.trackSleepQuality,
                  (value) => settingsProvider.setTrackSleepQuality(value),
                ),
              ],
            ),
            _buildSection(
              context,
              'البيانات',
              [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  title: const Text('مسح سجل النوم'),
                  subtitle: const Text('حذف جميع البيانات المسجلة'),
                  onTap: () => _showDeleteConfirmation(context),
                ),
             
              ],
            ),
            _buildSection(
              context,
              'حول التطبيق',
              [
                ListTile(
                  leading: Icon(Icons.info_outline, 
                    color: Theme.of(context).primaryColor),
                  title: const Text('إصدار التطبيق'),
                  subtitle: const Text('1.0.0'),
                ),
                ListTile(
                  leading: Icon(Icons.code, color: Theme.of(context).primaryColor),
                  title: const Text('المطور'),
                  subtitle: const Text('تطوير واجهات المستخدم'),
                  trailing: Icon(
                    Icons.open_in_new,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => _launchDeveloperPage(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeProvider = context.watch<theme_provider.ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.secondaryContainer,
                colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getThemeModeIcon(themeProvider.themeMode),
            color: colorScheme.onSecondaryContainer,
            size: 24,
          ),
        ),
        title: const Text(
          'مظهر التطبيق',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
        trailing: DropdownButton<ThemeMode>(
          value: themeProvider.themeMode,
          underline: const SizedBox(),
          items: _buildThemeModeItems(context),
          onChanged: (ThemeMode? mode) {
            if (mode != null) {
              themeProvider.toggleTheme();
            }
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<ThemeMode>> _buildThemeModeItems(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      DropdownMenuItem(
        value: ThemeMode.system,
        child: _buildDropdownItem(
          Icons.phone_android,
          'حسب النظام',
          colorScheme,
        ),
      ),
      DropdownMenuItem(
        value: ThemeMode.light,
        child: _buildDropdownItem(
          Icons.light_mode,
          'فاتح',
          colorScheme,
        ),
      ),
      DropdownMenuItem(
        value: ThemeMode.dark,
        child: _buildDropdownItem(
          Icons.dark_mode,
          'داكن',
          colorScheme,
        ),
      ),
    ];
  }

  Widget _buildDropdownItem(IconData icon, String label, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ],
    );
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.phone_android;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'يتبع إعدادات الجهاز';
      case ThemeMode.light:
        return 'الوضع الفاتح';
      case ThemeMode.dark:
        return 'الوضع الداكن';
    }
  }

  Widget _buildSwitchItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: value 
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: value ? LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.7),
                colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ) : null,
            color: value ? null : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: value ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colorScheme.onPrimary,
          activeTrackColor: colorScheme.primary,
          inactiveThumbColor: colorScheme.onSurfaceVariant,
          inactiveTrackColor: colorScheme.surfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTimePickerItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Duration initialDuration,
    ValueChanged<Duration> onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.alarm,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(initialDuration),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
          final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: initialDuration.inHours,
              minute: initialDuration.inMinutes % 60,
            ),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  timePickerTheme: TimePickerThemeData(
                    backgroundColor: colorScheme.surface,
                    hourMinuteShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    dayPeriodShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (time != null) {
            onChanged(Duration(hours: time.hour, minutes: time.minute));
          }
        },
      ),
    );
  }

  Widget _buildSleepGoalItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Duration initialDuration,
    ValueChanged<Duration> onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: colorScheme.onPrimaryContainer,
          size: 24,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.nightlight_round,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${initialDuration.inHours} ساعات',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
      onTap: () => _showSleepGoalPicker(context, initialDuration, onChanged),
    );
  }

  void _showSleepGoalPicker(
    BuildContext context,
    Duration initialDuration,
    ValueChanged<Duration> onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر هدف ساعات النوم',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [6, 7, 8, 9, 10].map((hours) {
                final isSelected = initialDuration.inHours == hours;
                return InkWell(
                  onTap: () {
                    onChanged(Duration(hours: hours));
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$hours ساعات',
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح سجل النوم'),
        content: const Text('هل أنت متأكد من حذف جميع البيانات المسجلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await sleepProvider.clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف جميع البيانات بنجاح'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
