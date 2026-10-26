import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_translations.dart';
import '../providers/settings_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../prayer_times/providers/prayer_provider.dart';

class SettingsScreen extends StatelessWidget {
  final bool showAppBar;

  const SettingsScreen({super.key, this.showAppBar = true});

  void _showThemeDialog(BuildContext context, SettingsProvider provider) {
    final lang = provider.languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang == 'en' ? 'Select Theme' : 'Pilih Tema Tampilan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              title: lang == 'en' ? 'System Default' : 'Ikuti Pengaturan Sistem',
              isSelected: provider.themeMode == ThemeMode.system,
              onTap: () {
                provider.setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            _buildDialogOption(
              title: lang == 'en' ? 'Light Mode' : 'Mode Terang (Light)',
              isSelected: provider.themeMode == ThemeMode.light,
              onTap: () {
                provider.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            _buildDialogOption(
              title: lang == 'en' ? 'Dark Mode' : 'Mode Gelap (Dark)',
              isSelected: provider.themeMode == ThemeMode.dark,
              onTap: () {
                provider.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(provider.languageCode == 'en' ? 'Select Language' : 'Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              title: 'Bahasa Indonesia (ID)',
              isSelected: provider.languageCode == 'id',
              onTap: () {
                provider.setLanguage('id');
                Navigator.pop(ctx);
              },
            ),
            _buildDialogOption(
              title: 'English (EN)',
              isSelected: provider.languageCode == 'en',
              onTap: () {
                provider.setLanguage('en');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDialogOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF0F766E) : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF0F766E))
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = settingsProvider.languageCode;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(AppTranslations.tr('settings', lang)),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Card Akun & Login (Paling Atas sesuai Acuan Gambar 4)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.teal.shade50,
                          backgroundImage: authProvider.photoUrl != null
                              ? NetworkImage(authProvider.photoUrl!)
                              : null,
                          child: authProvider.photoUrl == null
                              ? const Icon(Icons.person, size: 36, color: Color(0xFF0F766E))
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.isLoggedIn
                                    ? authProvider.displayName
                                    : AppTranslations.tr('login_account', lang),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                authProvider.isLoggedIn
                                    ? authProvider.email
                                    : (lang == 'en'
                                        ? 'Sync agenda with Google Calendar'
                                        : 'Sinkronisasikan agenda dengan Google Calendar'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!authProvider.isLoggedIn)
                          ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () => authProvider.signInWithGoogle(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Login'),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.red),
                            tooltip: lang == 'en' ? 'Sign out' : 'Keluar',
                            onPressed: () => authProvider.signOut(),
                          ),
                      ],
                    ),

                    // Tombol Sinkronisasi Google Calendar
                    if (authProvider.isLoggedIn) ...[
                      const Divider(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: authProvider.isSyncing
                              ? null
                              : () async {
                                  final pt = prayerProvider.prayerTime;
                                  final city = prayerProvider.currentCity?.lokasi ?? 'Kota Jakarta';
                                  if (pt != null) {
                                    await authProvider.syncToCalendar(
                                      cityName: city,
                                      prayerTime: pt,
                                      date: prayerProvider.selectedDate,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(lang == 'en'
                                            ? 'Prayer schedule not loaded yet.'
                                            : 'Jadwal sholat belum termuat.'),
                                      ),
                                    );
                                  }
                                },
                          icon: authProvider.isSyncing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.sync),
                          label: Text(AppTranslations.tr('sync_calendar', lang)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      if (authProvider.lastSyncMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          authProvider.lastSyncMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Kategori: Umum
            _buildSectionHeader(AppTranslations.tr('general', lang)),
            _buildSettingsTile(
              icon: Icons.dark_mode_outlined,
              title: AppTranslations.tr('appearance', lang),
              subtitle: settingsProvider.themeMode == ThemeMode.system
                  ? (lang == 'en' ? 'System Default' : 'Ikuti Sistem')
                  : settingsProvider.themeMode == ThemeMode.dark
                      ? (lang == 'en' ? 'Dark Mode' : 'Mode Gelap')
                      : (lang == 'en' ? 'Light Mode' : 'Mode Terang'),
              onTap: () => _showThemeDialog(context, settingsProvider),
            ),
            _buildSettingsTile(
              icon: Icons.language,
              title: AppTranslations.tr('language', lang),
              subtitle: settingsProvider.languageCode == 'id'
                  ? 'Bahasa Indonesia (ID)'
                  : 'English (EN)',
              onTap: () => _showLanguageDialog(context, settingsProvider),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration, color: Color(0xFF0F766E)),
              title: Text(AppTranslations.tr('vibration', lang)),
              subtitle: Text(lang == 'en'
                  ? 'Haptic feedback on tasbih button tap'
                  : 'Getaran haptic pada tombol tasbih & penanda'),
              value: settingsProvider.isVibrationEnabled,
              activeThumbColor: const Color(0xFF0F766E),
              onChanged: (val) => settingsProvider.setVibrationEnabled(val),
            ),

            const Divider(height: 28),

            // Kategori: Ibadah
            _buildSectionHeader(AppTranslations.tr('worship', lang)),
            _buildSettingsTile(
              icon: Icons.schedule,
              title: lang == 'en' ? 'Location & Prayer Time Settings' : 'Lokasi dan Pengaturan Waktu Shalat',
              subtitle: prayerProvider.currentCity?.lokasi ?? 'KOTA JAKARTA',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang == 'en'
                        ? 'Change city via Prayer Times tab.'
                        : 'Ubah kota melalui tab Jadwal Sholat.'),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.notifications_active_outlined,
              title: lang == 'en' ? 'Prayer Time Notifications' : 'Notifikasi Waktu Shalat',
              subtitle: lang == 'en' ? 'Adhan reminder & audio alarm' : 'Pengingat adzan & suara waktu sholat',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang == 'en'
                        ? 'Prayer notification active.'
                        : 'Notifikasi sholat diaktifkan.'),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.calendar_month_outlined,
              title: lang == 'en' ? 'Hijri Calendar Settings' : 'Pengaturan Kalender Hijriah',
              subtitle: 'Metode hisab Umm Al-Qura / Falakiyah NU',
              onTap: () {},
            ),

            const Divider(height: 28),

            // Kategori: Tentang Aplikasi
            _buildSectionHeader(AppTranslations.tr('about', lang)),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: lang == 'en' ? 'App Version' : 'Versi Aplikasi',
              subtitle: 'Versi 2.0.0 (ITBS Mobile Project)',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.school_outlined,
              title: lang == 'en' ? 'Developer' : 'Pengembang',
              subtitle: 'Tugas Studi Kasus Pemrograman Mobile ITBS',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F766E),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0F766E)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
