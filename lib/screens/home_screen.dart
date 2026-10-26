import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../features/counter/screens/counter_screen.dart';
import '../features/prayer_times/providers/prayer_provider.dart';
import '../features/prayer_times/screens/prayer_screen.dart';
import '../features/prayer_times/services/location_service.dart';

/// Halaman Home untuk aplikasi studi kasus (Kriteria Tugas #5: StatelessWidget terpisah)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kriteria Tugas #3: Scaffold + AppBar berjudul nama aplikasi
      appBar: AppBar(
        title: const Text('Jadwal Sholat & Tasbih'),
        centerTitle: true,
      ),
      // Kriteria Tugas #4: body: Center + Column berisi Icon, Text judul, dan Text deskripsi singkat
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Icon sesuai tema aplikasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mosque,
                  size: 72,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // 2. Text judul
              const Text(
                'Jadwal Sholat & Tasbih Digital',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Text deskripsi singkat
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Aplikasi pengingat jadwal sholat akurat dengan deteksi lokasi otomatis via GPS berizin pengguna atau pilihan daftar kota manual, dilengkapi counter tasbih digital.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kriteria Nilai Tambah: satu bagian StatefulWidget sederhana, misalnya counter
              const SimpleCounterSection(),

              const SizedBox(height: 16),

              // Card Status Jadwal Sholat & Lokasi
              const PrayerPreviewSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bagian StatefulWidget sederhana (Kriteria Nilai Tambah: Counter)
class SimpleCounterSection extends StatefulWidget {
  const SimpleCounterSection({super.key});

  @override
  State<SimpleCounterSection> createState() => _SimpleCounterSectionState();
}

class _SimpleCounterSectionState extends State<SimpleCounterSection> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  void _decrement() {
    if (_counter > 0) {
      setState(() {
        _counter--;
      });
    }
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.touch_app, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Counter Tasbih (Nilai Tambah)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CounterScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Layar Penuh >'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_counter',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: _decrement,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Kurang',
                ),
                const SizedBox(width: 16),
                IconButton.outlined(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  tooltip: 'Reset',
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: _increment,
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah (+1)',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bagian ringkasan Jadwal Sholat & Aksi Lokasi di Halaman Home
class PrayerPreviewSection extends StatelessWidget {
  const PrayerPreviewSection({super.key});

  void _handleDetectLocation(BuildContext context, PrayerProvider provider) async {
    final result = await provider.detectLocationAndFetchPrayerTime();
    if (!context.mounted) return;

    if (result.status == LocationResultStatus.permissionDenied ||
        result.status == LocationResultStatus.permissionDeniedForever ||
        result.status == LocationResultStatus.serviceDisabled) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('Izin Lokasi'),
            ],
          ),
          content: Text(
            '${result.message}\n\nAnda dapat memilih kota dari daftar kota yang tersedia secara manual.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Pilih Manual'),
            ),
          ],
        ),
      );
    } else if (result.status == LocationResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.teal.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerProvider>(
      builder: (context, provider, _) {
        final currentCity = provider.currentCity?.lokasi ?? 'KOTA JAKARTA';
        final isGps = provider.isGpsMode;
        final prayerTime = provider.prayerTime;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.access_time_filled,
                            color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Jadwal Sholat Hari Ini',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isGps
                            ? Colors.green.shade100
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isGps ? Icons.gps_fixed : Icons.location_on,
                            size: 13,
                            color: isGps
                                ? Colors.green.shade800
                                : Colors.teal.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isGps ? 'GPS' : 'Manual',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isGps
                                  ? Colors.green.shade800
                                  : Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Lokasi: $currentCity',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (prayerTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    prayerTime.tanggal,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // Ringkasan 4 waktu sholat terdekat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimeBadge('Subuh', prayerTime.subuh),
                      _buildTimeBadge('Dzuhur', prayerTime.dzuhur),
                      _buildTimeBadge('Ashar', prayerTime.ashar),
                      _buildTimeBadge('Maghrib', prayerTime.maghrib),
                      _buildTimeBadge('Isya', prayerTime.isya),
                    ],
                  ),
                ] else if (provider.isLoading) ...[
                  const SizedBox(height: 12),
                  const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: provider.isDetectingLocation
                            ? null
                            : () => _handleDetectLocation(context, provider),
                        icon: provider.isDetectingLocation
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location, size: 16),
                        label: const Text('Deteksi GPS'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrayerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_month, size: 16),
                        label: const Text('Jadwal Lengkap'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeBadge(String title, String time) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
