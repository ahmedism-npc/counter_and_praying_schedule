import 'package:flutter/material.dart';
import '../../../core/constants/city_data.dart';
import '../models/city.dart';
import '../models/prayer_time.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';

class PrayerProvider extends ChangeNotifier {
  final PrayerService _prayerService = PrayerService();
  final LocationService _locationService = LocationService();

  City? _currentCity;
  PrayerTime? _prayerTime;
  bool _isLoading = false;
  bool _isDetectingLocation = false;
  String _errorMessage = '';
  String _statusMessage = 'Lokasi Manual: KOTA JAKARTA';
  bool _isGpsMode = false;

  City? get currentCity => _currentCity;
  PrayerTime? get prayerTime => _prayerTime;
  bool get isLoading => _isLoading;
  bool get isDetectingLocation => _isDetectingLocation;
  String get errorMessage => _errorMessage;
  String get statusMessage => _statusMessage;
  bool get isGpsMode => _isGpsMode;
  List<City> get availableCities => CityData.popularCities;

  PrayerProvider() {
    // Set default city to Jakarta
    _currentCity = CityData.defaultCity;
    fetchPrayerTimeForCity(_currentCity!.lokasi, isManual: true);
  }

  /// Automatically detect location using device GPS (requires user permission)
  Future<LocationResult> detectLocationAndFetchPrayerTime() async {
    _isDetectingLocation = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _locationService.getCurrentLocation();

      if (result.status == LocationResultStatus.success && result.matchedCity != null) {
        _currentCity = result.matchedCity;
        _isGpsMode = true;
        _statusMessage = 'Lokasi Otomatis (GPS): ${_currentCity!.lokasi}';
        await _fetchPrayerTimesInternal(_currentCity!.id);
      } else {
        // Permission denied, service disabled, or error
        _errorMessage = result.message;
        _statusMessage = result.message;
      }
      return result;
    } catch (e) {
      _errorMessage = 'Gagal mendeteksi lokasi: $e';
      return LocationResult(
        status: LocationResultStatus.error,
        message: _errorMessage,
      );
    } finally {
      _isDetectingLocation = false;
      notifyListeners();
    }
  }

  /// Select a city manually from available city list
  Future<void> selectManualCity(City city) async {
    _currentCity = city;
    _isGpsMode = false;
    _statusMessage = 'Lokasi Manual: ${city.lokasi}';
    _errorMessage = '';
    notifyListeners();

    await _fetchPrayerTimesInternal(city.id);
  }

  /// Search city by name and fetch its prayer times
  Future<void> fetchPrayerTimeForCity(String cityName, {bool isManual = true}) async {
    _isLoading = true;
    _errorMessage = '';
    if (isManual) {
      _isGpsMode = false;
    }
    notifyListeners();

    try {
      final city = await _prayerService.searchCity(cityName);
      if (city != null) {
        _currentCity = city;
        _statusMessage = isManual
            ? 'Lokasi Manual: ${city.lokasi}'
            : 'Lokasi Otomatis: ${city.lokasi}';
        await _fetchPrayerTimesInternal(city.id);
      } else {
        _errorMessage = 'Kota "$cityName" tidak ditemukan dalam database.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPrayerTimesInternal(String cityId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final schedule = await _prayerService.getPrayerTime(cityId, DateTime.now());
      if (schedule != null) {
        _prayerTime = schedule;
      } else {
        _errorMessage = 'Jadwal sholat tidak ditemukan untuk tanggal hari ini.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh prayer times for the current city
  Future<void> refresh() async {
    if (_isGpsMode) {
      await detectLocationAndFetchPrayerTime();
    } else if (_currentCity != null) {
      await _fetchPrayerTimesInternal(_currentCity!.id);
    }
  }
}
