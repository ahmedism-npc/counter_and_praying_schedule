import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/city.dart';
import '../models/prayer_time.dart';

class PrayerService {
  Future<City?> searchCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/sholat/kota/cari/$cityName'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null && (data['data'] as List).isNotEmpty) {
          // Return the first match
          return City.fromJson(data['data'][0]);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mencari kota: $e');
    }
  }

  Future<PrayerTime?> getPrayerTime(String cityId, DateTime date) async {
    try {
      final year = date.year;
      final month = date.month;
      final day = date.day;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/sholat/jadwal/$cityId/$year/$month/$day'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null && data['data']['jadwal'] != null) {
          return PrayerTime.fromJson(data['data']['jadwal']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil jadwal sholat: $e');
    }
  }
}
