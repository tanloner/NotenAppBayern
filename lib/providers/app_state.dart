import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/calendar_event.dart';
import '../models/grade.dart';
import '../models/subject.dart';

/// The state of the application.
///
/// This class manages the subjects, calendar events, and other application-wide
/// settings.
class AppState extends ChangeNotifier {
  List<Subject> _subjects = [];
  List<CalendarEvent> _calendarEvents = [];
  double _targetGrade = 15.0;
  bool _isDarkMode = false;
  String _currentSemester =
      '1. Halbjahr'; //TODO: init depending on current date
  bool _isFirstLaunch = true;

  /// The list of subjects.
  List<Subject> get subjects => _subjects;

  /// The list of calendar events.
  List<CalendarEvent> get calendarEvents => _calendarEvents;

  /// The target grade.
  double get targetGrade => _targetGrade;

  /// Whether the application is in dark mode.
  bool get isDarkMode => _isDarkMode;

  /// The current semester.
  String get currentSemester => _currentSemester;

  /// Whether this is the first time the application is launched.
  bool get isFirstLaunch => _isFirstLaunch;

  /// The list of upcoming events in the next two weeks.
  List<CalendarEvent> get upcomingEvents {
    final now = DateTime.now();
    final twoWeeksFromNow = now.add(const Duration(days: 14));

    return _calendarEvents.where((event) {
      return event.date.isAfter(now.subtract(const Duration(days: 1))) &&
          event.date.isBefore(twoWeeksFromNow.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// The list of events for a specific date.
  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _calendarEvents.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  /// The overall average grade for the current semester.
  double get overallAverage {
    if (_subjects.isEmpty) return 0.0;
    double sum = _subjects.fold(
        0.0, (sum, subject) => sum + subject.averageGradeSemester(semester));

    int lengthWithout0 =
        _subjects.where((subject) => subject.amountGrades != 0).length;
    return lengthWithout0 > 0 ? sum / lengthWithout0 : 0.0;
  }

  /// The overall average grade across all semesters.
  double get allSemestersOverallAverageWrong {
    //muss man anders berechnen... (TODO!!)
    if (_subjects.isEmpty) return 0.0;
    double sum =
        _subjects.fold(0.0, (sum, subject) => sum + subject.averageGrade);
    int lengthWithout0 =
        _subjects.where((subject) => subject.amountGrades != 0).length;
    return lengthWithout0 > 0 ? sum / lengthWithout0 : 0.0;
  }

  /// The overall average grade across all semesters.
  double get allSemestersOverallAverage {
    if (_subjects.isEmpty) return 0.0;
    double sum =
        _subjects.fold(0.0, (sum, subject) => subject.globalAverage + sum);
    int lengthWithout0 =
        _subjects.where((subject) => subject.amountGrades != 0).length;
    return lengthWithout0 > 0 ? sum / lengthWithout0 : 0.0;
  }

  /// The progress towards the target grade.
  double get progressToTarget {
    return (overallAverage / _targetGrade).clamp(0.0, 1.0);
  }

  /// The current semester.
  Semester get semester {
    return Semester.fromString(_currentSemester);
  }

  /// Calculates the semester average with a temporary grade.
  double calculateSemesterAverageWithTemporaryGrade(
      Subject subject, Grade temporaryGrade) {
    if (_subjects.isEmpty) return 0.0;
    double sum = _subjects.fold(
        0.0,
        (sum, sub) => (sub != subject)
            ? sum + sub.averageGradeSemester(semester)
            : sum +
                calculateSubjectAverageWithTemporaryGrade(
                    subject, temporaryGrade));

    int lengthWithout0 = _subjects
        .where((sub) => (sub.amountGrades != 0) || (sub == subject))
        .length;
    return lengthWithout0 > 0 ? sum / lengthWithout0 : 0.0;
  }

  /// Calculates the subject average with a temporary grade.
  double calculateSubjectAverageWithTemporaryGrade(
      Subject subject, Grade temporaryGrade) {
    List<Grade> grades = subject.semesterGrades(semester);
    grades.add(temporaryGrade);

    if (grades.isEmpty) return 0.0;
    double sumSmall = grades.fold(0.0,
        (sum, grade) => grade.isBig ? sum : sum + grade.value * grade.weight);
    double weightSmall = grades.fold(
        0.0, (sum, grade) => grade.isBig ? sum : sum + grade.weight);
    double sumBig = grades.fold(0.0,
        (sum, grade) => grade.isBig ? sum + grade.value * grade.weight : sum);
    double weightBig = grades.fold(
        0.0, (sum, grade) => grade.isBig ? sum + grade.weight : sum);
    if (weightSmall == 0) return sumBig / weightBig;
    if (weightBig == 0) return sumSmall / weightSmall;
    double smallGrade = sumSmall / weightSmall;
    double bigGrade = sumBig / weightBig;
    return (smallGrade + bigGrade) / 2;
  }

  /// Sets the dark mode.
  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    _saveData();
  }

  /// Sets whether this is the first time the application is launched.
  void setFirstLaunch(bool value) {
    _isFirstLaunch = value;
    notifyListeners();
    _saveData();
  }

  /// Sets the current semester.
  void setSemester(String semester) {
    _currentSemester = semester;
    notifyListeners();
    _saveData();
  }

  /// Adds a subject.
  void addSubject(Subject subject) {
    _subjects.add(subject);
    notifyListeners();
    _saveData();
  }

  /// Removes a subject.
  void removeSubject(String subjectId) {
    _subjects.removeWhere((subject) => subject.id == subjectId);
    _calendarEvents.removeWhere((event) => event.subjectId == subjectId);
    notifyListeners();
    _saveData();
  }

  /// Updates a subject.
  void updateSubject(Subject updatedSubject) {
    int index = _subjects.indexWhere((s) => s.id == updatedSubject.id);
    if (index != -1) {
      _subjects[index] = updatedSubject;
      notifyListeners();
      _saveData();
    }
  }

  /// Adds a grade to a subject.
  void addGradeToSubject(String subjectId, Grade grade) {
    Subject? subject = _subjects.firstWhere((s) => s.id == subjectId);
    subject.grades.add(grade);
    notifyListeners();
    _saveData();
  }

  /// Removes a grade from a subject.
  void removeGradeFromSubject(Subject subject, String gradeId) {
    bool isgrade(Grade grade) {
      return grade.id == gradeId;
    }

    subject.grades.removeWhere(isgrade);
    notifyListeners();
    _saveData();
  }

  /// Adds a calendar event.
  void addCalendarEvent(CalendarEvent event) {
    _calendarEvents.add(event);
    notifyListeners();
    _saveData();
  }

  /// Removes a calendar event.
  void removeCalendarEvent(String eventId) {
    _calendarEvents.removeWhere((event) => event.id == eventId);
    notifyListeners();
    _saveData();
  }

  /// Updates a calendar event.
  void updateCalendarEvent(CalendarEvent updatedEvent) {
    int index = _calendarEvents.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _calendarEvents[index] = updatedEvent;
      notifyListeners();
      _saveData();
    }
  }

  /// Sets the target grade.
  void setTargetGrade(double target) {
    _targetGrade = target;
    notifyListeners();
    _saveData();
  }

  /// Loads the application data from shared preferences.
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson = prefs.getString('subjects');
      final eventsJson = prefs.getString('calendarEvents');
      final target = prefs.getDouble('targetGrade') ?? 15.0;
      _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      final isDark = prefs.getBool('isDarkMode') ?? false;
      final semester =
          prefs.getString('currentSemester') ?? '1. Halbjahr';

      _isDarkMode = isDark;
      _currentSemester = semester;

      if (subjectsJson != null) {
        final List<dynamic> decoded = json.decode(subjectsJson);
        _subjects = decoded.map((s) => Subject.fromJson(s)).toList();
      }

      if (eventsJson != null) {
        final List<dynamic> decoded = json.decode(eventsJson);
        _calendarEvents =
            decoded.map((e) => CalendarEvent.fromJson(e)).toList();
      }

      _targetGrade = target;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Fehler beim Laden der Daten: $e');
      }
    }
  }

  /// Saves the application data to shared preferences.
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

  /// Notifies listeners and saves the data.
  void updateStuff() {
    notifyListeners();
    _saveData();
  }
}
