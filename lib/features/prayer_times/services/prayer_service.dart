import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/city_data.dart';
import '../models/city.dart';
import '../models/prayer_time.dart';

class PrayerService {
  Future<City?> searchCity(String cityName) async {
    final query = cityName.trim();
    if (query.isEmpty) return null;

    // 1. Check local popular cities first for instantaneous match
    final upperQuery = query.toUpperCase();
    for (final city in CityData.popularCities) {
      if (city.lokasi == 'KOTA $upperQuery' ||
          city.lokasi == 'KAB. $upperQuery' ||
          city.lokasi == upperQuery) {
        return city;
      }
    }

    // 2. Fetch from remote API
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/sholat/kota/cari/$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true &&
            data['data'] != null &&
            (data['data'] as List).isNotEmpty) {
          final list = (data['data'] as List)
              .map((item) => City.fromJson(item as Map<String, dynamic>))
              .toList();

          // Prioritize exact word match over substring
          for (final c in list) {
            final words = c.lokasi.split(' ');
            if (words.contains(upperQuery)) {
              return c;
            }
          }
          return list.first;
        }
      }
    } catch (_) {
      // If remote search fails, fallback to substring match in popular cities
      for (final city in CityData.popularCities) {
        if (city.lokasi.contains(upperQuery)) {
          return city;
        }
      }
    }

    // Partial fallback in popular cities
    for (final city in CityData.popularCities) {
      if (city.lokasi.contains(upperQuery)) {
        return city;
      }
    }

    return null;
  }

  Future<PrayerTime?> getPrayerTime(String cityId, DateTime date) async {
    try {
      final year = date.year;
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/sholat/jadwal/$cityId/$year/$month/$day',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true &&
            data['data'] != null &&
            data['data']['jadwal'] != null) {
          return PrayerTime.fromJson(data['data']['jadwal']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil jadwal sholat: $e');
    }
  }
}
