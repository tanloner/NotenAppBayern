class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final EventType type;
  final String? subjectId;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.subjectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.index,
      'subjectId': subjectId,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: EventType.values[json['type'] ?? 0],
      subjectId: json['subjectId'],
    );
  }

  CalendarEvent copyWith({
    String? title,
    String? description,
    DateTime? date,
    EventType? type,
    String? subjectId,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      subjectId: subjectId ?? this.subjectId,
    );
  }
}

enum EventType {
  test,
  quiz,
  homework,
  project,
  presentation,
  other,
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.test:
        return 'Klassenarbeit';
      case EventType.quiz:
        return 'Test';
      case EventType.homework:
        return 'Hausaufgaben';
      case EventType.project:
        return 'Projekt';
      case EventType.presentation:
        return 'Präsentation';
      case EventType.other:
        return 'Sonstiges';
    }
  }

  String get icon {
    switch (this) {
      case EventType.test:
        return '📝';
      case EventType.quiz:
        return '❓';
      case EventType.homework:
        return '📚';
      case EventType.project:
        return '🎯';
      case EventType.presentation:
        return '🎤';
      case EventType.other:
        return '📅';
    }
  }
}