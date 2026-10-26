class AppTranslations {
  static const Map<String, Map<String, String>> _values = {
    'id': {
      'prayer_times': 'Jadwal Shalat',
      'tasbih': 'Tasbih',
      'calendar': 'Kalender',
      'qibla': 'Kiblat',
      'settings': 'Pengaturan',
      'digital_tasbih': 'Tasbih Digital',
      'count_dhikr': 'Hitungan Tasbih / Dzikir',
      'qibla_angle': 'Derajat Sudut Kiblat dari Utara',
      'ar_camera': 'Arahkan Kiblat dengan Kamera',
      'login_account': 'Masuk ke Akunmu',
      'sync_calendar': 'Sinkronkan ke Google Calendar',
      'appearance': 'Tampilan',
      'language': 'Bahasa',
      'vibration': 'Efek Getar (Vibration)',
      'general': 'Umum',
      'worship': 'Ibadah',
      'about': 'Tentang Aplikasi',
    },
    'en': {
      'prayer_times': 'Prayer Times',
      'tasbih': 'Tasbih',
      'calendar': 'Calendar',
      'qibla': 'Qibla',
      'settings': 'Settings',
      'digital_tasbih': 'Digital Tasbih',
      'count_dhikr': 'Tasbih / Dhikr Count',
      'qibla_angle': 'Qibla Angle from North',
      'ar_camera': 'Find Qibla with Camera',
      'login_account': 'Sign in to Account',
      'sync_calendar': 'Sync to Google Calendar',
      'appearance': 'Appearance',
      'language': 'Language',
      'vibration': 'Haptic Vibration',
      'general': 'General',
      'worship': 'Worship',
      'about': 'About Application',
    },
  };

  static String tr(String key, String lang) {
    return _values[lang]?[key] ?? _values['id']?[key] ?? key;
  }
}
