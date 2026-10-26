class CalendarAgenda {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String? endTime;
  final String notes;
  final String category;
  final bool isFromGoogle;
  final bool isCompleted;

  CalendarAgenda({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    this.endTime,
    this.notes = '',
    this.category = 'Pribadi',
    this.isFromGoogle = false,
    this.isCompleted = false,
  });

  CalendarAgenda copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? notes,
    String? category,
    bool? isFromGoogle,
    bool? isCompleted,
  }) {
    return CalendarAgenda(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      isFromGoogle: isFromGoogle ?? this.isFromGoogle,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes,
      'category': category,
      'isFromGoogle': isFromGoogle,
      'isCompleted': isCompleted,
    };
  }

  factory CalendarAgenda.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      final parts = (json['date'] as String).split('-');
      parsedDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return CalendarAgenda(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Agenda',
      date: parsedDate,
      startTime: json['startTime'] as String? ?? '08:00',
      endTime: json['endTime'] as String?,
      notes: json['notes'] as String? ?? '',
      category: json['category'] as String? ?? 'Pribadi',
      isFromGoogle: json['isFromGoogle'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
