import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/calendar_preview.dart';
import '../widgets/progress_header.dart';
import '../widgets/subject_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fächerübersicht',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  final subjects = appState.subjects;

                  if (subjects.isEmpty) {
                    return CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(
                          child: ProgressHeader(),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 16),
                        ),
                        const SliverToBoxAdapter(
                          child: CalendarPreview(),
                        ),
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Keine Fächer hinzugefügt',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Füge dein erstes Fach hinzu!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.pushNamed(
                                          context, '/add-subject'),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Fach hinzufügen'),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: ProgressHeader(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 16),
                      ),
                      const SliverToBoxAdapter(
                        child: CalendarPreview(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 16),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == subjects.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16, bottom: 32),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.pushNamed(
                                          context, '/add-subject'),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Fach hinzufügen'),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                            childCount: subjects.length + 1,
                          ),
                        ),
                      ),
                    ],
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
