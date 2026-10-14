import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/counter/providers/counter_provider.dart';
import 'features/prayer_times/providers/prayer_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
      ],
      // Kriteria Tugas #2: MaterialApp dengan title dan theme warna sesuai tema aplikasi
      child: MaterialApp(
        title: 'Jadwal Sholat & Tasbih',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F766E),
            primary: const Color(0xFF0F766E),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F766E),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 2,
          ),
        ),
        // Kriteria Tugas #5: Home dibuat sebagai StatelessWidget terpisah (bukan langsung di main)
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
