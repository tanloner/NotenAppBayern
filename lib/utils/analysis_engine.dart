import '../models/grade.dart';
import '../models/subject.dart';
import '../models/calendar_event.dart';

class AnalysisResult {
  final String title;
  final dynamic value;
  final String type;
  final List<Map<String, dynamic>>? chartData;
  final String? error;

  AnalysisResult({
    required this.title,
    this.value,
    required this.type,
    this.chartData,
    this.error,
  });
}

class AnalysisEngine {
  final List<Subject> subjects;
  final List<CalendarEvent> events;

  AnalysisEngine({required this.subjects, required this.events});

  List<Grade> get allGrades {
    return subjects.expand((s) => s.grades).toList();
  }

  AnalysisResult executeExpression(String expression) {
    try {
      expression = expression.trim().toLowerCase();

      if (expression.startsWith('average(') || expression.startsWith('avg(')) {
        return _handleAverage(expression);
      } else if (expression.startsWith('count(')) {
        return _handleCount(expression);
      } else if (expression.startsWith('grades_over_time')) {
        return _handleGradesOverTime(expression);
      } else if (expression.startsWith('subject_comparison')) {
        return _handleSubjectComparison(expression);
      } else if (expression.startsWith('grade_distribution')) {
        return _handleGradeDistribution(expression);
      } else if (expression.startsWith('weight_analysis')) {
        return _handleWeightAnalysis(expression);
      } else if (expression.startsWith('description_analysis')) {
        return _handleDescriptionAnalysis(expression);
      } else if (expression.startsWith('trend(')) {
        return _handleTrend(expression);
      } else if (expression.startsWith('filter(')) {
        return _handleFilter(expression);
      } else {
        return _handleSimpleCalculation(expression);
      }
    } catch (e) {
      return AnalysisResult(
        title: 'Error',
        type: 'text',
        error: 'Fehler beim Ausführen: ${e.toString()}',
      );
    }
  }

  AnalysisResult _handleAverage(String expression) {
    final content = _extractContent(expression);

    if (content == 'all' || content.isEmpty) {
      final avg = _calculateAverage(allGrades);
      return AnalysisResult(
        title: 'Gesamtdurchschnitt',
        value: avg,
        type: 'number',
      );
    } else if (content.startsWith('subject=')) {
      final subjectName = content.substring(8).replaceAll('"', '').replaceAll("'", '');
      final subject = subjects.firstWhere(
            (s) => s.name.toLowerCase().contains(subjectName),
        orElse: () => throw Exception('Fach "$subjectName" nicht gefunden'),
      );
      return AnalysisResult(
        title: 'Durchschnitt ${subject.name}',
        value: subject.averageGrade,
        type: 'number',
      );
    } else if (content.startsWith('weight=')) {
      final weight = double.parse(content.substring(7));
      final filteredGrades = allGrades.where((g) => g.weight == weight).toList();
      final avg = _calculateAverage(filteredGrades);
      return AnalysisResult(
        title: 'Durchschnitt (Gewichtung ${weight}x)',
        value: avg,
        type: 'number',
      );
    }

    throw Exception('Unbekannter Average-Parameter: $content');
  }

  AnalysisResult _handleCount(String expression) {
    final content = _extractContent(expression);

    if (content == 'all' || content.isEmpty) {
      return AnalysisResult(
        title: 'Anzahl aller Noten',
        value: allGrades.length,
        type: 'number',
      );
    } else if (content == 'subjects') {
      return AnalysisResult(
        title: 'Anzahl Fächer',
        value: subjects.length,
        type: 'number',
      );
    } else if (content.startsWith('subject=')) {
      final subjectName = content.substring(8).replaceAll('"', '').replaceAll("'", '');
      final subject = subjects.firstWhere(
            (s) => s.name.toLowerCase().contains(subjectName),
        orElse: () => throw Exception('Fach "$subjectName" nicht gefunden'),
      );
      return AnalysisResult(
        title: 'Anzahl Noten in ${subject.name}',
        value: subject.grades.length,
        type: 'number',
      );
    }

    throw Exception('Unbekannter Count-Parameter: $content');
  }

