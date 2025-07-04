import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/grade.dart';
import '../providers/app_state.dart';
import '../utils/analysis_engine.dart';

class StatisticsCharts extends StatelessWidget {
  final AppState appState;

  const StatisticsCharts({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final engine = AnalysisEngine(subjects: appState.subjects, events: appState.calendarEvents);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Diagramm-Analysen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _buildChartCard(
            'Notenverlauf über Zeit',
            _buildGradesOverTimeChart(engine),
            'Zeigt die Entwicklung deiner Noten chronologisch',
          ),

          const SizedBox(height: 16),

          _buildChartCard(
            'Fächer-Vergleich',
            _buildSubjectComparisonChart(engine),
            'Vergleicht den Durchschnitt aller Fächer',
          ),

          const SizedBox(height: 16),

          _buildChartCard(
            'Notenverteilung',
            _buildGradeDistributionChart(engine),
            'Zeigt wie deine Noten verteilt sind',
          ),

          const SizedBox(height: 16),

          _buildChartCard(
            'Gewichtungs-Analyse',
            _buildWeightAnalysisChart(engine),
            'Analysiert Noten nach ihrer Gewichtung',
          ),

          const SizedBox(height: 16),

          if (_hasMultipleDescriptions())
            _buildChartCard(
              'Analyse nach Arbeitstyp',
              _buildDescriptionAnalysisChart(engine),
              'Vergleicht verschiedene Arten von Arbeiten',
            ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesOverTimeChart(AnalysisEngine engine) {
    final result = engine.executeExpression('grades_over_time');

    if (result.error != null || result.chartData == null || result.chartData!.isEmpty) {
      return Center(child: Text(result.error ?? 'Keine Daten verfügbar'));
    }

    final data = result.chartData!;

    final gradeSpots = <FlSpot>[];
    final averageSpots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final grade = (data[i]['grade'] as num).toDouble();
      final average = (data[i]['average'] as num).toDouble();
      gradeSpots.add(FlSpot(i.toDouble(), grade));
      averageSpots.add(FlSpot(i.toDouble(), average));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      data[value.toInt()]['date'].toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
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
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
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
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: averageSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            isStrokeCapRound: true,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectComparisonChart(AnalysisEngine engine) {
    final result = engine.executeExpression('subject_comparison');

    if (result.error != null || result.chartData == null || result.chartData!.isEmpty) {
      return Center(child: Text(result.error ?? 'Keine Daten verfügbar'));
    }

    final data = result.chartData!;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[group.x.toInt()]['subject']}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: rod.toY.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final subject = data[value.toInt()]['subject'].toString();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      subject.length > 8 ? '${subject.substring(0, 8)}...' : subject,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final average = (item['average'] as num).toDouble();
          final color = Color(item['color'] as int);

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: average,
                color: color,
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
    );
  }

  Widget _buildGradeDistributionChart(AnalysisEngine engine) {
    final result = engine.executeExpression('grade_distribution');

    if (result.error != null || result.chartData == null || result.chartData!.isEmpty) {
      return Center(child: Text(result.error ?? 'Keine Daten verfügbar'));
    }

    final data = result.chartData!;
    final colors = [Colors.green, Colors.lightGreen, Colors.orange, Colors.red, Colors.grey];

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final count = item['count'] as int;
          final range = item['range'].toString(); //TODO: impelent range too
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
    );
  }

  Widget _buildWeightAnalysisChart(AnalysisEngine engine) {
    final result = engine.executeExpression('weight_analysis');

    if (result.error != null || result.chartData == null || result.chartData!.isEmpty) {
      return Center(child: Text(result.error ?? 'Keine Daten verfügbar'));
    }

    final data = result.chartData!;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[group.x.toInt()]['weight']}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: rod.toY.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      data[value.toInt()]['weight'].toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final average = (item['average'] as num).toDouble();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: average,
                color: Colors.purple,
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
    );
  }

  Widget _buildDescriptionAnalysisChart(AnalysisEngine engine) {
    final result = engine.executeExpression('description_analysis');

    if (result.error != null || result.chartData == null || result.chartData!.isEmpty) {
      return Center(child: Text(result.error ?? 'Keine Daten verfügbar'));
    }

    final data = result.chartData!;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[group.x.toInt()]['description']}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: rod.toY.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final description = data[value.toInt()]['description'].toString();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      description.length > 6 ? '${description.substring(0, 6)}...' : description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
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
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final average = (item['average'] as num).toDouble();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: average,
                color: Colors.indigo,
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
    );
  }

  bool _hasMultipleDescriptions() {
    final allGrades = appState.subjects.expand((s) => s.grades).toList();
    final descriptions = allGrades.map((g) => g.description.toLowerCase()).toSet();
    return descriptions.length > 1;
  }
}