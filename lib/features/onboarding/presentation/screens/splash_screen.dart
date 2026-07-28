import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pulsefit_logo.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback? onAnimationComplete;

  const SplashScreen({super.key, this.onAnimationComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // App Icon Squircle
            const PulseFitIcon(size: 110),
            const SizedBox(height: 24),

            // Wordmark: PulseFit
            RichText(
              text: TextSpan(
                style: GoogleFonts.sora(
                  fontSize: 38,
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
            const SizedBox(height: 8),

            // Subtitle: Health • Fitness • Nutrition
            Text(
              'Health • Fitness • Nutrition',
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),

            const Spacer(flex: 2),

            // Pulse Wave Divider Graphic
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: SizedBox(
                height: 30,
                child: CustomPaint(
                  painter: _PulseWaveGraphicPainter(color: AppColors.primary),
                  size: Size.infinite,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Footer Slogan: Better Health. Better You.
            Text(
              'Better Health. Better You.',
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _PulseWaveGraphicPainter extends CustomPainter {
  final Color color;

  _PulseWaveGraphicPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(0, h * 0.5);
    path.lineTo(w * 0.35, h * 0.5);
    path.lineTo(w * 0.42, h * 0.1);
    path.lineTo(w * 0.50, h * 0.9);
    path.lineTo(w * 0.58, h * 0.2);
    path.lineTo(w * 0.65, h * 0.5);
    path.lineTo(w, h * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