  AnalysisResult _handleGradesOverTime(String expression) {
    final sortedGrades = List<Grade>.from(allGrades)
      ..sort((a, b) => a.date.compareTo(b.date));

    final chartData = <Map<String, dynamic>>[];
    double runningAverage = 0;

    for (int i = 0; i < sortedGrades.length; i++) {
      final grade = sortedGrades[i];
      runningAverage = _calculateAverage(sortedGrades.take(i + 1).toList());

      chartData.add({
        'date': '${grade.date.day}.${grade.date.month}.',
        'grade': grade.value,
        'average': runningAverage,
        'subject': subjects.firstWhere((s) => s.grades.contains(grade)).name,
      });
    }

    return AnalysisResult(
      title: 'Noten über Zeit',
      type: 'chart_data',
      chartData: chartData,
    );
  }

  AnalysisResult _handleSubjectComparison(String expression) { //TODO: adding parameters (subject1, subject2, ...) or what kind of diagramm or stuff like that.
    final chartData = subjects.map((subject) => {
      'subject': subject.name,
      'average': subject.averageGrade,
      'count': subject.grades.length,
      'color': subject.color.value,
    }).toList();

    return AnalysisResult(
      title: 'Fächer-Vergleich',
      type: 'chart_data',
      chartData: chartData,
    );
  }

  AnalysisResult _handleGradeDistribution(String expression) {
    final gradeCounts = <String, int>{};

    for (final grade in allGrades) {
      final range = _getGradeRange(grade.value);
      gradeCounts[range] = (gradeCounts[range] ?? 0) + 1;
    }

    final chartData = gradeCounts.entries.map((entry) => {
      'range': entry.key,
      'count': entry.value,
    }).toList();

    return AnalysisResult(
      title: 'Notenverteilung',
      type: 'chart_data',
      chartData: chartData,
    );
  }

  AnalysisResult _handleWeightAnalysis(String expression) {
    final weightMap = <double, List<Grade>>{};

    for (final grade in allGrades) {
      weightMap.putIfAbsent(grade.weight, () => []).add(grade);
    }

    final chartData = weightMap.entries.map((entry) => {
      'weight': '${entry.key}x',
      'average': _calculateAverage(entry.value),
      'count': entry.value.length,
    }).toList();

    return AnalysisResult(
      title: 'Analyse nach Gewichtung',
      type: 'chart_data',
      chartData: chartData,
    );
  }

  AnalysisResult _handleDescriptionAnalysis(String expression) {
    final descriptionMap = <String, List<Grade>>{};

    for (final grade in allGrades) {
      final key = grade.description.toLowerCase();
      descriptionMap.putIfAbsent(key, () => []).add(grade);
    }

    final chartData = descriptionMap.entries
        .where((entry) => entry.value.length > 1)
        .map((entry) => {
      'description': entry.key,
      'average': _calculateAverage(entry.value),
      'count': entry.value.length,
    }).toList();

    return AnalysisResult(
      title: 'Analyse nach Beschreibung',
      type: 'chart_data',
      chartData: chartData,
    );
  }

  AnalysisResult _handleTrend(String expression) {
    final content = _extractContent(expression);

    List<Grade> targetGrades;
    String title;

    if (content.startsWith('subject=')) {
      final subjectName = content.substring(8).replaceAll('"', '').replaceAll("'", '');
      final subject = subjects.firstWhere(
            (s) => s.name.toLowerCase().contains(subjectName),
        orElse: () => throw Exception('Fach "$subjectName" nicht gefunden'),
      );
      targetGrades = subject.grades;
      title = 'Trend ${subject.name}';
    } else {
      targetGrades = allGrades;
      title = 'Gesamttrend';
    }

    final sortedGrades = List<Grade>.from(targetGrades)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedGrades.length < 2) {
      return AnalysisResult(
        title: title,
        value: 'Nicht genügend Daten für Trendanalyse',
        type: 'text',
      );
    }

