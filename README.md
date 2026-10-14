# 🕌 Jadwal Sholat & Tasbih Digital

> **Aplikasi Mobile Flutter** — Tugas Tampilan Awal Studi Kasus Pemrograman Mobile.  
> Aplikasi penghitung dzikir/tasbih digital terintegrasi pengingat jadwal sholat harian akurat yang dilengkapi **deteksi lokasi otomatis via GPS (dengan izin pengguna)** serta opsi **pemilihan lokasi manual**.

---

## 📌 Identitas Proyek & Pengembang

* **Nama Pengembang / Mahasiswa**: 
* **Topik / Studi Kasus**: *Counter dengan Jadwal Sholat dilengkapi Deteksi Lokasi Otomatis (Izin Pengguna) & Pilihan Lokasi Manual*
* **Repositori**: `counter_project`

---

## 🚀 Fitur Utama Aplikasi

### 1. 📿 Counter Tasbih Digital
- **Quick Counter (Nilai Tambah di Home)**: Penghitung tasbih berbasis `StatefulWidget` langsung di beranda untuk dzikir cepat.
- **Tasbih Layar Penuh**: Halaman counter khusus dengan visual melingkar, tombol increment (+), decrement (-), dan reset.
- State management terintegrasi menggunakan `Provider`.

### 2. 📍 Deteksi Lokasi Otomatis (GPS dengan Izin Pengguna)
- Meminta izin akses lokasi perangkat (`Geolocator.requestPermission()`).
- Jika izin diberikan, aplikasi mendeteksi koordinat GPS pengguna secara akurat dan mencocokkan ke kota terdekat.
- Jika izin ditolak oleh pengguna, aplikasi menampilkan dialog informatif dan mengarahkan pengguna untuk memilih kota secara manual tanpa hambatan.
- Menampilkan indikator status lokasi aktif: **`DETEKSI GPS OTOMATIS`** atau **`PILIHAN LOKASI MANUAL`**.

### 3. 🗺️ Pemilihan Lokasi Manual (Jika Tidak Menggunakan GPS)
- Disediakan daftar kota-kota populer di Indonesia (Jakarta, Bandung, Surabaya, Yogyakarta, Semarang, Malang, Medan, Makassar, Denpasar, Palembang, dll.) yang dapat dipilih langsung melalui *modal bottom sheet*.
- Kolom pencarian interaktif untuk mencari seluruh kota/kabupaten di Indonesia via integrasi API.

### 4. ⏰ Jadwal Sholat Harian Akurat
- Menampilkan jadwal harian lengkap secara *real-time*:
  - **Imsak**
  - **Subuh**
  - **Terbit**
  - **Dhuha**
  - **Dzuhur**
  - **Ashar**
  - **Maghrib**
  - **Isya**
- Sumber data terhubung dengan API Kemenag RI via `api.myquran.com`.

---

## 📂 Struktur Direktori Proyek

```text
counter_project/
├── android/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart      # URL endpoint API Jadwal Sholat
│   │   │   └── city_data.dart          # Database kota populer & koordinat
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   │   ├── counter/
│   │   │   ├── providers/
│   │   │   │   └── counter_provider.dart
│   │   │   └── screens/
│   │   │       └── counter_screen.dart # Halaman Tasbih Layar Penuh
│   │   └── prayer_times/
│   │       ├── models/
│   │       │   ├── city.dart           # Model data Kota
│   │       │   └── prayer_time.dart    # Model data Jadwal Sholat
│   │       ├── providers/
│   │       │   └── prayer_provider.dart# Manajemen state jadwal & lokasi
│   │       ├── screens/
│   │       │   └── prayer_screen.dart  # Halaman detail Jadwal Sholat
│   │       └── services/
│   │           ├── location_service.dart# Layanan izin GPS & geocoding
│   │           └── prayer_service.dart # Layanan API jadwal sholat
│   ├── screens/
│   │   └── home_screen.dart            # Kriteria Tugas: StatelessWidget Home
│   └── main.dart                       # Entry point & MaterialApp Theme
├── test/
│   └── widget_test.dart                # Pengujian otomatis kriteria tugas
├── pubspec.yaml
└── README.md
```

---

## 🛠️ Teknologi & Dependensi

* **Framework**: [Flutter](https://flutter.dev/) (Channel stable, Dart 3.x)
* **State Management**: [`provider`](https://pub.dev/packages/provider)
* **Location & Geocoding**:
  * [`geolocator`](https://pub.dev/packages/geolocator) — Akses sensor GPS & izin lokasi
  * [`geocoding`](https://pub.dev/packages/geocoding) — Reverse geocoding koordinat ke nama wilayah
* **Networking**: [`http`](https://pub.dev/packages/http) — Konsumsi REST API
* **API Endpoint**: [MyQuran v2 API](https://api.myquran.com) (Sinkronisasi jadwal sholat Kemenag RI)

---

## 💻 Panduan Menjalankan Aplikasi

### 1. Clone atau Buka Direktori Proyek
```bash
cd C:\ITBS\project-counter\counter_project
```

### 2. Unduh Dependensi
```bash
flutter pub get
```

### 3. Jalankan Pengujian Otomatis
Untuk memvalidasi bahwa seluruh kriteria tugas terpenuhi:
```bash
flutter test
```

### 4. Jalankan Aplikasi
Jalankan pada perangkat emulator Android, perangkat fisik, atau desktop:
```bash
flutter run
```

---

## 📄 Lisensi
Proyek ini dibuat untuk keperluan akademik dan perkuliahan di **ITBS**. Bebas dikembangkan dan dimanfaatkan untuk pembelajaran.
