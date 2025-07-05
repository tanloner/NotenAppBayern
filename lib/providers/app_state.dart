import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grade.dart';
import '../models/subject.dart';
import '../models/calendar_event.dart';

class AppState extends ChangeNotifier {
  List<Subject> _subjects = [];
  List<CalendarEvent> _calendarEvents = [];
  double _targetGrade = 15.0;
  bool _isDarkMode = false;
  String _currentSemester = '1. Halbjahr 2024/25'; //TODO: init depending on current date
  bool _isFirstLaunch = true;

  List<Subject> get subjects => _subjects;
  List<CalendarEvent> get calendarEvents => _calendarEvents;
  double get targetGrade => _targetGrade;
  bool get isDarkMode => _isDarkMode;
  String get currentSemester => _currentSemester;
  bool get isFirstLaunch => _isFirstLaunch;

  List<CalendarEvent> get upcomingEvents {
    final now = DateTime.now();
    final twoWeeksFromNow = now.add(const Duration(days: 14));

    return _calendarEvents.where((event) {
      return event.date.isAfter(now.subtract(const Duration(days: 1))) &&
          event.date.isBefore(twoWeeksFromNow.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _calendarEvents.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  double get overallAverage {
    if (_subjects.isEmpty) return 0.0;
    double sum =
    _subjects.fold(0.0, (sum, subject) => sum + subject.averageGrade);

    int lengthWithout0 =
        _subjects.where((subject) => subject.amountGrades != 0).length;
    return lengthWithout0 > 0 ? sum / lengthWithout0 : 0.0;
  }

  double get progressToTarget {
    return (overallAverage / _targetGrade).clamp(0.0, 1.0);
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    _saveData();
  }

  void setFirstLaunch(bool value) {
    _isFirstLaunch = value;
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
    _calendarEvents.removeWhere((event) => event.subjectId == subjectId);
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

  void removeGradeFromSubject(Subject subject, String gradeId) {
    bool isgrade(Grade grade) {
      return grade.id == gradeId;
    }

    subject.grades.removeWhere(isgrade);
    notifyListeners();
    _saveData();
  }

  void addCalendarEvent(CalendarEvent event) {
    _calendarEvents.add(event);
    notifyListeners();
    _saveData();
  }

  void removeCalendarEvent(String eventId) {
    _calendarEvents.removeWhere((event) => event.id == eventId);
    notifyListeners();
    _saveData();
  }

  void updateCalendarEvent(CalendarEvent updatedEvent) {
    int index = _calendarEvents.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _calendarEvents[index] = updatedEvent;
      notifyListeners();
      _saveData();
    }
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
      final eventsJson = prefs.getString('calendarEvents');
      final target = prefs.getDouble('targetGrade') ?? 15.0;
      _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      final isDark = prefs.getBool('isDarkMode') ?? false;
      final semester =
          prefs.getString('currentSemester') ?? '1. Halbjahr 2024/25';

      _isDarkMode = isDark;
      _currentSemester = semester;

      if (subjectsJson != null) {
        final List<dynamic> decoded = json.decode(subjectsJson);
        _subjects = decoded.map((s) => Subject.fromJson(s)).toList();
      }

      if (eventsJson != null) {
        final List<dynamic> decoded = json.decode(eventsJson);
        _calendarEvents = decoded.map((e) => CalendarEvent.fromJson(e)).toList();
      }

      _targetGrade = target;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Fehler beim Laden der Daten: $e');
      }
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson =
      json.encode(_subjects.map((s) => s.toJson()).toList());
      final eventsJson =
      json.encode(_calendarEvents.map((e) => e.toJson()).toList());

      await prefs.setBool('isFirstLaunch', _isFirstLaunch);
      await prefs.setString('subjects', subjectsJson);
      await prefs.setString('calendarEvents', eventsJson);
      await prefs.setDouble('targetGrade', _targetGrade);
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setString('currentSemester', _currentSemester);
    } catch (e) {
      if (kDebugMode) {
        print('Fehler beim Speichern der Daten: $e');
      }
    }
  }

  void updateStuff() {
    notifyListeners();
    _saveData();
  }
}