import '../../features/prayer_times/models/city.dart';

class CityData {
  static final List<City> popularCities = [
    City(id: '1301', lokasi: 'KOTA JAKARTA', latitude: -6.2088, longitude: 106.8456),
    City(id: '1227', lokasi: 'KOTA BANDUNG', latitude: -6.9175, longitude: 107.6191),
    City(id: '1638', lokasi: 'KOTA SURABAYA', latitude: -7.2575, longitude: 112.7521),
    City(id: '1505', lokasi: 'KOTA YOGYAKARTA', latitude: -7.7956, longitude: 110.3695),
    City(id: '1433', lokasi: 'KOTA SEMARANG', latitude: -6.9667, longitude: 110.4167),
    City(id: '1634', lokasi: 'KOTA MALANG', latitude: -7.9797, longitude: 112.6304),
    City(id: '0228', lokasi: 'KOTA MEDAN', latitude: 3.5952, longitude: 98.6722),
    City(id: '2622', lokasi: 'KOTA MAKASSAR', latitude: -5.1477, longitude: 119.4327),
    City(id: '0816', lokasi: 'KOTA PALEMBANG', latitude: -2.9761, longitude: 104.7754),
    City(id: '1709', lokasi: 'KOTA DENPASAR', latitude: -8.6705, longitude: 115.2126),
    City(id: '0119', lokasi: 'KOTA BANDA ACEH', latitude: 5.5483, longitude: 95.3238),
    City(id: '2113', lokasi: 'KOTA BANJARMASIN', latitude: -3.3194, longitude: 114.5908),
    City(id: '2310', lokasi: 'KOTA SAMARINDA', latitude: -0.5022, longitude: 117.1536),
    City(id: '2308', lokasi: 'KOTA BALIKPAPAN', latitude: -1.2379, longitude: 116.8289),
    City(id: '1222', lokasi: 'KOTA BOGOR', latitude: -6.5971, longitude: 106.8060),
    City(id: '1225', lokasi: 'KOTA DEPOK', latitude: -6.4025, longitude: 106.7942),
    City(id: '1221', lokasi: 'KOTA BEKASI', latitude: -6.2383, longitude: 106.9756),
    City(id: '1434', lokasi: 'KOTA SURAKARTA', latitude: -7.5755, longitude: 110.8243),
    City(id: '1106', lokasi: 'KOTA SERANG', latitude: -6.1104, longitude: 106.1640),
    City(id: '1105', lokasi: 'KOTA TANGERANG', latitude: -6.1783, longitude: 106.6319),
  ];

  static City get defaultCity => popularCities.first; // Jakarta
}
