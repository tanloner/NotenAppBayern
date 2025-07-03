import 'package:flutter/material.dart';

import 'grade.dart';

class Subject {
  final String id;
  String name;
  final List<Grade> grades;
  Color color;
  bool isLk;

  Subject(
      {required this.id,
      required this.name,
      required this.grades,
      this.color = Colors.blue,
      this.isLk = false});

  double get averageGrade {
    if (grades.isEmpty) return 0.0;
    double sum =
        grades.fold(0.0, (sum, grade) => sum + grade.value * grade.weight);
    double weightSum = grades.fold(0.0, (sum, grade) => sum + grade.weight);
    return sum / weightSum;
  }

  void setNewName(String newName) {
    name = newName;
  }

  void setNewColor(Color newColor) {
    color = newColor;
  }

  void setIsLk(bool isLk) {
    isLk = isLk;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grades': grades.map((g) => g.toJson()).toList(),
      'color': color.value,
      //.toARGB32(),
      'isLk': isLk
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      grades: (json['grades'] as List).map((g) => Grade.fromJson(g)).toList(),
      color: Color(json['color'] ?? Colors.blue.value),
      //toARGB32()),
      isLk: json['isLk'] ?? false,
    );
  }

  Subject copyWith({
    String? name,
    Color? color,
    bool? isLk,
  }) {
    return Subject(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      grades: grades,
      isLk: isLk ?? this.isLk,
    );
  }
}
