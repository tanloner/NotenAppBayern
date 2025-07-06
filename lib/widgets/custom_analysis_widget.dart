import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../providers/app_state.dart';
import '../utils/analysis_engine.dart';

class CustomAnalysisWidget extends StatefulWidget {
  final AppState appState;

  const CustomAnalysisWidget({super.key, required this.appState});

  @override
  State<CustomAnalysisWidget> createState() => _CustomAnalysisWidgetState();
}

class _CustomAnalysisWidgetState extends State<CustomAnalysisWidget> {
  final TextEditingController _expressionController = TextEditingController();
  final List<AnalysisResult> _results = [];
  final List<String> _history = [];
  bool _showHelp = false;
  late ProgrammableAnalysisEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = ProgrammableAnalysisEngine(
        subjects: widget.appState.subjects,
        events: widget.appState.calendarEvents);
  }

  @override
  void dispose() {
    _expressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.code, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Custom Analyse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(_showHelp ? Icons.help : Icons.help_outline),
                    onPressed: () => setState(() => _showHelp = !_showHelp),
                    tooltip: 'Hilfe anzeigen',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expressionController,
                      decoration: const InputDecoration(
                        hintText: 'z.B. average(subject="Mathematik")',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.functions),
                      ),
                      onSubmitted: (_) => _executeExpression(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _executeExpression,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Ausführen'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'count(all_grades())',
                    'debug()',
                    'show_num(5.0)',
                    '3.0 + 2.0',
                    '10.0 / 2.0',
                  ].map((example) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label:
                            Text(example, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          _expressionController.text = example;
                          _executeExpression();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        if (_showHelp) _buildHelpSection(),
        Expanded(
          child: _results.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[_results.length - 1 - index];
                    return _buildResultCard(result, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDebugInfo(Map debugData) {
    final info = debugData['info'] as List<String>;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('Debug Info', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ...info.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line, style: const TextStyle(fontSize: 12)),
              )),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue),
              SizedBox(width: 8),
              Text('Hilfe & Beispiele',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    ProgrammableAnalysisEngine.programmingHelpText.map((line) {
                  if (line.isEmpty) return const SizedBox(height: 8);
                  if (line.startsWith('PROGRAMMABLE') ||
                      line.startsWith('DATA') ||
                      line.startsWith('MATH') ||
                      line.startsWith('LIST') ||
                      line.startsWith('DISPLAY') ||
                      line.startsWith('UTILITY') ||
                      line.startsWith('LITERALS') ||
                      line.startsWith('EXAMPLES') ||
                      line.startsWith('OPERATORS')) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(line,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 2),
                    child: Text(line,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Führe deine erste Analyse aus!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Probiere: count(all_grades()) oder debug()',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _expressionController.text = 'debug()';
                _executeExpression();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Debug ausführen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(AnalysisResult result, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    result.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                if (_history.length > index)
                  Flexible(
                    child: Chip(
                      label: Text(
                        _history[_history.length - 1 - index],
                        style: const TextStyle(fontSize: 10),
                        softWrap: true,
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(
                      () => _results.removeAt(_results.length - 1 - index)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (result.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(result.error!,
                            style: const TextStyle(color: Colors.red))),
                  ],
                ),
              )
            else if (result.type == 'number')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    result.value.toString(),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ),
              )
            else if (result.type == 'text')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(result.value.toString(),
                    style: const TextStyle(fontSize: 16)),
              )
            else if (result.type == 'chart_data' && result.chartData != null)
              _buildResultChart(result)
            else if (result.type == 'list')
              _buildResultList(result)
            else if (result.value is Map &&
                (result.value as Map)['type'] == 'debug_info')
              _buildDebugInfo(result.value as Map)
            else
              Text(result.value.toString(),
                  style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultChart(AnalysisResult result) {
    if (result.chartData == null || result.chartData!.isEmpty) {
      return const Text('Keine Diagrammdaten verfügbar');
    }

    final data = result.chartData!;
    final firstItem = data.first;

    if (firstItem.containsKey('date') && firstItem.containsKey('grade')) {
      final gradeSpots = <FlSpot>[];
      final averageSpots = <FlSpot>[];

      for (int i = 0; i < data.length; i++) {
        final grade = (data[i]['grade'] as num).toDouble();
        final average = (data[i]['average'] as num?)?.toDouble();
        gradeSpots.add(FlSpot(i.toDouble(), grade));
        if (average != null) {
          averageSpots.add(FlSpot(i.toDouble(), average));
        }
      }

      return Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              show: true,
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  interval: (data.length / 5).ceil().toDouble(),
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      String label = data[index]['date'].toString();
                      if (label.length > 8) {
                        label = '${label.substring(0, 6)}...';
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child:
                            Text(label, style: const TextStyle(fontSize: 10)),
                      );
                    }
                    return Container();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(value.toInt().toString(),
                        style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: 0,
            maxY: 15,
            lineBarsData: [
              LineChartBarData(
                spots: gradeSpots,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                dotData: const FlDotData(show: true),
              ),
              if (averageSpots.isNotEmpty)
                LineChartBarData(
                  spots: averageSpots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                ),
            ],
          ),
        ),
      );
    } else if (firstItem.containsKey('count') &&
        (firstItem.containsKey('range') ||
            firstItem.containsKey('description'))) {
      final colors = [
        Colors.green,
        Colors.lightGreen,
        Colors.orange,
        Colors.red,
        Colors.grey
      ];

      return Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final count = item['count'] as int;
              final color = colors[index % colors.length];

              return PieChartSectionData(
                color: color,
                value: count.toDouble(),
                title: '$count',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      );
    } else {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 15,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.blueGrey,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      // KORREKTUR: Greift auf den 'label'-Schlüssel zu.
                      final label = data[index]['label']?.toString() ?? '';
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: Text(
                          label.length > 8
                              ? '${label.substring(0, 8)}...'
                              : label,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(value.toInt().toString(),
                        style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              // KORREKTUR: Greift explizit auf den 'value'-Schlüssel zu.
              final rawValue = item['value'];
              num? numericValue;

              if (rawValue is num) {
                numericValue = rawValue;
              } else if (rawValue is String) {
                numericValue = num.tryParse(rawValue);
              }

              final barValue = (numericValue ?? 0.0).toDouble();

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: barValue,
                    color: Colors.blue,
                    width: 22,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  Widget _buildResultList(AnalysisResult result) {
    if (result.value is! List) {
      return Text(result.value.toString());
    }

    final items = result.value as List;
    return Column(
      children: items.map<Widget>((item) {
        return ListTile(
          dense: true,
          title: Text(item.toString()),
        );
      }).toList(),
    );
  }

  void _executeExpression() {
    final expression = _expressionController.text.trim();
    if (expression.isEmpty) return;

    _engine = ProgrammableAnalysisEngine(
        subjects: widget.appState.subjects,
        events: widget.appState.calendarEvents);

    final result = _engine.executeExpression(expression);

    setState(() {
      _results.add(result);
      _history.add(expression);

      if (_results.length > 10) {
        _results.removeAt(0);
        _history.removeAt(0);
      }
    });

    _expressionController.clear();
  }
}
