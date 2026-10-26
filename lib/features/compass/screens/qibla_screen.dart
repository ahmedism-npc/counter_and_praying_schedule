import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../prayer_times/providers/prayer_provider.dart';

class QiblaScreen extends StatefulWidget {
  final bool showAppBar;
  final bool isActive;

  const QiblaScreen({super.key, this.showAppBar = true, this.isActive = true});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with WidgetsBindingObserver {
  StreamSubscription<CompassEvent>? _compassSubscription;
  final ValueNotifier<double?> _headingNotifier = ValueNotifier<double?>(0.0);
  bool _hasCompassSensor = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) {
      _startCompass();
    }
  }

  @override
  void didUpdateWidget(covariant QiblaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startCompass();
      } else {
        _stopCompass();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isActive) {
      _startCompass();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _stopCompass();
    }
  }

  void _startCompass() {
    if (_compassSubscription != null) return;
    try {
      _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
        if (mounted) {
          _headingNotifier.value = event.heading;
          final hasSensor = event.heading != null;
          if (_hasCompassSensor != hasSensor) {
            setState(() {
              _hasCompassSensor = hasSensor;
            });
          }
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

  void _stopCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCompass();
    _headingNotifier.dispose();
    super.dispose();
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
                            Icon(Icons.explore, color: AppColors.primary),
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
              // Hero Header Card Kiblat dengan Gradiasi Elegan & Sentuhan Emas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Badge Lokasi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              currentCity?.lokasi ?? 'Lokasi Terdeteksi',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Derajat Sudut Kiblat dari Utara',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${qiblaAngle.toStringAsFixed(1)}°',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mosque, size: 14, color: AppColors.goldLight),
                          SizedBox(width: 6),
                          Text(
                            'Arah Menghadap Ka\'bah (Makkah)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (!_hasCompassSensor) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Mode simulasi: Sensor kompas fisik tidak terdeteksi pada emulator.',
                    style: TextStyle(fontSize: 12, color: AppColors.goldDark, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Visual Dial Kompas Interaktif (Optimasi: Hanya Bagian Ini yang Rebuild dari Sensor Stream)
              ValueListenableBuilder<double?>(
                valueListenable: _headingNotifier,
                builder: (context, headingValue, _) {
                  final heading = headingValue ?? 0.0;
                  final qiblaNeedleRotation = (qiblaAngle - heading) * (pi / 180.0);
                  final compassDialRotation = -heading * (pi / 180.0);

                  return SizedBox(
                    width: 295,
                    height: 295,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cincin Luar Berpendar Halus (Glow effect)
                        Container(
                          width: 295,
                          height: 295,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.gold.withValues(alpha: isDark ? 0.2 : 0.15),
                                Colors.transparent,
                              ],
                              stops: const [0.75, 1.0],
                            ),
                          ),
                        ),
                        // Lingkaran Luar & Piringan Mata Angin (B, U, T, S)
                        Transform.rotate(
                          angle: compassDialRotation,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? AppColors.cardDark : Colors.white,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.primaryLight.withValues(alpha: 0.8)
                                    : AppColors.primary,
                                width: 3.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.18),
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
                                        color: isMajor ? AppColors.primary : Colors.grey.shade400,
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
                                      color: AppColors.primary,
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
                                    color: isDark
                                        ? AppColors.primaryDark.withValues(alpha: 0.5)
                                        : AppColors.surfaceLight,
                                    border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.6),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.brightness_high,
                                    size: 54,
                                    color: AppColors.gold,
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
                              // Ikon Ka'bah di Ujung Jarum dengan Efek Emas
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.goldDark,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.6),
                                      blurRadius: 10,
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
                  );
                },
              ),

              const SizedBox(height: 38),

              // Tombol Arahkan Kiblat dengan Kamera
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.camera_alt, color: AppColors.primary),
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
                    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.cardDark,
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
