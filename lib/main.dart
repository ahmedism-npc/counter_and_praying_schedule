import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/counter/providers/counter_provider.dart';
import 'features/prayer_times/providers/prayer_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final Widget? initialHome;

  const MyApp({super.key, this.initialHome});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Jadwal Sholat & Tasbih',
            themeMode: settingsProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0F766E),
                primary: const Color(0xFF0F766E),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0F766E),
                foregroundColor: Colors.white,
                centerTitle: true,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0F766E),
                primary: const Color(0xFF0F766E),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0F172A),
                foregroundColor: Colors.white,
                centerTitle: true,
                elevation: 0,
              ),
            ),
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              overscroll: false,
              physics: const ClampingScrollPhysics(),
            ),
            home: initialHome ?? const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
