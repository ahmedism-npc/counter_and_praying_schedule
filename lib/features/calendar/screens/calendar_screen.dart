import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/calendar_agenda.dart';
import '../providers/calendar_provider.dart';
import '../widgets/add_agenda_bottom_sheet.dart';

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

  Future<void> _showAddAgendaDialog() async {
    final newAgenda = await showModalBottomSheet<CalendarAgenda>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddAgendaBottomSheet(
        initialDate: _selectedDate,
      ),
    );

    if (newAgenda != null && mounted) {
      final provider = Provider.of<CalendarProvider>(context, listen: false);
      await provider.addAgenda(newAgenda);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agenda "${newAgenda.title}" berhasil ditambahkan!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _handleImportGoogleCalendar(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

    final count = await calendarProvider.importFromGoogleCalendar(authProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count > 0
              ? 'Berhasil mengimpor $count agenda dari Google Calendar!'
              : 'Semua agenda Google Calendar sudah tersinkronisasi.',
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
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
              title: const Text('Kalender Hijriah & Agenda'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAgendaDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text('Tambah Agenda', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card Navigasi Bulan dengan Gradiasi Elegan
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
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
                              letterSpacing: 0.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getHijriHeader(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.goldLight,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
              ),

              const SizedBox(height: 14),

              // Baris Nama Hari (Ahad sd Sabtu)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _buildDayNameHeader('AHAD', Colors.redAccent, isDark),
                    _buildDayNameHeader('SENIN', null, isDark),
                    _buildDayNameHeader('SELASA', null, isDark),
                    _buildDayNameHeader('RABU', null, isDark),
                    _buildDayNameHeader('KAMIS', null, isDark),
                    _buildDayNameHeader('JUMAT', isDark ? AppColors.primaryAccent : AppColors.primary, isDark),
                    _buildDayNameHeader('SABTU', null, isDark),
                  ],
                ),
              ),
              const Divider(height: 12),

              // Grid Tanggal Kalender (Masehi + Hijriah + Agenda Indicator Dot)
              Consumer<CalendarProvider>(
                builder: (context, calendarProvider, _) {
                  return _buildCalendarGrid(daysInMonth, firstWeekday, isDark, calendarProvider);
                },
              ),

              const SizedBox(height: 16),

              // Kartu Detail Tanggal Terpilih & Hari Besar Islami
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.primary),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColors.primaryLight : AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${selectedHijri.hDay} ${selectedHijri.longMonthName} ${selectedHijri.hYear} H',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.goldLight : AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (eventInfo.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryDark.withValues(alpha: 0.4)
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.goldDark : AppColors.gold.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 16, color: AppColors.gold),
                              const SizedBox(width: 8),
                              Text(
                                eventInfo,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.goldLight : AppColors.goldDark,
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

              const SizedBox(height: 18),

              // Bagian Agenda Pribadi & Integrasi Google Calendar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.event_note, color: AppColors.primary, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Agenda Pribadi & Kegiatan',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _handleImportGoogleCalendar(context),
                    icon: const Icon(Icons.cloud_download_outlined, size: 16),
                    label: const Text('Import Google Cal', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Daftar Agenda untuk Tanggal Terpilih
              Consumer<CalendarProvider>(
                builder: (context, calendarProvider, _) {
                  final dailyAgendas = calendarProvider.getAgendasForDate(_selectedDate);

                  if (calendarProvider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (dailyAgendas.isEmpty) {
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 40,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Belum ada agenda pada tanggal ini',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _showAddAgendaDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Tambah Agenda Sekarang'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: dailyAgendas.map((agenda) {
                      return _buildAgendaItem(context, agenda, calendarProvider, isDark);
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 70), // Padding untuk FloatingActionButton
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgendaItem(
    BuildContext context,
    CalendarAgenda agenda,
    CalendarProvider provider,
    bool isDark,
  ) {
    Color categoryColor;
    IconData categoryIcon;

    switch (agenda.category) {
      case 'Ibadah':
        categoryColor = AppColors.primary;
        categoryIcon = Icons.mosque;
        break;
      case 'Kajian':
        categoryColor = AppColors.goldDark;
        categoryIcon = Icons.menu_book;
        break;
      case 'Google Calendar':
        categoryColor = Colors.blue.shade700;
        categoryIcon = Icons.sync;
        break;
      case 'Akademik':
        categoryColor = Colors.indigo;
        categoryIcon = Icons.school;
        break;
      default:
        categoryColor = AppColors.primaryLight;
        categoryIcon = Icons.bookmark_border;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: agenda.isCompleted
              ? Colors.grey.withValues(alpha: 0.3)
              : categoryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox Status Selesai
            InkWell(
              onTap: () => provider.toggleAgendaCompleted(agenda.id),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  agenda.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: agenda.isCompleted ? Colors.green : Colors.grey,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Konten Agenda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Badge Kategori
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcon, size: 12, color: categoryColor),
                            const SizedBox(width: 4),
                            Text(
                              agenda.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Waktu Agenda
                      Text(
                        '${agenda.startTime}${agenda.endTime != null ? ' - ${agenda.endTime}' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey.shade400 : Colors.black54,
                        ),
                      ),
                      if (agenda.isFromGoogle) ...[
                        const Spacer(),
                        const Icon(Icons.g_mobiledata, size: 20, color: Colors.blue),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    agenda.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: agenda.isCompleted ? TextDecoration.lineThrough : null,
                      color: agenda.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  if (agenda.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      agenda.notes,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Tombol Hapus Agenda
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              tooltip: 'Hapus Agenda',
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                provider.deleteAgenda(agenda.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Agenda "${agenda.title}" dihapus.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
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

  Widget _buildCalendarGrid(
    int daysInMonth,
    int firstWeekday,
    bool isDark,
    CalendarProvider calendarProvider,
  ) {
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
        final hasAgenda = calendarProvider.hasAgendaOnDate(cellDate);

        return InkWell(
          onTap: () {
            setState(() {
              _selectedDate = cellDate;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isToday
                      ? AppColors.primary.withValues(alpha: 0.14)
                      : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.gold
                    : isToday
                        ? AppColors.primary
                        : Colors.transparent,
                width: isSelected ? 2 : 1.5,
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
                          ? AppColors.goldLight
                          : (isDark ? Colors.grey.shade400 : AppColors.primary),
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
                              ? Colors.redAccent
                              : isFriday
                                  ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                                  : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
                // Titik Indikator jika ada Agenda pada tanggal ini
                if (hasAgenda)
                  Positioned(
                    bottom: 3,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.gold : AppColors.goldAccent,
                        ),
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
