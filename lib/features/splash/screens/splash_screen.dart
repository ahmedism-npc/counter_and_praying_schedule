import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../screens/main_navigation_screen.dart';
import '../../prayer_times/providers/prayer_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  String _loadingMessage = 'Memuat preferensi aplikasi...';
  double _loadingProgress = 0.0;
  Timer? _progressTimer;
  Timer? _messageTimer;
  Timer? _secondMessageTimer;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();

    // 1. Animasi Masuk Logo (1200 ms)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );

    // 2. Animasi Denyut Halus Logo (Pulse Glow)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward().then((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });

    // 3. Status Progress Loading Bar selama 3 Detik (3000 ms)
    _startLoadingProcess();
  }

  void _startLoadingProcess() {
    const totalDurationMs = 3000;
    const intervalMs = 50;
    const steps = totalDurationMs ~/ intervalMs;
    int currentStep = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          _loadingProgress = (currentStep / steps).clamp(0.0, 1.0);
        });
      }
      if (currentStep >= steps) {
        timer.cancel();
      }
    });

    // Perubahan Pesan Loading Progresif
    _messageTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) {
        setState(() {
          _loadingMessage = 'Menyiapkan jadwal sholat & lokasi...';
        });
      }
    });

    _secondMessageTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _loadingMessage = 'Menyinkronkan kalender & kiblat...';
        });
      }
    });

    // 4. Background Data Preload & Transisi Tepat di Detik ke-3 (3000 ms)
    _preloadDataAndNavigate();
  }

  Future<void> _preloadDataAndNavigate() async {
    // Jalankan background preload data (Jadwal Sholat & Lokasi)
    try {
      final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
      if (prayerProvider.prayerTime == null) {
        prayerProvider.refresh();
      }
    } catch (_) {}

    // Transisi mulus ke MainNavigationScreen setelah 3 detik
    _navigateTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, animation, secondaryAnimation) =>
                const MainNavigationScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache gambar logo agar dirender instan tanpa jeda
    precacheImage(const AssetImage('assets/images/app_logo.png'), context);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    _secondMessageTimer?.cancel();
    _navigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Animasi Masuk dan Denyut Logo
              AnimatedBuilder(
                animation: Listenable.merge([_entryController, _pulseController]),
                builder: (context, child) {
                  final scale = _scaleAnimation.value * (_entryController.isCompleted ? _pulseAnimation.value : 1.0);
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.28),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                              blurRadius: 36,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Judul & Subtitle Aplikasi
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'Jadwal Sholat & Tasbih',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Aplikasi Ibadah Digital Terpadu',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal.shade100,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Loading Progress Bar & Status Text (Initial Loading Indicator)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Column(
                    children: [
                      // Progress Bar Halus
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 5,
                          child: LinearProgressIndicator(
                            value: _loadingProgress,
                            backgroundColor: Colors.teal.shade800,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF5EEAD4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Teks Status Loading
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _loadingMessage,
                          key: ValueKey<String>(_loadingMessage),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal.shade200,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
