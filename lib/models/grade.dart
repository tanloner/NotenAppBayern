enum GradeType { big, small, other }

class Grade {
  final String id;
  final int value;
  final String description;
  final DateTime date;
  final double weight;
  final GradeType type;

  Grade(
      {required this.id,
      required this.value,
      required this.description,
      required this.date,
      this.weight = 1.0,
      this.type = GradeType.other});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'description': description,
      'date': date.toIso8601String(),
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
      weight: json['weight'] ?? 1.0,
      type: GradeType.values.firstWhere((t) => t.toString() == json['type']),
    );
  }
}
