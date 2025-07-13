import 'dart:math';

import 'package:flutter/material.dart';

/// A widget that displays a circular progress bar.
class CircularProgressWidget extends StatelessWidget {
  /// The progress of the circular progress bar.
  final double progress;

  /// The current grade.
  final double currentGrade;

  /// The target grade.
  final double targetGrade;

  /// Creates a [CircularProgressWidget].
  const CircularProgressWidget({
    super.key,
    required this.progress,
    required this.currentGrade,
    required this.targetGrade,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 120),
      painter: SemicircleProgressPainter(
        progress: progress,
        backgroundColor: Colors.white.withOpacity(0.2),
        progressColor: Colors.white,
        strokeWidth: 12.0,
      ),
      child: Container(
        width: 200,
        height: 120,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentGrade.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ ${targetGrade.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A painter for the circular progress bar.
class SemicircleProgressPainter extends CustomPainter {
  /// The progress of the circular progress bar.
  final double progress;

  /// The background color of the circular progress bar.
  final Color backgroundColor;

  /// The progress color of the circular progress bar.
  final Color progressColor;

  /// The stroke width of the circular progress bar.
  final double strokeWidth;

  /// Creates a [SemicircleProgressPainter].
  SemicircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      backgroundPaint,
    );

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
