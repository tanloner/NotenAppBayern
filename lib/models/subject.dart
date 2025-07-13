import 'package:flutter/material.dart';

import 'grade.dart';

/// Represents a single subject.
class Subject {
  /// The unique identifier of the subject.
  final String id;

  /// The name of the subject.
  String name;

  /// The list of grades in the subject.
  final List<Grade> grades;

  /// The color of the subject.
  Color color;

  /// Whether the subject is a major subject.
  bool isLk;

  /// Creates a [Subject] instance.
  Subject(
      {required this.id,
      required this.name,
      required this.grades,
      this.color = Colors.blue,
      this.isLk = false});

  /// The average grade of the subject.
  double get averageGrade {
    /*    if (grades.isEmpty) return 0.0;
    double sum =
        grades.fold(0.0, (sum, grade) => sum + grade.value * grade.weight);
    double weightSum = grades.fold(0.0, (sum, grade) => sum + grade.weight);
    return sum / weightSum;*/

    if (grades.isEmpty) return 0.0;
    double sumSmall = grades.fold(0.0,
        (sum, grade) => grade.isBig ? sum : sum + grade.value * grade.weight);
    double weightSmall = grades.fold(
        0.0, (sum, grade) => grade.isBig ? sum : sum + grade.weight);
    double sumBig = grades.fold(
        0.0,
        (sum, grade) => grade.isBig
            ? sum + grade.value * grade.weight
            : sum); //TODO: oder hier fehler werfen falls mehr als 1 großer leistungsnachweis eingetragen ist?
    double weightBig = grades.fold(
        0.0, (sum, grade) => grade.isBig ? sum + grade.weight : sum);
    if (weightSmall == 0) return sumBig / weightBig;
    if (weightBig == 0) return sumSmall / weightSmall;
    double smallGrade = sumSmall / weightSmall;
    double bigGrade = sumBig / weightBig;
    return (smallGrade + bigGrade) / 2;
  }

  /// The average grade of the subject in a specific semester.
  double averageGradeSemester(Semester semester) {
    List<Grade> semesterGrades =
        grades.where((grade) => grade.semester == semester).toList();
    if (semesterGrades.isEmpty) return 0.0;
    double sumSmall = semesterGrades.fold(0.0,
        (sum, grade) => grade.isBig ? sum : sum + grade.value * grade.weight);
    double weightSmall = semesterGrades.fold(
        0.0, (sum, grade) => grade.isBig ? sum : sum + grade.weight);
    double sumBig = semesterGrades.fold(0.0,
        (sum, grade) => grade.isBig ? sum + grade.value * grade.weight : sum);
    double weightBig = semesterGrades.fold(
        0.0, (sum, grade) => grade.isBig ? sum + grade.weight : sum);
    if (weightSmall == 0) return sumBig / weightBig;
    if (weightBig == 0) return sumSmall / weightSmall;
    double smallGrade = sumSmall / weightSmall;
    double bigGrade = sumBig / weightBig;
    return (smallGrade + bigGrade) / 2;
  }

  /// The global average grade of the subject across all semesters.
  double get globalAverage {
    if (grades.isEmpty) return 0.0;
    double sum = averageGradeSemester(Semester.first) +
        averageGradeSemester(Semester.second) +
        averageGradeSemester(Semester.third) +
        averageGradeSemester(Semester.fourth);
    int lengthWithout0 =
        Set<Semester>.from(grades.map((grade) => grade.semester)).length;
    return lengthWithout0 > 0 ? sum / lengthWithout0 : 0.0;
  }

  /// The list of grades in a specific semester.
  List<Grade> semesterGrades(Semester semester) {
    List<Grade> semesterGrades =
        grades.where((grade) => grade.semester == semester).toList();
    return semesterGrades;
  }

  /// Whether the subject has a big grade.
  bool get hasBigGrade {
    return grades.any((grade) => grade.type == GradeType.big);
  }

  /// The amount of grades in the subject.
  int get amountGrades {
    return grades.length;
  }

  /// Sets the new name of the subject.
  void setNewName(String newName) {
    name = newName;
  }

  /// Sets the new color of the subject.
  void setNewColor(Color newColor) {
    color = newColor;
  }

  /// Sets whether the subject is a major subject.
  void setIsLk(bool isLk) {
    isLk = isLk;
  }

  /// Converts the [Subject] to a JSON object.
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

  /// Creates a [Subject] from a JSON object.
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

  /// Creates a copy of this [Subject] with the given fields replaced
  /// with the new values.
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
