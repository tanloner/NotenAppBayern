import 'package:flutter/material.dart';

import 'grade.dart';

class Subject {
  final String id;
  final String name;
  final List<Grade> grades;
  final Color color;

  Subject({
    required this.id,
    required this.name,
    required this.grades,
    this.color = Colors.blue,
  });

  double get averageGrade {
    if (grades.isEmpty) return 0.0;
    double sum = grades.fold(0.0, (sum, grade) => sum + grade.value);
    return sum / grades.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grades': grades.map((g) => g.toJson()).toList(),
      'color': color.value,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      grades: (json['grades'] as List).map((g) => Grade.fromJson(g)).toList(),
      color: Color(json['color'] ?? Colors.blue.value),
    );
  }
}