    final first = sortedGrades.first.value;
    final last = sortedGrades.last.value;
    final change = last - first;

    String trendText;
    if (change > 0.5) {
      trendText = 'Steigend (+${change.toStringAsFixed(1)})';
    } else if (change < -0.5) {
      trendText = 'Fallend (${change.toStringAsFixed(1)})';
    } else {
      trendText = 'Stabil (${change.toStringAsFixed(1)})';
    }

    return AnalysisResult(
      title: title,
      value: trendText,
      type: 'text',
    );
  }

  AnalysisResult _handleFilter(String expression) {
    throw Exception('Filter-Funktion noch nicht implementiert'); //TODO: Implementieren
  }

  AnalysisResult _handleSimpleCalculation(String expression) {
    if (expression == 'subjects.length' || expression == 'anzahl_fächer') {
      return AnalysisResult(
        title: 'Anzahl Fächer',
        value: subjects.length,
        type: 'number',
      );
    } else if (expression == 'grades.length' || expression == 'anzahl_noten') {
      return AnalysisResult(
        title: 'Anzahl Noten',
        value: allGrades.length,
        type: 'number',
      );
    }

    throw Exception('Unbekannter Ausdruck: $expression');
  }

  String _extractContent(String expression) {
    final start = expression.indexOf('(') + 1;
    final end = expression.lastIndexOf(')');
    if (start > 0 && end > start) {
      return expression.substring(start, end).trim();
    }
    return '';
  }

  double _calculateAverage(List<Grade> grades) {
    if (grades.isEmpty) return 0.0;
    final totalWeightedScore = grades.fold(0.0, (sum, grade) => sum + (grade.value * grade.weight));
    final totalWeight = grades.fold(0.0, (sum, grade) => sum + grade.weight);
    return totalWeight > 0 ? totalWeightedScore / totalWeight : 0.0;
  }

  String _getGradeRange(double grade) {
    if (grade >= 13) return '13-15 (Sehr gut)';
    if (grade >= 10) return '10-12 (Gut)';
    if (grade >= 7) return '7-9 (Befriedigend)';
    if (grade >= 4) return '4-6 (Ausreichend)';
    return '0-3 (Mangelhaft)';
  }

  static List<String> get exampleExpressions => [
    'average(all)',
    'average(subject="Mathematik")',
    'count(all)',
    'count(subjects)',
    'grades_over_time',
    'subject_comparison',
    'grade_distribution',
    'weight_analysis',
    'description_analysis',
    'trend(all)',
    'trend(subject="Deutsch")',
    'average(weight=2.0)',
    'anzahl_fächer',
    'anzahl_noten',
  ];

  static List<String> get helpText => [
    'Verfügbare Funktionen:',
    '',
    'average(all) - Gesamtdurchschnitt',
    'average(subject="Name") - Durchschnitt eines Fachs',
    'average(weight=2.0) - Durchschnitt nach Gewichtung',
    '',
    'count(all) - Anzahl aller Noten',
    'count(subjects) - Anzahl der Fächer',
    'count(subject="Name") - Noten in einem Fach',
    '',
    'grades_over_time - Notenverlauf',
    'subject_comparison - Fächer vergleichen',
    'grade_distribution - Notenverteilung',
    'weight_analysis - Analyse nach Gewichtung',
    'description_analysis - Analyse nach Beschreibung',
    '',
    'trend(all) - Gesamttrend',
    'trend(subject="Name") - Trend eines Fachs',
    '',
    'Einfache Abfragen:',
    'anzahl_fächer, anzahl_noten',
  ];
}