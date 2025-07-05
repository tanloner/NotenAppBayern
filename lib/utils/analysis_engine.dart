import 'dart:math';

import '../models/calendar_event.dart';
import '../models/grade.dart';
import '../models/subject.dart';

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

class GradeData {
  final List<Grade> grades;
  GradeData(this.grades);

  @override
  String toString() => 'GradeData(${grades.length} grades)';
}

class SubjectData {
  final List<Subject> subjects;
  SubjectData(this.subjects);

  @override
  String toString() => 'SubjectData(${subjects.length} subjects)';
}

class NumberData {
  final double value;
  NumberData(this.value);

  @override
  String toString() => value.toString();
}

class ListData {
  final List<dynamic> items;
  ListData(this.items);

  @override
  String toString() => 'ListData(${items.length} items)';
}

class ProgrammableAnalysisEngine {
  final List<Subject> subjects;
  final List<CalendarEvent> events;

  ProgrammableAnalysisEngine({required this.subjects, required this.events});

  List<Grade> get allGrades => subjects.expand((s) => s.grades).toList();

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
        }else if (parenDepth == 0 && operators.contains(char)) {
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
    return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*\s*\(.*\)$').hasMatch(expr);
  }

  dynamic _evaluateFunction(String expr) {
    final match =
        RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s*\((.*)\)$').firstMatch(expr);
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
        }else if (char == '[') {
          bracketDepth++;
        }else if (char == ']') {
          bracketDepth--;
        }else if ((char == ';' || char == ',') &&
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

      case 'debug':
      case 'info':
        return _functionDebug(args);

      default:
        throw Exception('Unknown function: $functionName');
    }
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
      return NumberData(data.grades.map((g) => g.value).reduce(min) as double);
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
      return NumberData(data.grades.map((g) => g.value).reduce(max) as double);
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
      values = data.grades.map((g) => g.value).cast<double>().toList();
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

  static List<String> get programmingHelpText => [
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
        '  average(data)         - Calculates the average (works on GradeData, ListData).',
        '  sum(data)             - Calculates the sum (works on GradeData, ListData).',
        '  count(data)           - Counts items (GradeData, SubjectData, ListData).',
        '  min(data) | max(data) - Finds min/max value.',
        '  median(data)          - Finds the median value.',
        '',
        'LIST FUNCTIONS:',
        '  concat(d1, d2, ...)   - Combines multiple lists/data sets of the same type.',
        '  sort(data)            - Sorts data by value.',
        '  take(data, count)     - Takes the first N items.',
        '  skip(data, count)     - Skips the first N items.',
        '',
        'LITERALS:',
        '  Numbers: 5.0, 15',
        '  Strings: "Hello World"',
        '  Lists:   [1.0, 2.0, 3.0] (use comma or semicolon as separator)',
        '',
        'EXAMPLES:',
        '  debug()',
        '  count(all_grades()) + 2.0',
        '  average(grades(subject("Mathematik")))',
        '  max([10, count(all_grades()), 15])',
        '  show_list(sort(all_grades()))',
      ];
}
