import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';

/// A widget that determines whether to show the [SetupScreen] or the
/// [HomeScreen] based on the [AppState].
class AuthGate extends StatelessWidget {
  /// Creates an [AuthGate] widget.
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.subjects.isEmpty && appState.isFirstLaunch) {
          return const SetupScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
