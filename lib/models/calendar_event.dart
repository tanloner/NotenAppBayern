/// Represents a single event in the calendar.
class CalendarEvent {
  /// The unique identifier of the event.
  final String id;

  /// The title of the event.
  final String title;

  /// The description of the event.
  final String description;

  /// The date of the event.
  final DateTime date;

  /// The type of the event.
  final EventType type;

  /// The ID of the subject this event belongs to, if any.
  final String? subjectId;

  /// Creates a [CalendarEvent] instance.
  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.subjectId,
  });

  /// Converts the [CalendarEvent] to a JSON object.
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

  /// Creates a [CalendarEvent] from a JSON object.
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

  /// Creates a copy of this [CalendarEvent] with the given fields replaced
  /// with the new values.
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

/// The type of a calendar event.
enum EventType {
  /// A test.
  test,

  /// A quiz.
  quiz,

  /// Homework.
  homework,

  /// A project.
  project,

  /// A presentation.
  presentation,

  /// Other.
  other,
}

/// An extension on [EventType] to provide a display name and an icon.
extension EventTypeExtension on EventType {
  /// The display name of the event type.
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

  /// The icon of the event type.
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
