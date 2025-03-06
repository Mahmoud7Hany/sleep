import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart' as theme;
import 'theme/app_theme.dart';
import 'screens/home_page.dart';
import 'providers/sleep_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الإشعارات أولاً
  try {
    await NotificationsService.initialize();
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
  }
  
  // إنشاء وتهيئة مزود السمة
  final themeProvider = theme.ThemeProvider();
  while (!themeProvider.isInitialized) {
    await Future.delayed(const Duration(milliseconds: 50));
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<theme.ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<theme.ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', 'AE')],
          home: const HomePage(),
        );
      },
    );
  }
}
