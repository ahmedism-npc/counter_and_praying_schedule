import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../services/location_service.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _handleDetectLocation(PrayerProvider provider) async {
    final result = await provider.detectLocationAndFetchPrayerTime();
    if (!mounted) return;

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
            '${result.message}\n\nAnda dapat memilih kota yang tersedia di bawah secara manual.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mengerti'),
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

  void _showCityPicker(BuildContext context, PrayerProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      'Pilih Lokasi yang Tersedia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.availableCities.length,
                  itemBuilder: (context, index) {
                    final city = provider.availableCities[index];
                    final isSelected = provider.currentCity?.id == city.id &&
                        !provider.isGpsMode;

                    return ListTile(
                      leading: Icon(
                        Icons.place,
                        color: isSelected ? Colors.teal : Colors.grey,
                      ),
                      title: Text(
                        city.lokasi,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.teal : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.teal)
                          : null,
                      onTap: () {
                        provider.selectManualCity(city);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        centerTitle: true,
        actions: [
          Consumer<PrayerProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Perbarui Jadwal',
              onPressed: provider.isLoading ? null : () => provider.refresh(),
            ),
          ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, prayerProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Location Status Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: prayerProvider.isGpsMode
                                  ? Colors.green.shade100
                                  : Colors.teal.shade100,
                              child: Icon(
                                prayerProvider.isGpsMode
                                    ? Icons.gps_fixed
                                    : Icons.location_on,
                                color: prayerProvider.isGpsMode
                                    ? Colors.green.shade800
                                    : Colors.teal.shade800,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        prayerProvider.isGpsMode
                                            ? 'DETEKSI GPS OTOMATIS'
                                            : 'PILIHAN LOKASI MANUAL',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: prayerProvider.isGpsMode
                                              ? Colors.green.shade700
                                              : Colors.teal.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    prayerProvider.currentCity?.lokasi ??
                                        'Memuat lokasi...',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        // Action Buttons: Deteksi Otomatis & Pilih Manual
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: prayerProvider.isDetectingLocation
                                    ? null
                                    : () => _handleDetectLocation(
                                          prayerProvider,
                                        ),
                                icon: prayerProvider.isDetectingLocation
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.my_location, size: 18),
                                label: const Text(
                                  'Deteksi GPS',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: prayerProvider.isGpsMode
                                      ? Colors.green.shade700
                                      : Colors.grey.shade200,
                                  foregroundColor: prayerProvider.isGpsMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _showCityPicker(context, prayerProvider),
                                icon: const Icon(Icons.list, size: 18),
                                label: const Text(
                                  'Pilih Kota',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.teal.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Manual City Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'Cari kota lain (misal: Malang)...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          isDense: true,
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            prayerProvider.fetchPrayerTimeForCity(value.trim());
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_cityController.text.trim().isNotEmpty) {
                          prayerProvider
                              .fetchPrayerTimeForCity(_cityController.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Cari'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Prayer Schedule Content
                if (prayerProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (prayerProvider.errorMessage.isNotEmpty &&
                    prayerProvider.prayerTime == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            prayerProvider.errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (prayerProvider.prayerTime != null)
                  _buildScheduleList(prayerProvider)
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.0),
                    child: Center(child: Text('Belum ada data jadwal sholat.')),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleList(PrayerProvider provider) {
    final schedule = provider.prayerTime!;
    final city = provider.currentCity;

    return Column(
      children: [
        if (city != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      schedule.tanggal,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade900,
                      ),
                    ),
                  ],
                ),
                Text(
                  provider.isGpsMode ? 'GPS Aktif' : 'Manual',
                  style: TextStyle(
                    fontSize: 12,
                    color: provider.isGpsMode
                        ? Colors.green.shade700
                        : Colors.teal.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        _buildPrayerCard('Imsak', schedule.imsak, Icons.nightlight_outlined),
        _buildPrayerCard('Subuh', schedule.subuh, Icons.wb_twilight),
        _buildPrayerCard('Terbit', schedule.terbit, Icons.wb_sunny_outlined),
        _buildPrayerCard('Dhuha', schedule.dhuha, Icons.wb_sunny_outlined),
        _buildPrayerCard('Dzuhur', schedule.dzuhur, Icons.wb_sunny),
        _buildPrayerCard('Ashar', schedule.ashar, Icons.wb_cloudy_outlined),
        _buildPrayerCard('Maghrib', schedule.maghrib, Icons.brightness_4_outlined),
        _buildPrayerCard('Isya', schedule.isya, Icons.bedtime_outlined),
      ],
    );
  }

  Widget _buildPrayerCard(String name, String time, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
