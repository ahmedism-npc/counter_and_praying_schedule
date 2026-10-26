import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../../prayer_times/models/prayer_time.dart';

class GoogleCalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      cal.CalendarApi.calendarEventsScope,
    ],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      // Return null on cancellation or configuration missing
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  /// Fetches events from primary Google Calendar
  Future<List<cal.Event>> fetchCalendarEvents({
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    try {
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        return [];
      }

      final calendarApi = cal.CalendarApi(authClient);
      final events = await calendarApi.events.list(
        'primary',
        timeMin: (timeMin ?? DateTime.now().subtract(const Duration(days: 30))).toUtc(),
        timeMax: (timeMax ?? DateTime.now().add(const Duration(days: 60))).toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Syncs prayer times for today into Google Calendar
  Future<bool> syncPrayerTimesToCalendar({
    required String cityName,
    required PrayerTime prayerTime,
    required DateTime date,
  }) async {
    try {
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        return false;
      }

      final calendarApi = cal.CalendarApi(authClient);

      // Create events for the 5 main prayers
      final prayers = [
        {'name': 'Subuh', 'time': prayerTime.subuh},
        {'name': 'Dzuhur', 'time': prayerTime.dzuhur},
        {'name': 'Ashar', 'time': prayerTime.ashar},
        {'name': 'Maghrib', 'time': prayerTime.maghrib},
        {'name': 'Isya', 'time': prayerTime.isya},
      ];

      for (final prayer in prayers) {
        final timeParts = (prayer['time'] as String).split(':');
        if (timeParts.length < 2) continue;

        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;

        final startDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        final endDateTime = startDateTime.add(const Duration(minutes: 30));

        final event = cal.Event(
          summary: '🕌 Sholat ${prayer['name']} - $cityName',
          description:
              'Waktu Sholat ${prayer['name']} di $cityName (${prayerTime.tanggal}). Disinkronkan otomatis dari aplikasi Jadwal Sholat & Tasbih.',
          start: cal.EventDateTime(
            dateTime: startDateTime.toUtc(),
            timeZone: 'Asia/Jakarta',
          ),
          end: cal.EventDateTime(
            dateTime: endDateTime.toUtc(),
            timeZone: 'Asia/Jakarta',
          ),
          reminders: cal.EventReminders(
            useDefault: false,
            overrides: [
              cal.EventReminder(method: 'popup', minutes: 10),
            ],
          ),
        );

        await calendarApi.events.insert(event, 'primary');
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
