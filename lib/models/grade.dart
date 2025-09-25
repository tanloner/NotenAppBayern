/// The type of a grade.
enum GradeType { big, small, other }

/// The semester a grade belongs to.
enum Semester {
  /// The first semester of the  school year.
  first,

  /// The second semester of the  school year.
  second,

  /// The first semester of the  school year.
  third,

  /// The second semester of the school year.
  fourth;

  /// The display name of the semester.
  String get displayName {
    switch (this) {
      case Semester.first:
        return '1. Halbjahr';
      case Semester.second:
        return '2. Halbjahr';
      case Semester.third:
        return '3. Halbjahr';
      case Semester.fourth:
        return '4. Halbjahr';
    }
  }

  /// Creates a [Semester] from a string.
  static Semester fromString(String value) {
    switch (value) {
      case '1. Halbjahr':
        return Semester.first;
      case '2. Halbjahr':
        return Semester.second;
      case '3. Halbjahr':
        return Semester.third;
      case '4. Halbjahr':
        return Semester.fourth;
      default:
        throw ArgumentError('Unknown semester string: "$value"');
    }
  }
}

/// Represents a single grade.
class Grade {
  /// The unique identifier of the grade.
  final String id;

  /// The value of the grade.
  final int value;

  /// The description of the grade.
  final String description;

  /// The date of the grade.
  final DateTime date;

  /// The weight of the grade.
  final double weight;

  /// The type of the grade.
  final GradeType type;

  /// The semester the grade belongs to.
  final Semester semester;

  /// Creates a [Grade] instance.
  Grade(
      {required this.id,
      required this.value,
      required this.description,
      required this.date,
      required this.semester,
      this.weight = 1.0,
      this.type = GradeType.other});

  /// Converts the [Grade] to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'description': description,
      'date': date.toIso8601String(),
      'semester': semester.toString(),
      'weight': weight,
      'type': type.toString(),
    };
  }

  /// Whether the grade is a big grade.
  bool get isBig {
    return type == GradeType.big;
  }

  /// Creates a [Grade] from a JSON object.
  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      value: json['value'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      semester:
          Semester.values.firstWhere((s) => s.toString() == json['semester']),
      weight: json['weight'] ?? 1.0,
      type: GradeType.values.firstWhere((t) => t.toString() == json['type']),
    );
  }
}
