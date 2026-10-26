# 🕌 Jadwal Sholat, Tasbih Digital & Ibadah Terpadu

> **Aplikasi Mobile Flutter** — Tugas Studi Kasus Pemrograman Mobile ITBS.  
> Aplikasi komprehensif pendukung ibadah muslim yang menggabungkan **Jadwal Sholat Harian Akurat (GPS/Manual)**, **Counter Tasbih Digital**, **Kalender Hijriah & Masehi**, **Kompas Arah Kiblat Interaktif**, **Preferensi Kustomisasi (Tema Gelap/Terang, Bahasa, Getar)**, serta **Autentikasi & Sinkronisasi Agenda ke Google Calendar**.

---

## 🚀 Fitur-Fitur Utama Aplikasi

### 1. 💫 Splash Screen Beranimasi (1 Detik)
- Logo resmi aplikasi dengan animasi masuk (*scale & fade*) berdurasi 1.000 ms.
- Inisialisasi preferensi pengguna (*theme, vibration, language*) sebelum beralih mulus ke navigasi utama.

### 2. 🕌 Tab 1: Jadwal Sholat (Beranda Utama)
- **Hero Header Islami**: Gradasi hijau toska dengan nama lokasi aktif, status GPS/manual, penanda sholat berikutnya (misal: *Isya' 18:36 WIB*), dan hitung mundur (*countdown*) *real-time*.
- **Pembaruan Lokasi**: Tombol cepat *Update GPS* dan *Modal Bottom Sheet* untuk memilih atau mencari kota/kabupaten di seluruh Indonesia.
- **Navigasi Tanggal**: Pengalih tanggal Masehi dan Hijriah harian.
- **8 Waktu Sholat**: Menampilkan Imsak, Subuh, Terbit, Dhuha, Zuhur, Ashar, Maghrib, dan Isya' dengan kartu sorotan aktif untuk waktu sholat yang sedang berlangsung.
- **Tashih Falakiyah**: Terhubung dengan sumber resmi Kemenag RI / Lembaga Falakiyah NU.

### 3. 📿 Tab 2: Tasbih Digital
- **Antarmuka Minimalis**: Layar bersih bebas distraksi dengan angka counter berukuran besar.
- **Kontrol Responsif**: Tombol Tambah (+1), Kurang (-1), dan Reset dengan dialog pengaman.
- **Haptic Vibration**: Efek getar pada sentuhan (dapat diaktifkan/dinonaktifkan melalui Pengaturan).

### 4. 📅 Tab 3: Kalender Hijriah & Masehi
- **Navigasi Bulanan**: Menampilkan bulan Masehi dan padanan bulan Hijriah.
- **Grid Kalender Rapi**: Memuat angka tanggal Masehi (Latin) dan tanggal Hijriah (Arab).
- **Penanda Khusus**: Hari Ahad (merah) dan Jumat (hijau), serta indikator hari ini.
- **Detail Agenda Ibadah**: Menampilkan informasi puasa sunnah (Senin & Kamis, Ayyamul Bidh) dan peringatan hari besar Islam saat tanggal diklik.

### 5. 🧭 Tab 4: Kompas Kiblat (Qibla Compass)
- **Kalkulasi Sudut Presisi**: Perhitungan matematis *Great-Circle Bearing* dari koordinat GPS ke Ka'bah (Makkah).
- **Piringan Berputar Dinamis**: Bergerak halus menyesuaikan sensor magnetometer perangkat.
- **Jarum Ka'bah Emas**: Penunjuk arah kiblat dengan sudut derajat presisi dari arah Utara (misal: `294.21°`).
- **Simulasi & Panduan**: Mendukung mode kalibrasi serta simulasi fallback di lingkungan emulator tanpa sensor fisik.

### 6. ⚙️ Tab 5: Pengaturan & Sinkronisasi Akun
- **Integrasi Akun Google**: Masuk dengan Akun Google (*Google Sign-In*).
- **Google Calendar Sync**: Tombol *"Sinkronkan ke Google Calendar"* untuk mengekspor jadwal sholat dan agenda ibadah ke kalender pengguna secara otomatis.
- **Kustomisasi Pengguna**:
  - Pilihan Tema: `Mode Terang (Light)`, `Mode Gelap (Dark)`, atau `Ikuti Sistem`.
  - Pilihan Bahasa: `Bahasa Indonesia (ID)` atau `English (EN)`.
  - Efek Getar (Vibration): On / Off.
- **Informasi Aplikasi**: Detail versi dan identitas perkuliahan ITBS.

---

## 📂 Struktur Direktori Proyek

```text
counter_project/
├── assets/
│   └── images/
│       └── app_logo.png              # Logo aplikasi resmi
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart    # Endpoint MyQuran v2 API
│   │   │   └── city_data.dart        # Database kota & koordinat GPS
│   │   └── utils/
│   │       └── date_formatter.dart   # Pemformat tanggal ID/EN
│   ├── features/
│   │   ├── auth/                     # Fitur Login Google & Sync Calendar
│   │   │   ├── providers/auth_provider.dart
│   │   │   └── services/google_calendar_service.dart
│   │   ├── calendar/                 # Fitur Kalender Masehi & Hijriah
│   │   │   └── screens/calendar_screen.dart
│   │   ├── compass/                  # Fitur Kompas Kiblat
│   │   │   └── screens/qibla_screen.dart
│   │   ├── counter/                  # Fitur Tasbih Digital
│   │   │   ├── providers/counter_provider.dart
│   │   │   └── screens/counter_screen.dart
│   │   ├── prayer_times/             # Fitur Jadwal Sholat & Lokasi
│   │   │   ├── models/ (city.dart, prayer_time.dart)
│   │   │   ├── providers/prayer_provider.dart
│   │   │   ├── services/ (location_service.dart, prayer_service.dart)
│   │   │   └── screens/prayer_screen.dart
│   │   ├── settings/                 # Fitur Preferensi Pengguna
│   │   │   ├── providers/settings_provider.dart
│   │   │   └── screens/settings_screen.dart
│   │   └── splash/                   # Fitur Splash Screen 1 Detik
│   │       └── screens/splash_screen.dart
│   ├── screens/
│   │   └── main_navigation_screen.dart # Shell Bottom Navigation 5 Tab
│   └── main.dart                     # MultiProvider & MaterialApp Theme
├── test/
│   └── widget_test.dart              # Automated UI & flow tests
└── pubspec.yaml
```

---

## 🛠️ Dependensi Utama

* [`provider`](https://pub.dev/packages/provider): Manajemen state aplikasi terpusat.
* [`geolocator`](https://pub.dev/packages/geolocator): Izin dan deteksi koordinat GPS pengguna.
* [`flutter_compass`](https://pub.dev/packages/flutter_compass): Pembacaan sensor arah mata angin.
* [`hijri`](https://pub.dev/packages/hijri): Kalkulasi konversi kalender Hijriah.
* [`google_sign_in`](https://pub.dev/packages/google_sign_in): Autentikasi Google Account.
* [`googleapis`](https://pub.dev/packages/googleapis): Integrasi Google Calendar API v3.
* [`shared_preferences`](https://pub.dev/packages/shared_preferences): Penyimpanan preferensi tema, bahasa, dan getar.

---

## 🧪 Menjalankan Pengujian Otomatis

Untuk menjalankan seluruh rangkaian pengujian unit dan antarmuka:
```bash
flutter test
```
*Hasil Verifikasi:*
```text
00:00 +0: Verifikasi Splash Screen 1 Detik dan Transisi ke Navigasi Utama
00:01 +1: Verifikasi Fitur Counter Tasbih (Increment, Decrement, Reset)
00:01 +2: Verifikasi Tab Kalender (Masehi & Hijriah)
00:02 +3: Verifikasi Tab Kompas Kiblat
00:02 +4: Verifikasi Tab Pengaturan & Status Login Google
00:02 +5: All tests passed!
```

---

## 💻 Menjalankan Aplikasi

```bash
cd counter_project
flutter run
```
