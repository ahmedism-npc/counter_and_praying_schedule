import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/calendar_agenda.dart';

class CalendarProvider extends ChangeNotifier {
  static const String _storageKey = 'personal_calendar_agendas_v1';

  List<CalendarAgenda> _agendas = [];
  bool _isLoading = false;
  String _statusMessage = '';

  List<CalendarAgenda> get agendas => List.unmodifiable(_agendas);
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;

  CalendarProvider() {
    _loadAgendas();
  }

  /// Get agendas for a specific date (matching year, month, and day)
  List<CalendarAgenda> getAgendasForDate(DateTime date) {
    return _agendas.where((agenda) {
      return agenda.date.year == date.year &&
          agenda.date.month == date.month &&
          agenda.date.day == date.day;
    }).toList();
  }

  /// Checks if any agenda exists on a specific date
  bool hasAgendaOnDate(DateTime date) {
    return _agendas.any((agenda) =>
        agenda.date.year == date.year &&
        agenda.date.month == date.month &&
        agenda.date.day == date.day);
  }

  Future<void> _loadAgendas() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_storageKey);

      if (storedData != null && storedData.isNotEmpty) {
        final List<dynamic> decoded = json.decode(storedData);
        _agendas = decoded
            .map((item) => CalendarAgenda.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // If storage is empty, initialize with rich dummy agendas for demo/dummy account
      if (_agendas.isEmpty) {
        _agendas = _generateInitialDummyAgendas();
        await _saveToStorage();
      }
    } catch (_) {
      _agendas = _generateInitialDummyAgendas();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_agendas.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  /// Add new personal agenda
  Future<void> addAgenda(CalendarAgenda agenda) async {
    _agendas.add(agenda);
    _agendas.sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();
    await _saveToStorage();
  }

  /// Delete personal agenda by ID
  Future<void> deleteAgenda(String id) async {
    _agendas.removeWhere((a) => a.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  /// Toggle completion state of an agenda item
  Future<void> toggleAgendaCompleted(String id) async {
    final index = _agendas.indexWhere((a) => a.id == id);
    if (index != -1) {
      final item = _agendas[index];
      _agendas[index] = item.copyWith(isCompleted: !item.isCompleted);
      notifyListeners();
      await _saveToStorage();
    }
  }

  /// Import agendas from Google Calendar
  Future<int> importFromGoogleCalendar(AuthProvider authProvider) async {
    _isLoading = true;
    _statusMessage = 'Mengimpor agenda dari Google Calendar...';
    notifyListeners();

    int importedCount = 0;
    try {
      // 1. If not logged in yet, trigger sign in
      if (!authProvider.isLoggedIn) {
        await authProvider.signInWithGoogle();
      }

      // 2. Attempt fetching from Google Calendar API
      final googleEvents = await authProvider.fetchGoogleCalendarEvents();

      if (googleEvents.isNotEmpty) {
        for (final evt in googleEvents) {
          final summary = evt.summary ?? 'Agenda Google Calendar';
          final startDateTime = evt.start?.dateTime?.toLocal() ??
              evt.start?.date ??
              DateTime.now();
          final endDateTime = evt.end?.dateTime?.toLocal();

          final startTime =
              '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';
          final endTime = endDateTime != null
              ? '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}'
              : null;

          final agenda = CalendarAgenda(
            id: 'gcal_${evt.id ?? DateTime.now().millisecondsSinceEpoch}_$importedCount',
            title: summary,
            date: DateTime(startDateTime.year, startDateTime.month, startDateTime.day),
            startTime: startTime,
            endTime: endTime,
            notes: evt.description ?? 'Disinkronkan dari Google Calendar',
            category: 'Google Calendar',
            isFromGoogle: true,
          );

          // Avoid duplicating identical ID
          if (!_agendas.any((a) => a.id == agenda.id)) {
            _agendas.add(agenda);
            importedCount++;
          }
        }
      } else {
        // 3. Fallback: Seed demo Google Calendar agendas for the demo account
        final now = DateTime.now();
        final dummyGoogleEvents = [
          CalendarAgenda(
            id: 'gcal_dummy_1_${now.millisecondsSinceEpoch}',
            title: 'Google Meet: Kuliah Umum ITBS',
            date: DateTime(now.year, now.month, now.day),
            startTime: '10:00',
            endTime: '11:30',
            notes: 'Link Google Meet: meet.google.com/itbs-kuliah-umum (Akun: ahmad.fathoni@itbs.ac.id)',
            category: 'Google Calendar',
            isFromGoogle: true,
          ),
          CalendarAgenda(
            id: 'gcal_dummy_2_${now.millisecondsSinceEpoch}',
            title: 'Sinkronisasi Evaluasi Proyek Akhir',
            date: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
            startTime: '14:00',
            endTime: '15:30',
            notes: 'Jadwal Google Classroom & Kalender Akademik ITBS',
            category: 'Google Calendar',
            isFromGoogle: true,
          ),
          CalendarAgenda(
            id: 'gcal_dummy_3_${now.millisecondsSinceEpoch}',
            title: 'Seminar Riset Kecerdasan Buatan & Mobile',
            date: DateTime(now.year, now.month, now.day).add(const Duration(days: 3)),
            startTime: '08:30',
            endTime: '10:00',
            notes: 'Undangan Calendar: Dr. Ir. Fathoni (Google Calendar)',
            category: 'Google Calendar',
            isFromGoogle: true,
          ),
        ];

        for (final item in dummyGoogleEvents) {
          if (!_agendas.any((a) =>
              a.title == item.title &&
              a.date.year == item.date.year &&
              a.date.month == item.date.month &&
              a.date.day == item.date.day)) {
            _agendas.add(item);
            importedCount++;
          }
        }
      }

      _agendas.sort((a, b) => a.startTime.compareTo(b.startTime));
      await _saveToStorage();
      _statusMessage = 'Berhasil mengimpor $importedCount agenda Google Calendar';
      return importedCount;
    } catch (e) {
      _statusMessage = 'Gagal mengimpor: $e';
      return 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generates initial dummy agenda items for dummy account
  List<CalendarAgenda> _generateInitialDummyAgendas() {
    final now = DateTime.now();

    return [
      CalendarAgenda(
        id: 'dummy_1',
        title: 'Kajian Bulanan ITBS: Fiqih Ibadah Praktis',
        date: DateTime(now.year, now.month, now.day),
        startTime: '09:00',
        endTime: '11:00',
        notes: 'Aula Utama ITBS bersama Ustadz Dr. H. Abdurrahman (Akun: ahmad.fathoni@itbs.ac.id)',
        category: 'Kajian',
      ),
      CalendarAgenda(
        id: 'dummy_2',
        title: 'Tadarus & Setoran Hafalan Al-Qur\'an',
        date: DateTime(now.year, now.month, now.day),
        startTime: '16:00',
        endTime: '17:15',
        notes: 'Musholla Baitul Ilmi ITBS lantai 2',
        category: 'Ibadah',
      ),
      CalendarAgenda(
        id: 'dummy_3',
        title: 'Puasa Sunnah Ayyamul Bidh',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
        startTime: '04:00',
        endTime: '04:30',
        notes: 'Sahur bersama dan berniat puasa sunnah pertengahan bulan hijriah',
        category: 'Ibadah',
      ),
      CalendarAgenda(
        id: 'dummy_4',
        title: 'Rapat Panitia Peringatan Maulid Nabi',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
        startTime: '13:30',
        endTime: '15:00',
        notes: 'Ruang Sidang Lt. 2 - Pembahasan rundown acara dan konsumsi',
        category: 'Pribadi',
      ),
      CalendarAgenda(
        id: 'dummy_5',
        title: 'Persiapan Sholat Jumat & Infaq Berkah ITBS',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 2)),
        startTime: '11:30',
        endTime: '12:45',
        notes: 'Masjid Agung ITBS - Datang lebih awal untuk mendengarkan khutbah',
        category: 'Ibadah',
      ),
      CalendarAgenda(
        id: 'dummy_6',
        title: 'Bimbingan Studi Kasus Mobile Computing',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 3)),
        startTime: '10:00',
        endTime: '11:45',
        notes: 'Lab Komputer ITBS bersama Dosen Pembimbing',
        category: 'Akademik',
      ),
    ];
  }
}
