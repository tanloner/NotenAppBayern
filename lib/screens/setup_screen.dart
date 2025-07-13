import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/subject.dart';
import '../providers/app_state.dart';
import '../providers/config.dart';

class _SetupSubject {
  final String name;
  bool isSelected;
  bool isLk;
  Color color;

  _SetupSubject({
    required this.name,
    this.isSelected = false,
    this.isLk = false,
    this.color = Colors.grey,
  });
}

/// A screen for setting up the app for the first time.
class SetupScreen extends StatefulWidget {
  /// Creates a [SetupScreen].
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _selectedSemester = '1. Halbjahr 2024/25';
  double _targetGrade = 12.0;
  late List<_SetupSubject> _setupSubjects;

  @override
  void initState() {
    super.initState();
    _setupSubjects = Config.allSubjects.map((name) {
      bool isSelected = (name == 'Mathematik' || name == 'Deutsch');
      bool isLk = (name == 'Mathematik' || name == 'Deutsch');
      var rng = Random();
      Color color = Color.fromARGB(rng.nextInt(256), rng.nextInt(256),
          rng.nextInt(256), rng.nextInt(256)); //Colors.grey.shade400;
      if (name == 'Mathematik') color = Colors.blue;
      if (name == 'Deutsch') color = Colors.red;

      return _SetupSubject(
          name: name, isSelected: isSelected, isLk: isLk, color: color);
    }).toList();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _finishSetup();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void _finishSetup() {
    final appState = Provider.of<AppState>(context, listen: false);

    appState.setSemester(_selectedSemester);
    appState.setTargetGrade(_targetGrade);

    final selectedSubjects = _setupSubjects.where((s) => s.isSelected);
    for (var setupSubject in selectedSubjects) {
      final newSubject = Subject(
        id: const Uuid().v4(),
        name: setupSubject.name,
        grades: [],
        color: setupSubject.color,
        isLk: setupSubject.isLk,
      );
      appState.addSubject(newSubject);
    }
    appState.setFirstLaunch(false);
  }

  void _showColorPickerDialogForSubject(_SetupSubject subject) {
    Color pickerColor = subject.color;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wähle eine Farbe'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              setState(() => subject.color = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 24.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (index) => Container(
                          width: 40,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _currentPage >= index
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildSemesterAndGoalPage(),
                  _buildSubjectSelectionPage(),
                  _buildColorSelectionPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterAndGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dein Start",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Text("Aktuelles Halbjahr",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedSemester,
            items: [
              '1. Halbjahr 2024/25',
              '2. Halbjahr 2024/25',
              '1. Halbjahr 2025/26',
              '2. Halbjahr 2025/26'
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (value) => setState(() => _selectedSemester = value!),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 32),
          Text("Dein Notenziel",
              style: Theme.of(context).textTheme.titleLarge),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _targetGrade,
                  min: 1.0,
                  max: 15.0,
                  divisions: 14,
                  label: _targetGrade.toStringAsFixed(0),
                  onChanged: (value) => setState(() => _targetGrade = value),
                ),
              ),
              Text(_targetGrade.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelectionPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text("Wähle deine Fächer",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _setupSubjects.length,
            itemBuilder: (context, index) {
              final subject = _setupSubjects[index];
              final isFixedLk =
                  subject.name == 'Mathematik' || subject.name == 'Deutsch';

              return Card(
                elevation: 0,
                color: Colors.transparent,
                child: CheckboxListTile(
                  title: Text(subject.name),
                  value: subject.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (isFixedLk) return;
                      subject.isSelected = value ?? false;
                      if (!subject.isSelected) subject.isLk = false;
                    });
                  },
                  secondary: subject.isSelected
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('LK'),
                            Switch(
                              value: subject.isLk,
                              onChanged: isFixedLk
                                  ? null
                                  : (bool value) =>
                                      setState(() => subject.isLk = value),
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelectionPage() {
    final selectedSubjects = _setupSubjects.where((s) => s.isSelected).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text("Gib deinen Fächern Farbe",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: selectedSubjects.length,
            itemBuilder: (context, index) {
              final subject = selectedSubjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: subject.color, shape: BoxShape.circle)),
                  title: Text(subject.name),
                  trailing: subject.isLk ? const Chip(label: Text("LK")) : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...Config.availableColors.map((color) {
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => subject.color = color),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: subject.color == color
                                      ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 3)
                                      : null,
                                ),
                                child: subject.color == color
                                    ? const Icon(Icons.check,
                                        color: Colors.white)
                                    : null,
                              ),
                            );
                          }),
                          GestureDetector(
                            onTap: () =>
                                _showColorPickerDialogForSubject(subject),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 2),
                              ),
                              child: const Icon(Icons.colorize,
                                  color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(onPressed: _previousPage, child: const Text('Zurück'))
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
            child: Text(_currentPage < 2 ? 'Weiter' : 'Fertigstellen'),
          ),
        ],
      ),
    );
  }
}
