import 'dart:math';

import '../models/calendar_event.dart';
import '../models/grade.dart';
import '../models/subject.dart';

//TODO: überall in den analysen die "pro semester" logik hinzufügen

/// The result of an analysis.
class AnalysisResult {
  /// The title of the result.
  final String title;

  /// The value of the result.
  final dynamic value;

  /// The type of the result.
  final String type;

  /// The chart data of the result, if any.
  final List<Map<String, dynamic>>? chartData;

  /// The error of the result, if any.
  final String? error;

  /// Creates an [AnalysisResult].
  AnalysisResult({
    required this.title,
    this.value,
    required this.type,
    this.chartData,
    this.error,
  });
}

/// A data class for a list of grades.
class GradeData {
  /// The list of grades.
  final List<Grade> grades;

  /// Creates a [GradeData].
  GradeData(this.grades);

  @override
  String toString() => 'GradeData(${grades.length} grades)';
}

/// A data class for a list of subjects.
class SubjectData {
  /// The list of subjects.
  final List<Subject> subjects;

  /// Creates a [SubjectData].
  SubjectData(this.subjects);

  @override
  String toString() => 'SubjectData(${subjects.length} subjects)';
}

/// A data class for a number.
class NumberData {
  /// The value of the number.
  final double value;

  /// Creates a [NumberData].
  NumberData(this.value);

  @override
  String toString() => value.toString();
}

/// A data class for a list of items.
class ListData {
  /// The list of items.
  final List<dynamic> items;

  /// Creates a [ListData].
  ListData(this.items);

  @override
  String toString() => 'ListData(${items.length} items)';
}

/// A programmable analysis engine for analyzing grades and subjects.
class ProgrammableAnalysisEngine {
  /// The list of subjects.
  final List<Subject> subjects;

  /// The list of calendar events.
  final List<CalendarEvent> events;

  /// Creates a [ProgrammableAnalysisEngine].
  ProgrammableAnalysisEngine({required this.subjects, required this.events});

  /// A list of all grades.
  List<Grade> get allGrades => subjects.expand((s) => s.grades).toList();

  /// Executes an expression and returns the result.
  AnalysisResult executeExpression(String expression) {
    try {
      final result = _evaluateExpression(expression);
      return AnalysisResult(
        title: 'Ergebnis für: "$expression"',
        value: result,
        type: _determineResultType(result),
        chartData: _generateChartData(result),
      );
    } catch (e) {
      return AnalysisResult(
        title: 'Fehler bei: "$expression"',
        type: 'text',
        error: 'Fehler: ${e.toString()}',
      );
    }
  }

  dynamic _evaluateExpression(String expr) {
    expr = expr.trim();

    int operatorPos = _findTopLevelOperator(expr, ['+', '-']);
    if (operatorPos != -1) {
      final operator = expr[operatorPos];
      final leftExpr = expr.substring(0, operatorPos).trim();
      final rightExpr = expr.substring(operatorPos + 1).trim();

      final left = _getNumber(_evaluateExpression(leftExpr));
      final right = _getNumber(_evaluateExpression(rightExpr));

      switch (operator) {
        case '+':
          return NumberData(left + right);
        case '-':
          return NumberData(left - right);
      }
    }

    operatorPos = _findTopLevelOperator(expr, ['*', '/']);
    if (operatorPos != -1) {
      final operator = expr[operatorPos];
      final leftExpr = expr.substring(0, operatorPos).trim();
      final rightExpr = expr.substring(operatorPos + 1).trim();

      final left = _getNumber(_evaluateExpression(leftExpr));
      final right = _getNumber(_evaluateExpression(rightExpr));

      switch (operator) {
        case '*':
          return NumberData(left * right);
        case '/':
          if (right == 0) throw Exception('Division by zero');
          return NumberData(left / right);
      }
    }
    return _evaluatePrimaryExpression(expr);
  }

  int _findTopLevelOperator(String expr, List<String> operators) {
    int parenDepth = 0;
    bool inQuotes = false;
    for (int i = expr.length - 1; i >= 0; i--) {
      final char = expr[i];

      if (char == '"' && (i == 0 || expr[i - 1] != '\\')) {
        inQuotes = !inQuotes;
      } else if (!inQuotes) {
        if (char == ')') {
          parenDepth++;
        } else if (char == '(') {
          parenDepth--;
        } else if (parenDepth == 0 && operators.contains(char)) {
          return i;
        }
      }
    }
    return -1;
  }

