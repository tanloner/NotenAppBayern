import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../models/grade.dart';
import '../providers/app_state.dart';
import 'package:uuid/uuid.dart';

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
          final currentSubject = appState.subjects.firstWhere((s) => s.id == subject.id);

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
                        trailing: grade.weight != 1.0
                            ? Chip(
                          label: Text('${grade.weight}x'),
                          backgroundColor: Colors.grey[200],
                        )
                            : null,
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

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
      // TODO: Edit Dialog machen!!!!!
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fach löschen'),
        content: Text('Möchtest du das Fach "${subject.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).removeSubject(subject.id);
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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