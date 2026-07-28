import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlowingVitalityRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int centerValue;
  final String centerUnit;
  final String label;

  const GlowingVitalityRing({
    super.key,
    required this.progress,
    required this.centerValue,
    required this.centerUnit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(120, 120),
            painter: _ProgressRingPainter(progress: clampedProgress),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.warning,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;

  _ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final trackPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepGradient = const SweepGradient(
      colors: [
        Color(0xFFCFF7B5), // Light Progress
        Color(0xFF9CE96A), // Fresh Sage Progress
        Color(0xFF5DAE47), // Deep Forest Progress
      ],
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
    );

    final progressPaint = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
