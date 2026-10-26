import 'package:flutter_test/flutter_test.dart';
import 'package:counter_project/features/calendar/models/calendar_agenda.dart';

void main() {
  group('CalendarAgenda Unit Tests', () {
    test('CalendarAgenda serialization and deserialization works correctly', () {
      final now = DateTime(2026, 10, 26);
      final agenda = CalendarAgenda(
        id: 'test_1',
        title: 'Kajian Tafsir',
        date: now,
        startTime: '09:00',
        endTime: '10:30',
        notes: 'Masjid ITBS',
        category: 'Kajian',
        isFromGoogle: true,
        isCompleted: false,
      );

      final jsonMap = agenda.toJson();
      expect(jsonMap['id'], 'test_1');
      expect(jsonMap['title'], 'Kajian Tafsir');
      expect(jsonMap['date'], '2026-10-26');
      expect(jsonMap['startTime'], '09:00');
      expect(jsonMap['endTime'], '10:30');
      expect(jsonMap['isFromGoogle'], true);

      final reconstructed = CalendarAgenda.fromJson(jsonMap);
      expect(reconstructed.id, agenda.id);
      expect(reconstructed.title, agenda.title);
      expect(reconstructed.date.year, 2026);
      expect(reconstructed.date.month, 10);
      expect(reconstructed.date.day, 26);
      expect(reconstructed.startTime, agenda.startTime);
      expect(reconstructed.endTime, agenda.endTime);
      expect(reconstructed.category, agenda.category);
      expect(reconstructed.isFromGoogle, true);
      expect(reconstructed.isCompleted, false);
    });

    test('CalendarAgenda copyWith updates fields properly', () {
      final agenda = CalendarAgenda(
        id: '1',
        title: 'Puasa Sunnah',
        date: DateTime(2026, 10, 27),
        startTime: '04:00',
      );

      final updated = agenda.copyWith(isCompleted: true, notes: 'Sahur bersama');
      expect(updated.id, '1');
      expect(updated.title, 'Puasa Sunnah');
      expect(updated.isCompleted, true);
      expect(updated.notes, 'Sahur bersama');
    });
  });
}
