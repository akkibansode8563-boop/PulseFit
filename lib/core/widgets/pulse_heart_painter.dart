import 'package:flutter/material.dart';

class PulseHeartPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;

  PulseHeartPainter({
    this.strokeColor = Colors.white,
    this.strokeWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final width = size.width;
    final height = size.height;

    // Draw Smooth Heart Contour
    final heartPath = Path();
    heartPath.moveTo(width * 0.5, height * 0.82);
    // Left bottom curve up to top left lobe
    heartPath.cubicTo(
      width * 0.1, height * 0.55,
      width * 0.05, height * 0.28,
      width * 0.28, height * 0.18,
    );
    // Top left lobe to top center dip
    heartPath.cubicTo(
      width * 0.42, height * 0.12,
      width * 0.48, height * 0.24,
      width * 0.5, height * 0.32,
    );
    // Top center dip to top right lobe
    heartPath.cubicTo(
      width * 0.52, height * 0.24,
      width * 0.58, height * 0.12,
      width * 0.72, height * 0.18,
    );
    // Top right lobe to bottom tip
    heartPath.cubicTo(
      width * 0.95, height * 0.28,
      width * 0.9, height * 0.55,
      width * 0.5, height * 0.82,
    );
    canvas.drawPath(heartPath, paint);

    // Draw Embedded Heartbeat ECG Pulse Line across center
    final pulsePath = Path();
    final centerY = height * 0.48;
    pulsePath.moveTo(width * 0.12, centerY);
    pulsePath.lineTo(width * 0.36, centerY);
    pulsePath.lineTo(width * 0.43, centerY - height * 0.14);
    pulsePath.lineTo(width * 0.51, centerY + height * 0.16);
    pulsePath.lineTo(width * 0.59, centerY - height * 0.22);
    pulsePath.lineTo(width * 0.67, centerY + height * 0.08);
    pulsePath.lineTo(width * 0.74, centerY);
    pulsePath.lineTo(width * 0.88, centerY);

    canvas.drawPath(pulsePath, paint);
  }

  @override
  bool shouldRepaint(covariant PulseHeartPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
