import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../providers/app_state.dart';

class StatisticsCharts extends StatelessWidget {
  final AppState appState;

  const StatisticsCharts({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Diagramm-Analysen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildChartCard(
            'Fächer-Vergleich',
            _buildSubjectComparisonChart(),
            'Vergleicht den Durchschnitt aller Fächer',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Noten-Statistiken',
            _buildGradeStatsChart(),
            'Zeigt grundlegende Statistiken',
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
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectComparisonChart() {
    if (appState.subjects.isEmpty) {
      return const Center(child: Text('Keine Daten verfügbar'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${appState.subjects[group.x.toInt()].name}\n',
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
                  if (value.toInt() >= 0 &&
                      value.toInt() < appState.subjects.length) {
                    final subject = appState.subjects[value.toInt()];
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      angle: -1.1,
                      child: Text(
                        subject.name.length > 8
                            ? '${subject.name.substring(0, 8)}...'
                            : subject.name,
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
                reservedSize: 40),
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
        barGroups: appState.subjects.asMap().entries.map((entry) {
          final index = entry.key;
          final subject = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: subject.averageGrade,
                color: subject.color,
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

  Widget _buildGradeStatsChart() {
    final allGrades = appState.subjects.expand((s) => s.grades).toList();
    if (allGrades.isEmpty) {
      return const Center(child: Text('Keine Noten verfügbar'));
    }

    final average = allGrades.fold(0.0, (sum, grade) => sum + grade.value) /
        allGrades.length;
    final highest =
        allGrades.map((g) => g.value).reduce((a, b) => a > b ? a : b);
    final lowest =
        allGrades.map((g) => g.value).reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                  'Durchschnitt', average.toStringAsFixed(2), Colors.blue),
              _buildStatColumn(
                  'Höchste Note', highest.toStringAsFixed(1), Colors.green),
              _buildStatColumn(
                  'Niedrigste Note', lowest.toStringAsFixed(1), Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                  'Gesamt Noten', allGrades.length.toString(), Colors.purple),
              _buildStatColumn(
                  'Fächer', appState.subjects.length.toString(), Colors.orange),
              _buildStatColumn(
                  'Ziel', appState.targetGrade.toStringAsFixed(0), Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
