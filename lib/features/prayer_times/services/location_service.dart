import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/city_data.dart';
import '../models/city.dart';

enum LocationResultStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationResult {
  final LocationResultStatus status;
  final Position? position;
  final String? detectedCityName;
  final City? matchedCity;
  final String message;

  LocationResult({
    required this.status,
    this.position,
    this.detectedCityName,
    this.matchedCity,
    required this.message,
  });
}

class LocationService {
  /// Request permission and detect current device location
  Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled on device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          status: LocationResultStatus.serviceDisabled,
          message:
              'Layanan GPS/lokasi perangkat belum aktif. Silakan aktifkan GPS atau pilih lokasi manual.',
        );
      }

      // 2. Check and request location permission from the user
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            status: LocationResultStatus.permissionDenied,
            message:
                'Izin lokasi ditolak oleh pengguna. Anda dapat memilih kota dari daftar manual.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          status: LocationResultStatus.permissionDeniedForever,
          message:
              'Izin lokasi ditolak secara permanen. Anda dapat mengaktifkannya di pengaturan atau memilih kota secara manual.',
        );
      }

      // 3. Permission granted, get current GPS position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // 4. Try reverse geocoding (placemark)
      String? detectedName;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          detectedName = place.subAdministrativeArea ??
              place.locality ??
              place.administrativeArea;
        }
      } catch (_) {
        // Geocoding might be unavailable on certain platforms (e.g. Windows) or offline
      }

      // 5. Clean up name if available, or find nearest city using coordinates
      City? matchedCity;
      if (detectedName != null && detectedName.isNotEmpty) {
        final clean = _cleanCityName(detectedName);
        matchedCity = _findCityByKeyword(clean);
      }

      // Fallback: calculate nearest city by latitude/longitude distance
      matchedCity ??= findNearestCity(position.latitude, position.longitude);

      return LocationResult(
        status: LocationResultStatus.success,
        position: position,
        detectedCityName: detectedName ?? matchedCity.lokasi,
        matchedCity: matchedCity,
        message: 'Lokasi berhasil terdeteksi: ${matchedCity.lokasi}',
      );
    } catch (e) {
      return LocationResult(
        status: LocationResultStatus.error,
        message: 'Gagal mendeteksi lokasi: $e. Anda dapat memilih kota secara manual.',
      );
    }
  }

  String _cleanCityName(String raw) {
    return raw
        .replaceAll(RegExp(r'Kota|Kabupaten|Kab\.|Kecamatan', caseSensitive: false), '')
        .trim();
  }

  City? _findCityByKeyword(String keyword) {
    final upper = keyword.toUpperCase();
    for (final city in CityData.popularCities) {
      if (city.lokasi.contains(upper)) {
        return city;
      }
    }
    return null;
  }

  /// Calculates nearest Indonesian city using Haversine formula
  City findNearestCity(double lat, double lng) {
    City closest = CityData.popularCities.first;
    double minDistance = double.infinity;

    for (final city in CityData.popularCities) {
      if (city.latitude != null && city.longitude != null) {
        final dist = _haversineDistance(lat, lng, city.latitude!, city.longitude!);
        if (dist < minDistance) {
          minDistance = dist;
          closest = city;
        }
      }
    }
    return closest;
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371; // Earth radius in km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);
}
