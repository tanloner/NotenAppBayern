import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calendar_event.dart';
import '../models/subject.dart';
import '../providers/app_state.dart';

/// A widget that displays a preview of the calendar.
class CalendarPreview extends StatelessWidget {
  /// Creates a [CalendarPreview].
  const CalendarPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final upcomingEvents = appState.upcomingEvents;

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/calendar'),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.8),
                  Colors.deepPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Anstehende Termine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/calendar'),
                          icon: const Icon(
                            Icons.calendar_month,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showAddEventDialog(context),
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (upcomingEvents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            color: Colors.white70,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Keine anstehenden Termine',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: upcomingEvents.take(4).map((event) {
                      final subject = event.subjectId != null
                          ? appState.subjects.firstWhere(
                              (s) => s.id == event.subjectId,
                              orElse: () => Subject(
                                id: '',
                                name: '',
                                grades: [],
                                color: Colors.grey,
                              ),
                            )
                          : null;

                      return _buildEventItem(event, subject);
                    }).toList(),
                  ),
                if (upcomingEvents.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        '+${upcomingEvents.length - 4} weitere Termine',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventItem(CalendarEvent event, Subject? subject) {
    final daysUntil = event.date.difference(DateTime.now()).inDays;
    final isToday = daysUntil == 0;
    final isTomorrow = daysUntil == 1;

    String dateText;
    if (isToday) {
      dateText = 'Heute';
    } else if (isTomorrow) {
      dateText = 'Morgen';
    } else if (daysUntil < 7) {
      dateText = 'in $daysUntil Tagen';
    } else {
      dateText = '${event.date.day}.${event.date.month}.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: subject?.color ?? Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subject != null)
                  Text(
                    subject.name,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                event.type.icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                dateText,
                style: TextStyle(
                  color: isToday || isTomorrow
                      ? Colors.orange[300]
                      : Colors.white70,
                  fontSize: 11,
                  fontWeight: isToday || isTomorrow
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    EventType selectedType = EventType.other;
    String? selectedSubjectId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Termin hinzufügen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titel',
                    hintText: 'z.B. Mathe Klassenarbeit',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung (optional)',
                    hintText: 'Weitere Details...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Datum'),
                  subtitle: Text(
                    '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EventType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Typ'),
                  items: EventType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Text(type.icon),
                          const SizedBox(width: 8),
                          Text(type.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return DropdownButtonFormField<String?>(
                      value: selectedSubjectId,
                      decoration:
                          const InputDecoration(labelText: 'Fach (optional)'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Kein Fach'),
                        ),
                        ...appState.subjects.map((subject) {
                          return DropdownMenuItem<String?>(
                            value: subject.id,
                            child: Text(subject.name),
                          );
                        }),
                      ],
                      onChanged: (value) =>
                          setState(() => selectedSubjectId = value),
                    );
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
                if (titleController.text.trim().isNotEmpty) {
                  final event = CalendarEvent(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    date: selectedDate,
                    type: selectedType,
                    subjectId: selectedSubjectId,
                  );

                  Provider.of<AppState>(context, listen: false)
                      .addCalendarEvent(event);
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
}
