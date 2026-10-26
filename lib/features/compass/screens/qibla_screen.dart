import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../../prayer_times/providers/prayer_provider.dart';

class QiblaScreen extends StatefulWidget {
  final bool showAppBar;

  const QiblaScreen({super.key, this.showAppBar = true});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _deviceHeading = 0.0;
  bool _hasCompassSensor = true;

  @override
  void initState() {
    super.initState();
    _initCompass();
  }

  void _initCompass() {
    try {
      FlutterCompass.events?.listen((CompassEvent event) {
        if (mounted) {
          setState(() {
            _deviceHeading = event.heading;
            _hasCompassSensor = event.heading != null;
          });
        }
      }, onError: (_) {
        if (mounted) {
          setState(() {
            _hasCompassSensor = false;
          });
        }
      });
    } catch (_) {
      _hasCompassSensor = false;
    }
  }

  /// Menghitung sudut arah kiblat (Great-Circle bearing) dari koordinat pengguna ke Ka'bah (Makkah)
  double _calculateQibla(double lat, double lon) {
    const kaabaLat = 21.422487 * (pi / 180.0);
    const kaabaLon = 39.826206 * (pi / 180.0);
    final userLat = lat * (pi / 180.0);
    final userLon = lon * (pi / 180.0);

    final dLon = kaabaLon - userLon;
    final y = sin(dLon) * cos(kaabaLat);
    final x = cos(userLat) * sin(kaabaLat) - sin(userLat) * cos(kaabaLat) * cos(dLon);

    final qibla = atan2(y, x) * (180.0 / pi);
    return (qibla + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentCity = prayerProvider.currentCity;
    final userLat = currentCity?.latitude ?? -7.9797;
    final userLon = currentCity?.longitude ?? 112.6304;
    final qiblaAngle = _calculateQibla(userLat, userLon);

    final heading = _deviceHeading ?? 0.0;
    // Piringan kompas berputar berlawanan arah hadap perangkat (-heading)
    // Jarum kiblat mengarah ke (qiblaAngle - heading)
    final qiblaNeedleRotation = (qiblaAngle - heading) * (pi / 180.0);
    final compassDialRotation = -heading * (pi / 180.0);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Arah Kiblat'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Panduan Kalibrasi',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.explore, color: Color(0xFF0F766E)),
                            SizedBox(width: 8),
                            Text('Kalibrasi Kompas'),
                          ],
                        ),
                        content: const Text(
                          'Untuk akurasi maksimal, jauhkan perangkat dari benda logam atau medan magnet dan gerakkan ponsel Anda membentuk angka 8 di udara.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Lokasi dengan Red Pin (sesuai acuan desain)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      currentCity?.lokasi ?? 'Lokasi Terdeteksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Derajat Sudut Kiblat dari Utara',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${qiblaAngle.toStringAsFixed(2)}°',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F766E),
                  letterSpacing: 0.5,
                ),
              ),

              if (!_hasCompassSensor)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Mode simulasi: Sensor kompas fisik tidak terdeteksi pada emulator.',
                    style: TextStyle(fontSize: 11, color: Colors.brown),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 30),

              // Visual Dial Kompas Interaktif
              SizedBox(
                width: 290,
                height: 290,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lingkaran Luar & Piringan Mata Angin (B, U, T, S)
                    Transform.rotate(
                      angle: compassDialRotation,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.grey.shade900 : Colors.white,
                          border: Border.all(
                            color: const Color(0xFF0F766E).withValues(alpha: 0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Garis & Titik Derajat
                            ...List.generate(24, (i) {
                              final rad = (i * 15) * (pi / 180.0);
                              final isMajor = i % 6 == 0;
                              return Transform.rotate(
                                angle: rad,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: isMajor ? 3 : 1.5,
                                    height: isMajor ? 12 : 6,
                                    color: isMajor ? const Color(0xFF0F766E) : Colors.grey.shade400,
                                  ),
                                ),
                              );
                            }),

                            // Tanda Arah Mata Angin
                            const Positioned(
                              top: 24,
                              child: Text(
                                'U',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                            ),
                            const Positioned(
                              right: 24,
                              child: Text(
                                'T',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 24,
                              child: Text(
                                'S',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 24,
                              child: Text(
                                'B',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            // Ornamen Mandala Islami di Tengah
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.teal.shade50.withValues(alpha: 0.6),
                                border: Border.all(
                                  color: Colors.teal.shade200,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.brightness_high,
                                size: 54,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Jarum Penunjuk Kiblat (Ka'bah Indicator)
                    Transform.rotate(
                      angle: qiblaNeedleRotation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ikon Ka'bah di Ujung Jarum
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mosque,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          // Jarum Merah Penunjuk
                          Container(
                            width: 6,
                            height: 75,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                          // Pivot Tengah
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.redAccent, width: 3),
                            ),
                          ),
                          // Ekor Jarum Putih
                          Container(
                            width: 5,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              // Tombol Arahkan Kiblat dengan Kamera (sesuai acuan Gambar 3)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.camera_alt, color: Color(0xFF0F766E)),
                            SizedBox(width: 8),
                            Text('Mode Kamera AR'),
                          ],
                        ),
                        content: Text(
                          'Arah kiblat untuk wilayah ${currentCity?.lokasi ?? "Anda"} berada di ${qiblaAngle.toStringAsFixed(1)}° dari arah Utara. Posisikan kamera ponsel sejajar dengan garis horizontal.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Mengerti'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(
                    'Arahkan Kiblat dengan Kamera',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
