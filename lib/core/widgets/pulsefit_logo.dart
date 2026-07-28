import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'pulse_heart_painter.dart';

class PulseFitIcon extends StatelessWidget {
  final double size;

  const PulseFitIcon({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final padding = size * 0.22;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: CustomPaint(
        painter: PulseHeartPainter(
          strokeColor: Colors.white,
          strokeWidth: size * 0.06,
        ),
      ),
    );
  }
}

class PulseFitLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showTagline;

  const PulseFitLogo({
    super.key,
    this.iconSize = 36,
    this.fontSize = 24,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PulseFitIcon(size: iconSize),
            SizedBox(width: iconSize * 0.3),
            RichText(
              text: TextSpan(
                style: GoogleFonts.sora(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                children: const [
                  TextSpan(
                    text: 'Pulse',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'Fit',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: GoogleFonts.sora(
                fontSize: fontSize * 0.38,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              children: const [
                TextSpan(text: 'Every '),
                TextSpan(
                  text: 'Beat',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '. Every '),
                TextSpan(
                  text: 'Move',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '. Every '),
                TextSpan(
                  text: 'Day',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
