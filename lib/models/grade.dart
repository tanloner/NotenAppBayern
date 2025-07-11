enum GradeType { big, small, other }

enum Semester {
  first,
  second,
  third,
  fourth;

  String get displayName {
    switch (this) {
      case Semester.first:
        return '1. Halbjahr 2024/25';
      case Semester.second:
        return '2. Halbjahr 2024/25';
      case Semester.third:
        return '1. Halbjahr 2025/26';
      case Semester.fourth:
        return '2. Halbjahr 2025/26';
    }
  }

  static Semester fromString(String value) {
    switch (value) {
      case '1. Halbjahr 2024/25':
        return Semester.first;
      case '2. Halbjahr 2024/25':
        return Semester.second;
      case '1. Halbjahr 2025/26':
        return Semester.third;
      case '2. Halbjahr 2025/26':
        return Semester.fourth;
      default:
        throw ArgumentError('Unknown semester string: "$value"');
    }
  }
}

class Grade {
  final String id;
  final int value;
  final String description;
  final DateTime date;
  final double weight;
  final GradeType type;
  final Semester semester;

  Grade(
      {required this.id,
      required this.value,
      required this.description,
      required this.date,
      required this.semester,
      this.weight = 1.0,
      this.type = GradeType.other});

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

  bool get isBig {
    return type == GradeType.big;
  }

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
