import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/prayer_provider.dart';
import '../services/location_service.dart';

class PrayerScreen extends StatefulWidget {
  final bool showAppBar;

  const PrayerScreen({super.key, this.showAppBar = true});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Timer? _countdownTimer;
  String _nextPrayerName = 'Isya';
  String _nextPrayerTime = '18:36';
  String _countdownString = '- 00 : 00 : 00';

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
    final pt = prayerProvider.prayerTime;
    if (pt == null) return;

    final now = DateTime.now();

    final prayers = [
      {'name': 'Subuh', 'time': pt.subuh},
      {'name': 'Zuhur', 'time': pt.dzuhur},
      {'name': 'Ashar', 'time': pt.ashar},
      {'name': 'Maghrib', 'time': pt.maghrib},
      {'name': 'Isya', 'time': pt.isya},
    ];

    Map<String, String>? nextPrayer;
    Duration? minDiff;

    for (final p in prayers) {
      final parts = p['time']!.split(':');
      if (parts.length < 2) continue;
      final hour = int.tryParse(parts[0]) ?? 0;
      final min = int.tryParse(parts[1]) ?? 0;

      var pDateTime = DateTime(now.year, now.month, now.day, hour, min);
      if (pDateTime.isBefore(now)) {
        pDateTime = pDateTime.add(const Duration(days: 1));
      }

      final diff = pDateTime.difference(now);
      if (minDiff == null || diff < minDiff) {
        minDiff = diff;
        nextPrayer = p;
      }
    }

    if (nextPrayer != null && minDiff != null) {
      final hours = minDiff.inHours.toString().padLeft(2, '0');
      final minutes = (minDiff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (minDiff.inSeconds % 60).toString().padLeft(2, '0');

      setState(() {
        _nextPrayerName = nextPrayer!['name']!;
        _nextPrayerTime = nextPrayer['time']!;
        _countdownString = '- $hours : $minutes : $seconds';
      });
    }
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
            '${result.message}\n\nAnda dapat memilih kota dari daftar kota manual.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.location_city, color: Color(0xFF0F766E)),
                        SizedBox(width: 8),
                        Text(
                          'Pilih Kota / Kabupaten',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari kota (misal: Malang, Bandung)...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: (query) {
                        if (query.trim().isNotEmpty) {
                          provider.fetchPrayerTimeForCity(query.trim());
                          Navigator.pop(ctx);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: provider.availableCities.length,
                      itemBuilder: (context, index) {
                        final city = provider.availableCities[index];
                        final isSelected = provider.currentCity?.id == city.id && !provider.isGpsMode;

                        return ListTile(
                          leading: Icon(
                            Icons.place,
                            color: isSelected ? const Color(0xFF0F766E) : Colors.grey,
                          ),
                          title: Text(
                            city.lokasi,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF0F766E) : null,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Color(0xFF0F766E))
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Jadwal Shalat'),
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
            )
          : null,
      body: Consumer<PrayerProvider>(
        builder: (context, prayerProvider, _) {
          final pt = prayerProvider.prayerTime;
          final currentCityName = prayerProvider.currentCity?.lokasi ?? 'Memuat lokasi...';
          final selectedHijri = HijriCalendar.fromDate(_selectedDate);

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Header Islami (Acuan Gambar 1)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF064E3B), Color(0xFF0F766E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Baris Lokasi dengan Red Pin
                      InkWell(
                        onTap: () => _showCityPicker(context, prayerProvider),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  currentCityName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Next Prayer Title
                      Text(
                        '$_nextPrayerName $_nextPrayerTime WIB',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Countdown Timer
                      Text(
                        _countdownString,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade100,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Update Lokasi / GPS (Shortcut Kiblat dihapus sesuai permintaan)
                      OutlinedButton.icon(
                        onPressed: prayerProvider.isDetectingLocation
                            ? null
                            : () => _handleDetectLocation(prayerProvider),
                        icon: prayerProvider.isDetectingLocation
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.sync, color: Colors.white, size: 16),
                        label: Text(
                          prayerProvider.isGpsMode ? 'GPS Terhubung' : 'Update GPS',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Date Switcher Card (Acuan Gambar 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            final newDate = _selectedDate.subtract(const Duration(days: 1));
                            setState(() {
                              _selectedDate = newDate;
                            });
                            prayerProvider.setSelectedDate(newDate);
                          },
                        ),
                        Column(
                          children: [
                            Text(
                              AppDateFormatter.formatDayMonthYear(_selectedDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${selectedHijri.hDay} ${selectedHijri.longMonthName} ${selectedHijri.hYear} H',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            final newDate = _selectedDate.add(const Duration(days: 1));
                            setState(() {
                              _selectedDate = newDate;
                            });
                            prayerProvider.setSelectedDate(newDate);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Daftar 8 Waktu Sholat (Acuan Gambar 1)
                if (prayerProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (pt != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildPrayerItem('Imsak', pt.imsak, Icons.nightlight_outlined, Icons.volume_off, false),
                        _buildPrayerItem('Subuh', pt.subuh, Icons.wb_twilight, Icons.volume_up, _nextPrayerName == 'Subuh'),
                        _buildPrayerItem('Terbit', pt.terbit, Icons.wb_sunny_outlined, Icons.notifications_none, false),
                        _buildPrayerItem('Dhuha', pt.dhuha, Icons.wb_sunny_outlined, Icons.notifications_none, false),
                        _buildPrayerItem('Zuhur', pt.dzuhur, Icons.wb_sunny, Icons.volume_up, _nextPrayerName == 'Zuhur'),
                        _buildPrayerItem('Ashar', pt.ashar, Icons.wb_cloudy_outlined, Icons.volume_up, _nextPrayerName == 'Ashar'),
                        _buildPrayerItem('Maghrib', pt.maghrib, Icons.brightness_4_outlined, Icons.volume_up, _nextPrayerName == 'Maghrib'),
                        _buildPrayerItem('Isya\'', pt.isya, Icons.bedtime_outlined, Icons.volume_up, _nextPrayerName == 'Isya'),
                      ],
                    ),
                  ),

                const SizedBox(height: 18),

                // Footer Validasi Waktu Sholat (Acuan Gambar 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        'Waktu Shalat telah ditashih oleh',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Lembaga Falakiyah Nahdlatul Ulama / Kemenag RI',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.check_circle, size: 14, color: Colors.teal.shade700),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerItem(String name, String time, IconData prayerIcon, IconData actionIcon, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F766E) : null,
        borderRadius: BorderRadius.circular(10),
        border: isActive ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            prayerIcon,
            size: 22,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : null,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : null,
            ),
          ),
          const SizedBox(width: 14),
          Icon(
            actionIcon,
            size: 18,
            color: isActive ? Colors.white : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