  dynamic _evaluatePrimaryExpression(String expr) {
    expr = expr.trim();

    if (expr.startsWith('(') && expr.endsWith(')')) {
      return _evaluateExpression(expr.substring(1, expr.length - 1));
    }

    if (_isFunctionCall(expr)) {
      return _evaluateFunction(expr);
    }

    return _evaluateLiteral(expr);
  }

  bool _isFunctionCall(String expr) {
    return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*\s*\(.*\)
).hasMatch(expr);
  }

  dynamic _evaluateFunction(String expr) {
    final match =
        RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s*\((.*)\)
).firstMatch(expr);
    if (match == null) throw Exception('Invalid function call: $expr');

    final functionName = match.group(1)!;
    final argsString = match.group(2)!;
    final args = _parseArguments(argsString);

    return _callFunction(functionName, args);
  }

  List<dynamic> _parseArguments(String argsString) {
    argsString = argsString.trim();
    if (argsString.isEmpty) return [];

    final args = <dynamic>[];
    final parts = _splitArguments(argsString);

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty) {
        args.add(_evaluateExpression(trimmed));
      }
    }
    return args;
  }

  List<String> _splitArguments(String argsString) {
    final parts = <String>[];
    final buffer = StringBuffer();
    int parenDepth = 0;
    int bracketDepth = 0;
    bool inQuotes = false;

    for (int i = 0; i < argsString.length; i++) {
      final char = argsString[i];

      if (char == '"' && (i == 0 || argsString[i - 1] != '\\')) {
        inQuotes = !inQuotes;
      } else if (!inQuotes) {
        if (char == '(') {
          parenDepth++;
        } else if (char == ')') {
          parenDepth--;
        } else if (char == '[') {
          bracketDepth++;
        } else if (char == ']') {
          bracketDepth--;
        } else if ((char == ';' || char == ',') &&
            parenDepth == 0 &&
            bracketDepth == 0) {
          parts.add(buffer.toString().trim());
          buffer.clear();
          continue;
        }
      }
      buffer.write(char);
    }
    if (buffer.isNotEmpty) {
      parts.add(buffer.toString().trim());
    }
    return parts;
  }

  dynamic _evaluateLiteral(String expr) {
    expr = expr.trim();

    final number = double.tryParse(expr);
    if (number != null) return NumberData(number);

    if (expr.startsWith('"') && expr.endsWith('"')) {
      return expr.substring(1, expr.length - 1);
    }

    if (expr.startsWith('[') && expr.endsWith(']')) {
      final content = expr.substring(1, expr.length - 1);
      if (content.trim().isEmpty) return ListData([]);

      final items = _splitArguments(content);
      final evaluatedItems =
          items.map((item) => _evaluateExpression(item.trim())).toList();
      return ListData(evaluatedItems);
    }

    throw Exception('Unknown or invalid literal: $expr');
  }

  dynamic _callFunction(String functionName, List<dynamic> args) {
    switch (functionName.toLowerCase()) {
      case 'subject':
        return _functionSubject(args);
      case 'all_subjects':
        return _functionAllSubjects(args);
      case 'grades':
        return _functionGrades(args);
      case 'all_grades':
        return _functionAllGrades(args);

      case 'average':
      case 'avg':
        return _functionAverage(args);
      case 'sum':
        return _functionSum(args);
      case 'count':
        return _functionCount(args);
      case 'min':
        return _functionMin(args);
      case 'max':
        return _functionMax(args);
      case 'median':
        return _functionMedian(args);

      case 'concat':
        return _functionConcat(args);
      case 'sort':
        return _functionSort(args);
      case 'take':
        return _functionTake(args);
      case 'skip':
        return _functionSkip(args);

      case 'show_num':
      case 'show_number':
        return _functionShowNumber(args);
      case 'show_bars':
        return _functionShowBars(args);
      case 'show_list':
        return _functionShowList(args);
      case 'show_line':
        return _functionShowLine(args);
      case 'show_pie':
        return _functionShowPie(args);
      case 'show_subjects':
        return _functionShowSubjects(args);

      case 'debug':
      case 'info':
        return _functionDebug(args);

      default:
        throw Exception('Unknown function: $functionName');
    }
  }

  dynamic _functionShowLine(List<dynamic> args) {
    if (args.isEmpty) throw Exception('show_line() requires data');

    if (args[0] is GradeData) {
      final gradeData = args[0] as GradeData;
      final chartData = <Map<String, dynamic>>[];

      final sortedGrades = List<Grade>.from(gradeData.grades)
        ..sort((a, b) => a.date.compareTo(b.date));

      for (int i = 0; i < sortedGrades.length; i++) {
        final grade = sortedGrades[i];

        final gradesUpToNow = sortedGrades.take(i + 1).toList();
        final totalWeighted =
            gradesUpToNow.fold(0.0, (sum, g) => sum + (g.value * g.weight));
        final totalWeight = gradesUpToNow.fold(0.0, (sum, g) => sum + g.weight);
        final average = totalWeight > 0 ? totalWeighted / totalWeight : 0.0;

        chartData.add({
          'date': grade.date.toIso8601String().substring(0, 10),
          // YYYY-MM-DD format
          'grade': grade.value,
          'average': average,
        });
      }

      return {'type': 'chart_data', 'chartType': 'line', 'data': chartData};
    }

    throw Exception('show_line() currently only supports GradeData');
  }

  dynamic _functionShowPie(List<dynamic> args) {
    if (args.isEmpty) throw Exception('show_pie() requires data');

    if (args[0] is GradeData) {
      final gradeData = args[0] as GradeData;
      final chartData = <Map<String, dynamic>>[];

      final ranges = [
        {'min': 13, 'max': 15, 'range': '13-15', 'description': 'Sehr gut'},
        {'min': 10, 'max': 12, 'range': '10-12', 'description': 'Gut'},
        {'min': 7, 'max': 9, 'range': '7-9', 'description': 'Befriedigend'},
        {'min': 4, 'max': 6, 'range': '4-6', 'description': 'Ausreichend'},
        {'min': 0, 'max': 3, 'range': '0-3', 'description': 'Mangelhaft'},
      ];

      for (final range in ranges) {
        final count = gradeData.grades
            .where((grade) =>
                grade.value >= (range['min']! as num) &&
                grade.value <= (range['max']! as num))
            .length;

        if (count > 0) {
          chartData.add({
            'count': count,
            'range': range['range'],
            'description': range['description'],
          });
        }
      }

      return {'type': 'chart_data', 'chartType': 'pie', 'data': chartData};
    }

    throw Exception('show_pie() currently only supports GradeData');
  }

  dynamic _functionShowSubjects(List<dynamic> args) {
    if (args.isEmpty) throw Exception('show_subjects() requires data');

    if (args[0] is SubjectData) {
      final subjectData = args[0] as SubjectData;
      final chartData = <Map<String, dynamic>>[];

      for (final subject in subjectData.subjects) {
        if (subject.grades.isNotEmpty) {
          chartData.add({
            'label': subject.name,
            'value': subject.averageGrade,
          });
        }
      }

      return {'type': 'chart_data', 'chartType': 'bar', 'data': chartData};
    }

    throw Exception('show_subjects() currently only supports SubjectData');
  }

  dynamic _functionSubject(List<dynamic> args) {
    if (args.isEmpty) throw Exception('subject() requires a subject name');
    String name = args[0].toString();
    if (name.startsWith('"') && name.endsWith('"')) {
      name = name.substring(1, name.length - 1);
    }
    final subject = subjects.firstWhere(
      (s) => s.name.toLowerCase().contains(name.toLowerCase()),
      orElse: () => throw Exception('Subject "$name" not found'),
    );
    return SubjectData([subject]);
  }

  dynamic _functionAllSubjects(List<dynamic> args) => SubjectData(subjects);

  dynamic _functionGrades(List<dynamic> args) {
    if (args.isEmpty || args[0] is! SubjectData) {
      throw Exception(
          'grades() requires a SubjectData argument. Try grades(subject("Name")).');
    }
    final subjectData = args[0] as SubjectData;
    final allGrades = subjectData.subjects.expand((s) => s.grades).toList();
    return GradeData(allGrades);
  }

  dynamic _functionAllGrades(List<dynamic> args) => GradeData(allGrades);

  dynamic _functionAverage(List<dynamic> args) {
    if (args.isEmpty) throw Exception('average() requires data');
    final data = args[0];

    if (data is GradeData) {
      if (data.grades.isEmpty) return NumberData(0.0);
      final totalWeighted =
          data.grades.fold(0.0, (sum, g) => sum + (g.value * g.weight));
      final totalWeight = data.grades.fold(0.0, (sum, g) => sum + g.weight);
      return NumberData(totalWeight > 0 ? totalWeighted / totalWeight : 0.0);
    }
    if (data is SubjectData) {
      if (data.subjects.isEmpty) return NumberData(0.0);
      final avg = data.subjects.fold(0.0, (sum, s) => sum + s.averageGrade) /
          data.subjects.length;
      return NumberData(avg);
    }
    if (data is ListData) {
      if (data.items.isEmpty) return NumberData(0.0);
      final numbers = data.items.map((item) => _getNumber(item)).toList();
      return NumberData(numbers.reduce((a, b) => a + b) / numbers.length);
    }
    throw Exception(
        'average() cannot process this data type: ${data.runtimeType}');
  }

  dynamic _functionCount(List<dynamic> args) {
    if (args.isEmpty) throw Exception('count() requires data');
    final data = args[0];

    if (data is GradeData) return NumberData(data.grades.length.toDouble());
    if (data is SubjectData) return NumberData(data.subjects.length.toDouble());
    if (data is ListData) return NumberData(data.items.length.toDouble());

    throw Exception(
        'count() cannot process this data type: ${data.runtimeType}');
  }

  dynamic _functionSum(List<dynamic> args) {
    if (args.isEmpty) throw Exception('sum() requires data');
    final data = args[0];

    if (data is GradeData) {
      return NumberData(data.grades.fold(0.0, (sum, g) => sum + g.value));
    }
    if (data is ListData) {
      if (data.items.isEmpty) return NumberData(0.0);
      final numbers = data.items.map((item) => _getNumber(item)).toList();
      return NumberData(numbers.reduce((a, b) => a + b));
    }
    throw Exception('sum() cannot process this data type: ${data.runtimeType}');
  }

  dynamic _functionMin(List<dynamic> args) {
    if (args.isEmpty) throw Exception('min() requires data');
    final data = args[0];

    if (data is GradeData) {
      if (data.grades.isEmpty) return NumberData(0.0);
      return NumberData(data.grades.map((g) => g.value).reduce(min).toDouble());
    }
    if (data is ListData) {
      if (data.items.isEmpty) return NumberData(0.0);
      return NumberData(data.items.map((i) => _getNumber(i)).reduce(min));
    }
    throw Exception('min() cannot process this data type: ${data.runtimeType}');
  }

  dynamic _functionMax(List<dynamic> args) {
    if (args.isEmpty) throw Exception('max() requires data');
    final data = args[0];

    if (data is GradeData) {
      if (data.grades.isEmpty) return NumberData(0.0);
      return NumberData(data.grades.map((g) => g.value).reduce(max).toDouble());
    }
    if (data is ListData) {
      if (data.items.isEmpty) return NumberData(0.0);
      return NumberData(data.items.map((i) => _getNumber(i)).reduce(max));
    }
    throw Exception('max() cannot process this data type: ${data.runtimeType}');
  }

  dynamic _functionMedian(List<dynamic> args) {
    if (args.isEmpty) throw Exception('median() requires data');
    List<double> values = [];

    final data = args[0];
    if (data is GradeData) {
      if (data.grades.isEmpty) return NumberData(0.0);
      values = data.grades.map((g) => g.value.toDouble()).toList();
    } else if (data is ListData) {
      if (data.items.isEmpty) return NumberData(0.0);
      values = data.items.map((i) => _getNumber(i)).toList();
    } else {
      throw Exception(
          'median() cannot process this data type: ${data.runtimeType}');
    }

    values.sort();
    final middle = values.length ~/ 2;
    if (values.length % 2 == 0) {
      return NumberData((values[middle - 1] + values[middle]) / 2);
    } else {
      return NumberData(values[middle]);
    }
  }

  dynamic _functionConcat(List<dynamic> args) {
    if (args.length < 2) {
      throw Exception('concat() requires at least 2 arguments');
    }
    if (args.every((arg) => arg is GradeData)) {
      final allGrades =
          args.expand((arg) => (arg as GradeData).grades).toList();
      return GradeData(allGrades);
    }
    if (args.every((arg) => arg is ListData)) {
      final allItems = args.expand((arg) => (arg as ListData).items).toList();
      return ListData(allItems);
    }
    throw Exception(
        'concat() requires all arguments to be of the same compatible type (GradeData or ListData)');
  }

  dynamic _functionSort(List<dynamic> args) {
    if (args.isEmpty) throw Exception('sort() requires data');
    final data = args[0];

    if (data is GradeData) {
      final sorted = List<Grade>.from(data.grades)
        ..sort((a, b) => a.value.compareTo(b.value));
      return GradeData(sorted);
    }
    if (data is ListData) {
      final sorted = List<dynamic>.from(data.items)
        ..sort((a, b) => _getNumber(a).compareTo(_getNumber(b)));
      return ListData(sorted);
    }
    throw Exception(
        'sort() cannot process this data type: ${data.runtimeType}');
  }

  dynamic _functionTake(List<dynamic> args) {
    if (args.length != 2) throw Exception('take() requires data and a count');
    final count = _getNumber(args[1]).toInt();
    final data = args[0];

    if (data is GradeData) return GradeData(data.grades.take(count).toList());
    if (data is ListData) return ListData(data.items.take(count).toList());

    throw Exception(
        'take() cannot process this data type: ${data.runtimeType}');
  }

  dynamic _functionSkip(List<dynamic> args) {
    if (args.length != 2) throw Exception('skip() requires data and a count');
    final count = _getNumber(args[1]).toInt();
    final data = args[0];

    if (data is GradeData) return GradeData(data.grades.skip(count).toList());
    if (data is ListData) return ListData(data.items.skip(count).toList());

    throw Exception(
        'skip() cannot process this data type: ${data.runtimeType}');
  }

  dynamic _functionShowNumber(List<dynamic> args) {
    if (args.isEmpty) throw Exception('show_number() requires a number');
    final number = _getNumber(args[0]);
    return {'type': 'number_display', 'value': number};
  }

  dynamic _functionShowBars(List<dynamic> args) {
    if (args.isEmpty) throw Exception('show_bars() requires data');
    if (args[0] is ListData) {
      final listData = args[0] as ListData;
      final chartData = <Map<String, dynamic>>[];
      for (int i = 0; i < listData.items.length; i++) {
        final value = _getNumber(listData.items[i]);
        chartData.add({'label': 'Item ${i + 1}', 'value': value});
      }
      return {'type': 'chart_data', 'chartType': 'bar', 'data': chartData};
    }
    throw Exception('show_bars() currently only supports ListData');
  }

  dynamic _functionShowList(List<dynamic> args) {
    if (args.isEmpty) throw Exception('show_list() requires data');
    final items = <String>[];
    final data = args[0];

    if (data is GradeData) {
      items.addAll(data.grades.map(
          (g) => 'Grade: ${g.value} (Weight: ${g.weight}) - ${g.description}'));
    } else if (data is SubjectData) {
      items.addAll(data.subjects.map((s) =>
          'Subject: ${s.name} (Avg: ${s.averageGrade.toStringAsFixed(2)})'));
    } else if (data is ListData) {
      items.addAll(data.items.map((i) => i.toString()));
    } else {
      throw Exception(
          'show_list() cannot process this data type: ${data.runtimeType}');
    }

    return {'type': 'list', 'items': items};
  }

  dynamic _functionDebug(List<dynamic> args) {
    final info = <String>[
      'Subjects: ${subjects.length} (${subjects.map((s) => s.name).join(", ")})',
      'Total Grades: ${allGrades.length}',
      'Calendar Events: ${events.length}',
    ];
    return {'type': 'debug_info', 'info': info};
  }

  double _getNumber(dynamic value) {
    if (value is NumberData) return value.value;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw Exception(
        'Cannot convert ${value.runtimeType} to a number: "$value"');
  }

  String _determineResultType(dynamic result) {
    if (result is Map && result.containsKey('type')) {
      return result['type'];
    }
    if (result is NumberData) return 'number';
    if (result is GradeData) return 'list';
    if (result is SubjectData) return 'list';
    if (result is ListData) return 'list';
    if (result is String) return 'text';

    return 'text';
  }

  List<Map<String, dynamic>>? _generateChartData(dynamic result) {
    if (result is Map && result.containsKey('data') && result['data'] is List) {
      return (result['data'] as List).cast<Map<String, dynamic>>();
    }
    return null;
  }

  /// A list of strings that explain how to use the programmable analysis language.
  static List<String> get programmingHelpText => [
        //TODO: a help function for each function
        'PROGRAMMABLE ANALYSIS LANGUAGE (v2)',
        'This engine evaluates expressions with standard math order of operations.',
        '',
        'DATA FUNCTIONS:',
        '  subject("Name")       - Get a specific subject by name.',
        '  all_subjects()        - Get all subjects.',
        '  grades(subject_data)  - Get grades from a subject. e.g. grades(subject("Math"))',
        '  all_grades()          - Get all grades from all subjects.',
        '',
        'MATH FUNCTIONS:',
        '  average(data)         - Calculates the average (works on GradeData, SubjectData, ListData).',
        '  avg(data)             - Alias for average(data).',
        '  sum(data)             - Calculates the sum (works on GradeData, ListData).',
        '  count(data)           - Counts items (GradeData, SubjectData, ListData).',
        '  min(data)             - Finds the minimum value (works on GradeData, ListData).',
        '  max(data)             - Finds the maximum value (works on GradeData, ListData).',
        '  median(data)          - Finds the median value (works on GradeData, ListData).',
        '',
        'LIST FUNCTIONS:',
        '  concat(d1, d2, ...)   - Combines multiple lists/data sets of the same type (GradeData or ListData).',
        '  sort(data)            - Sorts data by value (GradeData, ListData).',
        '  take(data, count)     - Takes the first N items from data (GradeData, ListData).',
        '  skip(data, count)     - Skips the first N items from data (GradeData, ListData).',
        '',
        'DISPLAY FUNCTIONS:',
        '  show_num(number)      - Displays a single number. e.g. show_num(average(all_grades()))',
        '  show_number(number)   - Alias for show_num(number).',
        '  show_bars(list_data)  - Displays data as a bar chart. e.g. show_bars([10, 20, 15])',
        '  show_line(grade_data) - Shows grade progression over time as line chart. e.g. show_line(grades(subject("Math")))',
        '  show_pie(grade_data)  - Shows grade distribution as pie chart. e.g. show_pie(all_grades())',
        '  show_subjects(subj_data) - Shows subject averages as bar chart. e.g. show_subjects(all_subjects())',
        '  show_list(data)       - Displays data as a formatted list (GradeData, SubjectData, ListData).',
        '',
        'UTILITY FUNCTIONS:',
        '  debug()               - Shows debugging information about subjects, grades, and events.',
        '  info()                - Alias for debug().',
        '',
        'LITERALS:',
        '  Numbers: 5.0, 15',
        '  Strings: "Hello World"',
        '  Lists:   [1.0, 2.0, 3.0] (use comma or semicolon as separator for items)',
        '',
        'OPERATORS:',
        '  Standard math operators: +, -, *, / (evaluated with correct precedence)',
        '  Parentheses for grouping: ( )',
        '',
        'EXAMPLES:',
        '  debug()',
        '  count(all_grades()) + 2.0',
        '  average(grades(subject("Mathematik")))',
        '  max([10, count(all_grades()), 15])',
        '  show_list(sort(all_grades()))',
        '  show_bars(sort(grades(subject("Physics"))))',
        '  show_line(grades(subject("Mathematik")))',
        '  show_line(all_grades())',
        '  show_num(count(take(all_subjects(), 3)))',
      ];
}
