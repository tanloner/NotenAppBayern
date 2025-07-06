import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject.dart';
import '../providers/app_state.dart';
import '../utils/analysis_engine.dart';
import '../widgets/custom_analysis_widget.dart';
import '../widgets/statistics_charts.dart';

class ComprehensiveStatisticsScreen extends StatefulWidget {
  const ComprehensiveStatisticsScreen({super.key});

  @override
  State<ComprehensiveStatisticsScreen> createState() =>
      _ComprehensiveStatisticsScreenState();
}

class _ComprehensiveStatisticsScreenState
    extends State<ComprehensiveStatisticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiken'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Übersicht'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Diagramme'),
            Tab(icon: Icon(Icons.analytics), text: 'Trends'),
            Tab(icon: Icon(Icons.code), text: 'Custom'),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.subjects.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Keine Daten für Statistiken',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Füge Fächer und Noten hinzu!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(appState),
              _buildChartsTab(appState),
              _buildTrendsTab(appState),
              _buildCustomAnalysisTab(appState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(AppState appState) {
    final allGrades = appState.subjects.expand((s) => s.grades).toList();
    final totalGrades = allGrades.length;
    final overallAverage = appState.overallAverage;

    final subjects_have_different_avgs = (appState.subjects.where((s) => s.grades.isNotEmpty)).map((s) => s.averageGrade).toSet().length > 1;

    final bestSubject = (appState.subjects.isNotEmpty && subjects_have_different_avgs)
        ? appState.subjects
            .reduce((a, b) => (a.averageGrade > b.averageGrade) && a.amountGrades != 0 ? a : b)
        : null;


    final worstSubject = appState.subjects.isNotEmpty
        ? appState.subjects
            .reduce((a, b) => (a.amountGrades != 0) && (b.amountGrades == 0) ? a : (a.averageGrade < b.averageGrade) ? a : b)
        : null;

    final recentGrades = allGrades
        .where((g) => DateTime.now().difference(g.date).inDays <= 30)
        .toList();

    final heaviestWeight = allGrades.isNotEmpty
        ? allGrades.map((g) => g.weight).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      'Gesamtdurchschnitt',
                      overallAverage.toStringAsFixed(2),
                      Icons.trending_up,
                      Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      'Fächer',
                      appState.subjects.length.toString(),
                      Icons.book,
                      Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard('Noten', totalGrades.toString(),
                      Icons.assignment, Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          if (bestSubject != null && worstSubject != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fach-Performance',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.emoji_events,
                                  color: Colors.amber, size: 32),
                              const SizedBox(height: 8),
                              Text('Bestes Fach',
                                  style: TextStyle(color: Colors.grey[600])),
                              Text(bestSubject.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(bestSubject.averageGrade.toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.green)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.trending_down,
                                  color: Colors.red, size: 32),
                              const SizedBox(height: 8),
                              Text('Verbesserungspotential',
                                  style: TextStyle(color: Colors.grey[600])),
                              Text(worstSubject.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(worstSubject.averageGrade.toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Letzte 30 Tage',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              'Neue Noten',
                              recentGrades.length.toString(),
                              Icons.fiber_new,
                              Colors.purple)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatCard(
                              'Höchste Gewichtung',
                              '${heaviestWeight}x',
                              Icons.fitness_center,
                              Colors.indigo)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fächer im Detail',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...appState.subjects
                      .map((subject) => _buildSubjectDetailRow(subject)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab(AppState appState) {
    return StatisticsCharts(appState: appState);
  }

  Widget _buildTrendsTab(AppState appState) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trend-Analysen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Schnelle Analyse',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      'Gesamtdurchschnitt: ${appState.overallAverage.toStringAsFixed(2)}'),
                  Text('Anzahl Fächer: ${appState.subjects.length}'),
                  Text(
                      'Anzahl Noten: ${appState.subjects.expand((s) => s.grades).length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...appState.subjects.map((subject) {
            if (subject.grades.length < 2) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: subject.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(subject.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Durchschnitt: ${subject.averageGrade.toStringAsFixed(2)}'),
                    Text('Anzahl Noten: ${subject.grades.length}'),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomAnalysisTab(AppState appState) {
    return CustomAnalysisWidget(appState: appState);
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectDetailRow(Subject subject) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: subject.color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(subject.name)),
          Text('${subject.grades.length} Noten',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 16),
          Text(subject.averageGrade.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTrendResult(AnalysisResult result) {
    if (result.error != null) {
      return Text(result.error!, style: const TextStyle(color: Colors.red));
    }

    return Text(result.value.toString(), style: const TextStyle(fontSize: 16));
  }

  Widget _buildAnalysisResult(AnalysisResult result) {
    if (result.error != null) {
      return Text(result.error!, style: const TextStyle(color: Colors.red));
    }

    if (result.type == 'chart_data' && result.chartData != null) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: result.chartData!.length,
          itemBuilder: (context, index) {
            final data = result.chartData![index];
            return ListTile(
              title: Text(data['range'] ?? data['description'] ?? 'Unknown'),
              trailing: Text(data['count'].toString()),
            );
          },
        ),
      );
    }

    return Text(result.value.toString());
  }
}
