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
                child: currentSubject.grades.isEmpty
                    ? const Center(
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
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: currentSubject.grades.length,
                        itemBuilder: (context, index) {
                          final grade = currentSubject.grades[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getGradeColor(grade.value)
                                    .withOpacity(0.2),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      labelStyle: const TextStyle(fontSize: 12),
                                    ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _showDeleteGradeDialog(context, grade);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Löschen',
                                                style: TextStyle(
                                                    color: Colors.red)),
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
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGradeDialog(context),
        child: const Icon(Icons.add),
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
                    /*subject.setNewName(nameController.text);
                    subject.setNewColor(selectedColor);
                    subject.setIsLk(isAdvanced);
                    Provider.of<AppState>(context, listen: false).updateStuff();*/
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

  void _showAddGradeDialog(BuildContext context) {
    final gradeController = TextEditingController();
    final descriptionController = TextEditingController();
    double weight = 1.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Note hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: gradeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Note (0-15)',
                  hintText: '13',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  hintText: 'Klassenarbeit',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Gewichtung: '),
                  Container(
                    width: 80,
                    height: 40,
                    margin: const EdgeInsets.only(left: 8),
                    child: TextFormField(
                      initialValue: weight.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final parsedValue = double.tryParse(value);
                        if (parsedValue != null) {
                          setState(() => weight = parsedValue);
                        }
                      },
                      validator: (value) {
                        final parsedValue = double.tryParse(value ?? '');
                        if (parsedValue == null) {
                          return 'Ungültige Zahl';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                final gradeValue = double.tryParse(gradeController.text);
                if (gradeValue != null && gradeValue >= 0 && gradeValue <= 15) {
                  final grade = Grade(
                    id: const Uuid().v4(),
                    value: gradeValue,
                    description: descriptionController.text.isEmpty
                        ? 'Note'
                        : descriptionController.text,
                    date: DateTime.now(),
                    weight: weight,
                  );

                  Provider.of<AppState>(context, listen: false)
                      .addGradeToSubject(subject.id, grade);
                  Navigator.pop(context);
                }
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 13) return Colors.green;
    if (grade >= 10) return Colors.orange;
    if (grade >= 5) return Colors.red;
    return Colors.grey;
  }
}
