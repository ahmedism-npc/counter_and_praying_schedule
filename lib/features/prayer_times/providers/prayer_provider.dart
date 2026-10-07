import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/prayer_time.dart';
import '../services/prayer_service.dart';

class PrayerProvider extends ChangeNotifier {
  final PrayerService _prayerService = PrayerService();
  
  City? _currentCity;
  PrayerTime? _prayerTime;
  bool _isLoading = false;
  String _errorMessage = '';

  City? get currentCity => _currentCity;
  PrayerTime? get prayerTime => _prayerTime;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Set default city to Jakarta
  PrayerProvider() {
    fetchPrayerTimeForCity('Jakarta');
  }

  Future<void> fetchPrayerTimeForCity(String cityName) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final city = await _prayerService.searchCity(cityName);
      if (city != null) {
        _currentCity = city;
        final schedule = await _prayerService.getPrayerTime(city.id, DateTime.now());
        if (schedule != null) {
          _prayerTime = schedule;
        } else {
          _errorMessage = 'Jadwal tidak ditemukan untuk hari ini.';
        }
      } else {
        _errorMessage = 'Kota tidak ditemukan.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
