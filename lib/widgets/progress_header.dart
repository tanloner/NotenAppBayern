import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'circular_progress_widget.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/statistics'),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fortschritt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.analytics_outlined,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ],
                ),
                SizedBox(
                  height: 120,
                  child: CircularProgressWidget(
                    progress: appState.progressToTarget,
                    currentGrade: appState.overallAverage,
                    targetGrade: appState.targetGrade,
                  ),
                ),

/*                const SizedBox(height: 16),
                Text(
                  'Durchschnitt: ${appState.overallAverage.toStringAsFixed(1)} von ${appState.targetGrade.toStringAsFixed(0)} Punkten',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),*/
              ],
            ),
          ),
        );
      },
    );
  }
}
