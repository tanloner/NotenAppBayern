import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject.dart';
import '../providers/app_state.dart';

/// A card that displays information about a subject.
class SubjectCard extends StatelessWidget {
  /// The subject to display.
  final Subject subject;

  /// Creates a [SubjectCard].
  const SubjectCard({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/subject-detail',
          arguments: subject,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: subject.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.book_outlined,
                  color: subject.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subject.semesterGrades(Provider.of<AppState>(context, listen: false).semester).length} Note${subject.grades.length != 1 ? 'n' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    subject
                        .averageGradeSemester(
                            Provider.of<AppState>(context, listen: false)
                                .semester)
                        .toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(subject.averageGradeSemester(
                          Provider.of<AppState>(context, listen: false)
                              .semester)),
                    ),
                  ),
                  Text(
                    'Durchschnitt',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
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
