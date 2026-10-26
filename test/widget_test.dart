import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:counter_project/main.dart';
import 'package:counter_project/screens/main_navigation_screen.dart';
import 'package:counter_project/features/splash/screens/splash_screen.dart';
import 'package:counter_project/features/counter/screens/counter_screen.dart';
import 'package:counter_project/features/calendar/screens/calendar_screen.dart';
import 'package:counter_project/features/compass/screens/qibla_screen.dart';

void main() {
  testWidgets('Verifikasi Splash Screen 3 Detik dan Transisi ke Navigasi Utama', (WidgetTester tester) async {
    // 1. Jalankan aplikasi dengan SplashScreen
    await tester.pumpWidget(const MyApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Jadwal Sholat & Tasbih'), findsOneWidget);

    // 2. Majukan waktu 3000ms untuk menyelesaikan timer splash loading
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // 3. Verifikasi transisi ke MainNavigationScreen
    expect(find.byType(MainNavigationScreen), findsOneWidget);

    // 4. Verifikasi 5 tab di BottomNavigationBar
    expect(find.text('Jadwal'), findsOneWidget);
    expect(find.text('Tasbih'), findsOneWidget);
    expect(find.text('Kalender'), findsOneWidget);
    expect(find.text('Kiblat'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('Verifikasi Fitur Counter Tasbih (Increment, Decrement, Reset Langsung Tanpa Dialog)', (WidgetTester tester) async {
    // Buka langsung MainNavigationScreen
    await tester.pumpWidget(const MyApp(initialHome: MainNavigationScreen()));
    await tester.pumpAndSettle();

    // Pindah ke Tab 2 (Tasbih)
    await tester.tap(find.text('Tasbih'));
    await tester.pumpAndSettle();

    expect(find.byType(CounterScreen), findsOneWidget);
    expect(find.text('Hitungan Tasbih / Dzikir'), findsOneWidget);

    // Hitungan awal adalah 0
    expect(find.text('0'), findsWidgets);

    // Tap tombol tambah (+1) dua kali
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    expect(find.text('2'), findsWidgets);

    // Tap tombol kurang (-1)
    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pump();
    expect(find.text('1'), findsWidgets);

    // Tap tombol reset langsung: harus langsung kembali ke 0 tanpa dialog konfirmasi
    await tester.tap(find.byIcon(Icons.refresh).first);
    await tester.pump();

    // Pastikan tidak ada dialog konfirmasi yang muncul
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Reset Hitungan?'), findsNothing);

    // Nilai counter langsung tereset menjadi 0
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('Verifikasi Tab Kalender (Masehi & Hijriah, Dummy Agenda, Import Google Cal)', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialHome: MainNavigationScreen()));
    await tester.pumpAndSettle();

    // Pindah ke Tab 3 (Kalender)
    await tester.tap(find.text('Kalender'));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(find.text('AHAD'), findsOneWidget);
    expect(find.text('JUMAT'), findsOneWidget);

    // Verifikasi bagian Agenda Pribadi & Kegiatan
    expect(find.text('Agenda Pribadi & Kegiatan'), findsOneWidget);
    expect(find.text('Import Google Cal'), findsOneWidget);
    expect(find.text('Tambah Agenda'), findsOneWidget);

    // Verifikasi keberadaan dummy agenda untuk akun demo
    expect(find.text('Kajian Bulanan ITBS: Fiqih Ibadah Praktis'), findsOneWidget);

    // Tap tombol Import Google Cal
    await tester.tap(find.text('Import Google Cal'));
    await tester.pumpAndSettle();

    // Pastikan muncul feedback SnackBar import
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Verifikasi Tambah Agenda Pribadi Melalui Bottom Sheet', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialHome: MainNavigationScreen()));
    await tester.pumpAndSettle();

    // Pindah ke Tab Kalender
    await tester.tap(find.text('Kalender'));
    await tester.pumpAndSettle();

    // Tap tombol FAB Tambah Agenda
    await tester.tap(find.text('Tambah Agenda'));
    await tester.pumpAndSettle();

    // Verifikasi BottomSheet muncul
    expect(find.text('Tambah Agenda Pribadi'), findsOneWidget);
    expect(find.text('Simpan Agenda'), findsOneWidget);

    // Ketik judul agenda
    await tester.enterText(
      find.byType(TextField).first,
      'Rapat Divisi ITBS Sukses',
    );
    await tester.pumpAndSettle();

    // Tap tombol Simpan Agenda
    await tester.tap(find.text('Simpan Agenda'));
    await tester.pumpAndSettle();

    // Bottom sheet tertutup tanpa error
    expect(find.text('Tambah Agenda Pribadi'), findsNothing);

    // Agenda baru muncul di daftar kegiatan
    expect(find.text('Rapat Divisi ITBS Sukses'), findsOneWidget);
  });

  testWidgets('Verifikasi Tab Kompas Kiblat', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialHome: MainNavigationScreen()));
    await tester.pumpAndSettle();

    // Pindah ke Tab 4 (Kiblat)
    await tester.tap(find.text('Kiblat'));
    await tester.pumpAndSettle();

    expect(find.byType(QiblaScreen), findsOneWidget);
    expect(find.text('Derajat Sudut Kiblat dari Utara'), findsOneWidget);
    expect(find.text('Arahkan Kiblat dengan Kamera'), findsOneWidget);
  });

  testWidgets('Verifikasi Tab Pengaturan & Status Login Google', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialHome: MainNavigationScreen()));
    await tester.pumpAndSettle();

    // Pindah ke Tab 5 (Pengaturan)
    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Akunmu'), findsOneWidget);
    expect(find.text('Tampilan'), findsOneWidget);
    expect(find.text('Bahasa'), findsOneWidget);
    expect(find.text('Efek Getar (Vibration)'), findsOneWidget);
  });
}
