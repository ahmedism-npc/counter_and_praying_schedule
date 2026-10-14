import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:counter_project/main.dart';
import 'package:counter_project/screens/home_screen.dart';

void main() {
  testWidgets('Memenuhi kriteria tugas: Tampilan Awal Studi Kasus & Nilai Tambah', (WidgetTester tester) async {
    // 1. Jalankan aplikasi
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // 2. Kriteria #5: Home adalah StatelessWidget terpisah
    expect(find.byType(HomeScreen), findsOneWidget);

    // 3. Kriteria #3: Scaffold + AppBar berjudul nama aplikasi
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Jadwal Sholat & Tasbih'), findsOneWidget);

    // 4. Kriteria #4: body: Center + Column berisi Icon, Text judul, dan Text deskripsi
    expect(find.byIcon(Icons.mosque), findsOneWidget);
    expect(find.text('Jadwal Sholat & Tasbih Digital'), findsOneWidget);

    // 5. Kriteria Nilai Tambah: StatefulWidget counter sederhana
    expect(find.byType(SimpleCounterSection), findsOneWidget);

    // Verifikasi counter mulai dari 0
    expect(find.text('0'), findsWidgets);

    // Verifikasi tombol tambah (+1)
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    expect(find.text('1'), findsWidgets);

    // Verifikasi tombol kurang (-1)
    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pump();
    expect(find.text('0'), findsWidgets);
  });
}
