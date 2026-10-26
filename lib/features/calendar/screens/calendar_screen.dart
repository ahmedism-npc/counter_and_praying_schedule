import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/utils/date_formatter.dart';

class CalendarScreen extends StatefulWidget {
  final bool showAppBar;

  const CalendarScreen({super.key, this.showAppBar = true});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((c) => arabicDigits[int.parse(c)]).join();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  String _getHijriHeader() {
    final startHijri = HijriCalendar.fromDate(
      DateTime(_currentMonth.year, _currentMonth.month, 1),
    );
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final endHijri = HijriCalendar.fromDate(
      DateTime(_currentMonth.year, _currentMonth.month, lastDay),
    );

    if (startHijri.hMonth == endHijri.hMonth) {
      return '${startHijri.longMonthName} ${startHijri.hYear} H';
    } else {
      return '${startHijri.longMonthName} - ${endHijri.longMonthName} ${endHijri.hYear} H';
    }
  }

  String _getIslamicEvent(DateTime date, HijriCalendar hijri) {
    // Puasa Sunnah check
    final dayOfWeek = date.weekday;
    if (dayOfWeek == DateTime.monday) {
      return 'Puasa Sunnah Senin';
    } else if (dayOfWeek == DateTime.thursday) {
      return 'Puasa Sunnah Kamis';
    } else if (hijri.hDay >= 13 && hijri.hDay <= 15) {
      return 'Puasa Ayyamul Bidh';
    }

    // Hari Besar Islam
    if (hijri.hMonth == 1 && hijri.hDay == 1) return 'Tahun Baru Islam (1 Muharram)';
    if (hijri.hMonth == 1 && hijri.hDay == 10) return 'Hari Asyura (10 Muharram)';
    if (hijri.hMonth == 3 && hijri.hDay == 12) return 'Maulid Nabi Muhammad SAW';
    if (hijri.hMonth == 7 && hijri.hDay == 27) return 'Isra Mi\'raj';
    if (hijri.hMonth == 9 && hijri.hDay == 1) return 'Awal Ramadhan';
    if (hijri.hMonth == 9 && hijri.hDay == 17) return 'Nuzulul Qur\'an';
    if (hijri.hMonth == 10 && hijri.hDay == 1) return 'Hari Raya Idul Fitri';
    if (hijri.hMonth == 12 && hijri.hDay == 9) return 'Hari Arafah';
    if (hijri.hMonth == 12 && hijri.hDay == 10) return 'Hari Raya Idul Adha';

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7; // 0 for Sunday
    final selectedHijri = HijriCalendar.fromDate(_selectedDate);
    final eventInfo = _getIslamicEvent(_selectedDate, selectedHijri);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Kalender Hijriah & Masehi'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.today),
                  tooltip: 'Hari Ini',
                  onPressed: _goToToday,
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card Navigasi Bulan
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.teal.shade900.withValues(alpha: 0.5) : const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                          tooltip: 'Bulan Sebelumnya',
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                AppDateFormatter.formatMonthYear(_currentMonth),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _getHijriHeader(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal.shade100,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                          tooltip: 'Bulan Berikutnya',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Baris Nama Hari (Ahad sd Sabtu)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _buildDayNameHeader('AHAD', Colors.red, isDark),
                    _buildDayNameHeader('SENIN', null, isDark),
                    _buildDayNameHeader('SELASA', null, isDark),
                    _buildDayNameHeader('RABU', null, isDark),
                    _buildDayNameHeader('KAMIS', null, isDark),
                    _buildDayNameHeader('JUMAT', Colors.green, isDark),
                    _buildDayNameHeader('SABTU', null, isDark),
                  ],
                ),
              ),
              const Divider(height: 12),

              // Grid Tanggal Kalender (Masehi + Hijriah Saja)
              _buildCalendarGrid(daysInMonth, firstWeekday, isDark),

              const SizedBox(height: 16),

              // Kartu Detail Tanggal Terpilih
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_note, color: Color(0xFF0F766E)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppDateFormatter.formatFullDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${selectedHijri.hDay} ${selectedHijri.longMonthName} ${selectedHijri.hYear} H',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (eventInfo.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                eventInfo,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayNameHeader(String name, Color? color, bool isDark) {
    return Expanded(
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color ?? (isDark ? Colors.grey.shade400 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(int daysInMonth, int firstWeekday, bool isDark) {
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (index < firstWeekday || index >= firstWeekday + daysInMonth) {
          return const SizedBox.shrink();
        }

        final day = index - firstWeekday + 1;
        final cellDate = DateTime(_currentMonth.year, _currentMonth.month, day);
        final cellHijri = HijriCalendar.fromDate(cellDate);
        final isToday = cellDate.year == now.year &&
            cellDate.month == now.month &&
            cellDate.day == now.day;
        final isSelected = cellDate.year == _selectedDate.year &&
            cellDate.month == _selectedDate.month &&
            cellDate.day == _selectedDate.day;
        final isSunday = cellDate.weekday == DateTime.sunday;
        final isFriday = cellDate.weekday == DateTime.friday;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedDate = cellDate;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0F766E)
                  : isToday
                      ? Colors.teal.shade100.withValues(alpha: 0.4)
                      : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0F766E)
                    : isToday
                        ? const Color(0xFF0F766E)
                        : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Tanggal Hijriah dalam angka Arab di sudut atas kiri
                Positioned(
                  top: 2,
                  left: 3,
                  child: Text(
                    _toArabicDigits(cellHijri.hDay),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Colors.teal.shade100
                          : (isDark ? Colors.grey.shade400 : Colors.teal.shade700),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Tanggal Masehi tepat di tengah
                Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isSunday
                              ? Colors.red
                              : isFriday
                                  ? Colors.green
                                  : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
