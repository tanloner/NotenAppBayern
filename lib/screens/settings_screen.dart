import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grade.dart';
import '../providers/app_state.dart';

/// A screen for changing the app's settings.
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ziel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: appState.targetGrade,
                              min: 1.0,
                              max: 15.0,
                              divisions: 140,
                              label: appState.targetGrade.toStringAsFixed(1),
                              onChanged: (value) =>
                                  appState.setTargetGrade(value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            appState.targetGrade.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Dunkles Design aktivieren'),
                        value: appState.isDarkMode,
                        onChanged: (value) => appState.setDarkMode(value),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Aktuelles Halbjahr'),
                        subtitle: Text(appState.currentSemester),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showSemesterDialog(context, appState),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Über die App',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text('Version: 1.0.0'),
                      SizedBox(height: 8),
                      Text('Eine einfache Notenapp für die Schule.'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _showSemesterDialog(BuildContext context, AppState appState) {
  final List<String> semesters = Semester.values.map((s) => s.displayName).toList(growable: false);


  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Halbjahr wählen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: semesters
            .map(
              (semester) => RadioListTile<String>(
                title: Text(semester),
                value: semester,
                groupValue: appState.currentSemester,
                onChanged: (value) {
                  if (value != null) {
                    appState.setSemester(value);
                    Navigator.pop(context);
                  }
                },
              ),
            )
            .toList(),
      ),
    ),
  );
}
