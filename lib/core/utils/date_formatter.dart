class AppDateFormatter {
  static const List<String> monthsId = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const List<String> daysId = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Ahad'
  ];

  static const List<String> monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> daysEn = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  /// Format: 25 Oktober 2026
  static String formatDayMonthYear(DateTime date, {String lang = 'id'}) {
    final months = lang == 'id' ? monthsId : monthsEn;
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format: Oktober 2026
  static String formatMonthYear(DateTime date, {String lang = 'id'}) {
    final months = lang == 'id' ? monthsId : monthsEn;
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Format: Ahad, 25 Oktober 2026
  static String formatFullDate(DateTime date, {String lang = 'id'}) {
    final days = lang == 'id' ? daysId : daysEn;
    final months = lang == 'id' ? monthsId : monthsEn;
    final dayName = days[date.weekday - 1];
    return '$dayName, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
