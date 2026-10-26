import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keyVibration = 'settings_vibration';
  static const String _keyLanguage = 'settings_language';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isVibrationEnabled = true;
  String _languageCode = 'id'; // 'id' or 'en'

  ThemeMode get themeMode => _themeMode;
  bool get isVibrationEnabled => _isVibrationEnabled;
  String get languageCode => _languageCode;
  Locale get currentLocale => Locale(_languageCode);

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_keyThemeMode);
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      }

      final vib = prefs.getBool(_keyVibration);
      if (vib != null) {
        _isVibrationEnabled = vib;
      }

      final lang = prefs.getString(_keyLanguage);
      if (lang != null && (lang == 'id' || lang == 'en')) {
        _languageCode = lang;
      }

      notifyListeners();
    } catch (_) {
      // Fallback to defaults
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyThemeMode, mode.index);
    } catch (_) {}
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _isVibrationEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyVibration, enabled);
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    if (code == 'id' || code == 'en') {
      _languageCode = code;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyLanguage, code);
      } catch (_) {}
    }
  }

  /// Trigger haptic feedback if enabled in settings
  void triggerHaptic() {
    if (_isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void triggerSuccessHaptic() {
    if (_isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }
}
