import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/grade.dart';
import '../models/subject.dart';
import '../providers/app_state.dart';

class SubjectDetailScreen extends StatelessWidget {
  final Subject subject;

  const SubjectDetailScreen({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Bearbeiten'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Löschen', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMenuAction(context, value),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final currentSubject =
          appState.subjects.firstWhere((s) => s.id == subject.id);
          final majorGrades =
          currentSubject.grades.where((g) => g.isBig).toList();
          final minorGrades =
          currentSubject.grades.where((g) => !g.isBig).toList();

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: subject.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: subject.color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Durchschnitt',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentSubject.averageGrade.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: subject.color,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text(
                          'Großer Leistungsnachweis',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (majorGrades.isEmpty)
                        _buildAddMajorGradePlaceholder(context)
                      else
                        _buildGradeList(context, majorGrades, true),

                      const Padding(
                        padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
                        child: Text(
                          'Kleine Leistungsnachweise',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (minorGrades.isEmpty && majorGrades.isNotEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Noch keine kleinen Leistungsnachweise eingetragen',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (minorGrades.isNotEmpty)
                        _buildGradeList(context, minorGrades, false),

                      if (currentSubject.grades.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Noch keine Noten eingetragen',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGradeDialog(context, false),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGradeList(BuildContext context, List<Grade> grades, bool isMajorGradeContext) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final grade = grades[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getGradeColor(grade.value).withOpacity(0.2),
              child: Text(
                grade.value.toStringAsFixed(1),
                style: TextStyle(
                  color: _getGradeColor(grade.value),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(grade.description),
            subtitle: Text(
              '${grade.date.day}.${grade.date.month}.${grade.date.year}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (grade.weight != 1.0)
                  Chip(
                    label: Text('${grade.weight}x'),
                    backgroundColor: Colors.grey[200],
                    padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteGradeDialog(context, grade);
                    } //TODO: maybe edit function
                  },
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Löschen', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Placeholder-Widget, wenn kein großer Leistungsnachweis vorhanden ist
  Widget _buildAddMajorGradePlaceholder(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAddGradeDialog(context, true),
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Text(
                'Großen Leistungsnachweis hinzufügen',
                style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showDeleteGradeDialog(BuildContext context, Grade grade) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Note löschen'),
        content: Text(
            'Möchtest du die Note "${grade.description}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false)
                  .removeGradeFromSubject(subject, grade.id);
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _showEditSubjectDialog(context);
        break;
      case 'delete':
        _showDeleteSubjectDialog(context);
        break;
    }
  }

  void _showEditSubjectDialog(BuildContext context) {
    final nameController = TextEditingController(text: subject.name);
    Color selectedColor = subject.color;
    bool isAdvanced = subject.isLk;
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Fach bearbeiten'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Fachname',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Farbe wählen',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: colorOptions.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: color,
                            child: selectedColor == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Leistungskurs'),
                      value: isAdvanced,
                      onChanged: (bool value) {
                        setState(() {
                          isAdvanced = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () {
                    Subject updatedSubject = subject.copyWith(
                        name: nameController.text,
                        color: selectedColor,
                        isLk: isAdvanced);
                    Provider.of<AppState>(context, listen: false)
                        .updateSubject(updatedSubject);
                    Navigator.pop(context);
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteSubjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fach löschen'),
        content:
        Text('Möchtest du das Fach "${subject.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false)
                  .removeSubject(subject.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _showAddGradeDialog(BuildContext context, bool isMajor) {
    final gradeController = TextEditingController();
    final descriptionController = TextEditingController();
    final weightController = TextEditingController(text: '1.0');
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isMajor ? 'Großen Leistungsnachweis hinzufügen' : 'Note hinzufügen'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: gradeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Note (0-15)',
                    hintText: '13',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte eine Note eingeben.';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 15) {
                      return 'Note muss zwischen 0 und 15 liegen.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Beschreibung',
                    hintText: isMajor ? 'Klausur' : 'Mündliche Note',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte eine Beschreibung eingeben.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Gewichtung (0.5 - 4.0)',
                    hintText: '1.0',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte eine Gewichtung eingeben.';
                    }
                    final doubleValue = double.tryParse(value.replaceFirst(',', '.'));
                    if (doubleValue == null) {
                      return 'Ungültige Zahl.';
                    }
                    if (doubleValue < 0.5 || doubleValue > 4.0) {
                      return 'Gewichtung muss zwischen 0.5 und 4.0 liegen.';
                    }
                    String normalizedValue = doubleValue.toString();
                    if (normalizedValue.contains('.')) {
                      normalizedValue = normalizedValue.replaceAll(RegExp(r'0*$'), '');
                      normalizedValue = normalizedValue.replaceAll(RegExp(r'\.$'), '');
                    }
                    final parts = normalizedValue.split('.');
                    if (parts.length > 1 && parts[1].length > 2) {
                      return 'Maximal zwei Nachkommastellen erlaubt.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final value = int.tryParse(gradeController.text);
                  final description = descriptionController.text;
                  final weight = double.parse(weightController.text.replaceFirst(',', '.'));

                  if (value != null && description.isNotEmpty) {
                    final newGrade = Grade(
                      id: const Uuid().v4(),
                      value: value,
                      description: description,
                      date: DateTime.now(),
                      weight: weight,
                      type: isMajor ? GradeType.big : GradeType.small,
                    );
                    Provider.of<AppState>(context, listen: false)
                        .addGradeToSubject(subject.id, newGrade);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte alle Felder korrekt ausfüllen.'))
                    );
                  }
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(int gradeValue) {
    if (gradeValue >= 10) return Colors.green;
    if (gradeValue >= 5) return Colors.orange;
    return Colors.red;
  }
}