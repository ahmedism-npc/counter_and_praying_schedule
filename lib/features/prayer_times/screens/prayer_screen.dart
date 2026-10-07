import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        centerTitle: true,
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, prayerProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          hintText: 'Cari Kota (Contoh: Malang)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            prayerProvider.fetchPrayerTimeForCity(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        if (_cityController.text.isNotEmpty) {
                          prayerProvider.fetchPrayerTimeForCity(_cityController.text);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Content
                Expanded(
                  child: prayerProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : prayerProvider.errorMessage.isNotEmpty
                          ? Center(
                              child: Text(
                                prayerProvider.errorMessage,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : prayerProvider.prayerTime == null
                              ? const Center(child: Text('Belum ada data.'))
                              : _buildScheduleList(prayerProvider),
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

    return ListView(
      children: [
        if (city != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                Text(
                  city.lokasi,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  schedule.tanggal,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        _buildPrayerCard('Imsak', schedule.imsak),
        _buildPrayerCard('Subuh', schedule.subuh),
        _buildPrayerCard('Terbit', schedule.terbit),
        _buildPrayerCard('Dhuha', schedule.dhuha),
        _buildPrayerCard('Dzuhur', schedule.dzuhur),
        _buildPrayerCard('Ashar', schedule.ashar),
        _buildPrayerCard('Maghrib', schedule.maghrib),
        _buildPrayerCard('Isya', schedule.isya),
      ],
    );
  }

  Widget _buildPrayerCard(String name, String time) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(time, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
