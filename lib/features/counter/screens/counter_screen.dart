import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';
import '../../settings/providers/settings_provider.dart';

class CounterScreen extends StatelessWidget {
  final bool showAppBar;

  const CounterScreen({super.key, this.showAppBar = true});

  void _showResetDialog(BuildContext context, CounterProvider counterProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.red),
            SizedBox(width: 8),
            Text('Reset Hitungan?'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin mengatur ulang hitungan tasbih menjadi 0?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              counterProvider.reset();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hitungan Tasbih / Dzikir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade300 : Colors.black54,
                ),
              ),
              const SizedBox(height: 28),

              // Tampilan Lingkaran Counter Besar Bersih
              Consumer<CounterProvider>(
                builder: (context, counterProvider, child) {
                  return Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.teal.shade900.withValues(alpha: 0.5) : Colors.teal.shade50,
                      border: Border.all(
                        color: const Color(0xFF0F766E),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${counterProvider.counter}',
                      style: TextStyle(
                        fontSize: 84,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.teal.shade200 : const Color(0xFF0F766E),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Tombol Kontrol: Kurang, Reset, Tambah
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
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Tombol Reset
                      IconButton.outlined(
                        onPressed: () => _showResetDialog(context, counterProvider),
                        icon: const Icon(Icons.refresh, size: 28, color: Colors.red),
                        tooltip: 'Reset ke 0',
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Tombol Tambah Utama (+1)
                      IconButton.filled(
                        onPressed: () {
                          settingsProvider.triggerHaptic();
                          counterProvider.increment();
                        },
                        icon: const Icon(Icons.add, size: 38),
                        tooltip: 'Tambah (+1)',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(22),
                          elevation: 4,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
