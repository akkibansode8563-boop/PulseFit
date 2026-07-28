import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/ai/presentation/screens/ai_coach_screen.dart';
import '../theme/app_colors.dart';

class AIBreathingOrb extends StatefulWidget {
  const AIBreathingOrb({super.key});

  @override
  State<AIBreathingOrb> createState() => _AIBreathingOrbState();
}

class _AIBreathingOrbState extends State<AIBreathingOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AICoachScreen()),
        );
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 + (_controller.value * 0.12);
          final glowRadius = 20.0 + (_controller.value * 25.0);

          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.accent,
                  AppColors.primary,
                ],
                transform: GradientRotation(_controller.value * 2 * math.pi),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  blurRadius: glowRadius,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  blurRadius: glowRadius * 0.8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkBackground,
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 500.ms).scale(curve: Curves.easeOutBack);
  }
}
