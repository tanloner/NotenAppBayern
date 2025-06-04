import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grade.dart';
import '../models/subject.dart';

class AppState extends ChangeNotifier {
  List<Subject> _subjects = [];
  double _targetGrade = 15.0;
  bool _isDarkMode = false;
  String _currentSemester = '1. Halbjahr 2024/25';

  List<Subject> get subjects => _subjects;
  double get targetGrade => _targetGrade;
  bool get isDarkMode => _isDarkMode;
  String get currentSemester => _currentSemester;

  double get overallAverage {
    if (_subjects.isEmpty) return 0.0;
    double sum =
        _subjects.fold(0.0, (sum, subject) => sum + subject.averageGrade);
    return sum / _subjects.length;
  }

  double get progressToTarget {
    return (overallAverage / _targetGrade).clamp(0.0, 1.0);
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    _saveData();
  }

  void setSemester(String semester) {
    _currentSemester = semester;
    notifyListeners();
    _saveData();
  }

  void addSubject(Subject subject) {
    _subjects.add(subject);
    notifyListeners();
    _saveData();
  }

  void removeSubject(String subjectId) {
    _subjects.removeWhere((subject) => subject.id == subjectId);
    notifyListeners();
    _saveData();
  }

  void updateSubject(Subject updatedSubject) {
    int index = _subjects.indexWhere((s) => s.id == updatedSubject.id);
    if (index != -1) {
      _subjects[index] = updatedSubject;
      notifyListeners();
      _saveData();
    }
  }

  void addGradeToSubject(String subjectId, Grade grade) {
    Subject? subject = _subjects.firstWhere((s) => s.id == subjectId);
    subject.grades.add(grade);
    notifyListeners();
    _saveData();
  }

  void setTargetGrade(double target) {
    _targetGrade = target;
    notifyListeners();
    _saveData();
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson = prefs.getString('subjects');
      final target = prefs.getDouble('targetGrade') ?? 15.0;
      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      final isDark = prefs.getBool('isDarkMode') ?? false;
      final semester =
          prefs.getString('currentSemester') ?? '1. Halbjahr 2024/25';

      _isDarkMode = isDark;
      _currentSemester = semester;

      if (subjectsJson != null) {
        final List<dynamic> decoded = json.decode(subjectsJson);
        _subjects = decoded.map((s) => Subject.fromJson(s)).toList();
      } else if (isFirstLaunch) {
        _subjects = _createInitialSubjects();
        await prefs.setBool('isFirstLaunch', false);
        _saveData();
      }

      _targetGrade = target;
      notifyListeners();
    } catch (e) {
      print('Fehler beim Laden der Daten: $e');
    }
  }

  List<Subject> _createInitialSubjects() {
    return [
      Subject(
        id: 'deutsch-initial',
        name: 'Deutsch',
        color: Colors.red,
        grades: [],
      ),
      Subject(
        id: 'mathe-initial',
        name: 'Mathematik',
        color: Colors.blue,
        grades: [],
      ),
    ];
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson =
          json.encode(_subjects.map((s) => s.toJson()).toList());
      await prefs.setString('subjects', subjectsJson);
      await prefs.setDouble('targetGrade', _targetGrade);
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setString('currentSemester', _currentSemester);
    } catch (e) {
      print('Fehler beim Speichern der Daten: $e');
    }
  }
}
