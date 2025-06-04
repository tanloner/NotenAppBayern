class Grade {
  final String id;
  final double value;
  final String description;
  final DateTime date;
  final double weight;

  Grade({
    required this.id,
    required this.value,
    required this.description,
    required this.date,
    this.weight = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'description': description,
      'date': date.toIso8601String(),
      'weight': weight,
    };
  }

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      value: json['value'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      weight: json['weight'] ?? 1.0,
    );
  }
}
