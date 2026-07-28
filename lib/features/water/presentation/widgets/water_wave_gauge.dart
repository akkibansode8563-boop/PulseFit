import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_counter_text.dart';

class WaterWaveGauge extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final int currentMl;
  final int targetMl;

  const WaterWaveGauge({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.targetMl,
  });

  @override
  State<WaterWaveGauge> createState() => _WaterWaveGaugeState();
}

class _WaterWaveGaugeState extends State<WaterWaveGauge> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 210,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkSurface,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.5),
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: widget.progress.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, animatedProgress, child) {
            return AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    progress: animatedProgress,
                    animationValue: _waveController.value,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.water_drop, color: Colors.white, size: 30),
                        const SizedBox(height: 4),
                        AnimatedCounterText(
                          value: widget.currentMl,
                          suffix: ' ml',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Goal: ${widget.targetMl} ml',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final double animationValue;

  WavePainter({required this.progress, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppColors.cyanGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 8.0;
    final baseHeight = size.height * (1.0 - progress);

    path.moveTo(0, size.height);
    for (double i = 0.0; i <= size.width; i++) {
      final y = baseHeight + math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * waveHeight;
      path.lineTo(i, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}
