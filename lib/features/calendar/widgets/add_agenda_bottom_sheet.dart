import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/calendar_agenda.dart';

class AddAgendaBottomSheet extends StatefulWidget {
  final DateTime initialDate;

  const AddAgendaBottomSheet({
    super.key,
    required this.initialDate,
  });

  @override
  State<AddAgendaBottomSheet> createState() => _AddAgendaBottomSheetState();
}

class _AddAgendaBottomSheetState extends State<AddAgendaBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late DateTime _agendaDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? _endTime;
  String _category = 'Ibadah';

  final List<String> _categories = const [
    'Ibadah',
    'Kajian',
    'Pribadi',
    'Akademik',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    _agendaDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _agendaDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      useRootNavigator: true,
    );
    if (picked != null && mounted) {
      setState(() {
        _agendaDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      useRootNavigator: true,
    );
    if (picked != null && mounted) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? _startTime,
      useRootNavigator: true,
    );
    if (picked != null && mounted) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _submitForm() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan judul kegiatan terlebih dahulu.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final startStr =
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final end = _endTime;
    final endStr = end != null
        ? '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'
        : null;

    final newAgenda = CalendarAgenda(
      id: 'agenda_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      date: DateTime(_agendaDate.year, _agendaDate.month, _agendaDate.day),
      startTime: startStr,
      endTime: endStr,
      notes: _notesController.text.trim(),
      category: _category,
    );

    // Kembalikan agenda baru ke pemanggil (bottom sheet tertutup dengan bersih)
    Navigator.of(context).pop(newAgenda);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Dialog
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.event_available, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tambah Agenda Pribadi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Judul Kegiatan
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Agenda / Kegiatan *',
                hintText: 'Misal: Kajian Tafsir, Puasa Sunnah...',
                prefixIcon: const Icon(Icons.edit_calendar),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),

            // Pilihan Tanggal
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(AppDateFormatter.formatDayMonthYear(_agendaDate)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
            const SizedBox(height: 10),

            // Waktu Mulai & Selesai
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickStartTime,
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(
                      'Mulai: ${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickEndTime,
                    icon: const Icon(Icons.access_time_filled, size: 16),
                    label: Text(
                      _endTime != null
                          ? 'Selesai: ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                          : 'Selesai (Opsional)',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Kategori Kegiatan
            const Text(
              'Kategori',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _category = cat;
                      });
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Catatan / Lokasi
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Catatan / Lokasi (Opsional)',
                hintText: 'Misal: Ruang Utama Masjid Kampus ITBS',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Simpan
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Simpan Agenda',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
