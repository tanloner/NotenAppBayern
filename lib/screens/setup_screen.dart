import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/progress_header.dart';
import '../widgets/subject_card.dart';
import '../providers/config.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Choose you Passions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  final subjects = Config.all_subjects;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: subjects.length + 1,
                    itemBuilder: (context, index) {
                      if (index == subjects.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/add-subject'),
                              icon: const Icon(Icons.add),
                              label: const Text('Fach hinzufügen'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SubjectCard(subject: subjects[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
