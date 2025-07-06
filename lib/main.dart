import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_gate.dart';
import 'models/subject.dart';
import 'providers/app_state.dart';
import 'screens/add_subject_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/comprehensive_statistics_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/subject_detail_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..loadData(),
      child: const NotesApp(),
    ),
  );
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notenapp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.dark),
      ),
      themeMode: Provider.of<AppState>(context).isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const AuthGate(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/statistics': (context) => const ComprehensiveStatisticsScreen(),
        '/add-subject': (context) => const AddSubjectScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/calendar': (context) => const CalendarScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/subject-detail') {
          final subject = settings.arguments as Subject;
          return MaterialPageRoute(
              builder: (context) => SubjectDetailScreen(subject: subject));
        }
        return null;
      },
    );
  }
}
