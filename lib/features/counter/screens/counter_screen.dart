import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/counter_provider.dart';
import '../../settings/providers/settings_provider.dart';

class CounterScreen extends StatelessWidget {
  final bool showAppBar;

  const CounterScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Tasbih Digital'),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Label Islami dengan aksen Gold
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fingerprint,
                        size: 18,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hitungan Tasbih / Dzikir',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey.shade200 : AppColors.primaryDark,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Tampilan Lingkaran Counter Elegan dengan Gradiasi Satin & Aksen Emas
                Consumer<CounterProvider>(
                  builder: (context, counterProvider, child) {
                    final count = counterProvider.counter;
                    // Indikasi putaran 33 atau 99
                    final cycleCount = count > 0 ? ((count - 1) % 33) + 1 : 0;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cincin luar bercahaya halus (Glow effect)
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                (isDark ? AppColors.primaryLight : AppColors.primary)
                                    .withValues(alpha: 0.16),
                                Colors.transparent,
                              ],
                              stops: const [0.75, 1.0],
                            ),
                          ),
                        ),
                        // Lingkaran Utama Bergradasi
                        Container(
                          width: 224,
                          height: 224,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF13222C),
                                      const Color(0xFF09141B),
                                    ]
                                  : [
                                      Colors.white,
                                      const Color(0xFFF0FDF4),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.primaryLight.withValues(alpha: 0.8)
                                  : AppColors.primary,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? AppColors.primaryLight : AppColors.primary)
                                    .withValues(alpha: 0.22),
                                blurRadius: 26,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 82,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.primaryAccent
                                      : AppColors.primary,
                                  letterSpacing: -1,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Putaran: $cycleCount / 33',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.goldLight : AppColors.goldDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Tombol Kontrol: Kurang, Reset Langsung (Tanpa Dialog), Tambah
                Consumer<CounterProvider>(
                  builder: (context, counterProvider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tombol Kurang (-1)
                        IconButton.filledTonal(
                          onPressed: () {
                            if (counterProvider.counter > 0) {
                              settingsProvider.triggerHaptic();
                              counterProvider.decrement();
                            }
                          },
                          icon: const Icon(Icons.remove, size: 28),
                          tooltip: 'Kurangi (-1)',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: isDark
                                ? AppColors.cardDark
                                : Colors.teal.shade50,
                            foregroundColor: isDark
                                ? AppColors.primaryAccent
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Tombol Reset Langsung (Tanpa Konfirmasi Sesuai Permintaan)
                        IconButton.outlined(
                          onPressed: () {
                            settingsProvider.triggerHaptic();
                            counterProvider.reset();
                          },
                          icon: const Icon(Icons.refresh, size: 28, color: Colors.redAccent),
                          tooltip: 'Reset ke 0 (Langsung)',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Tombol Tambah Utama (+1) dengan Nuansa Hijau Zamrud Elegan
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.heroGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              settingsProvider.triggerHaptic();
                              counterProvider.increment();
                            },
                            icon: const Icon(Icons.add, size: 38, color: Colors.white),
                            tooltip: 'Tambah (+1)',
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(22),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
