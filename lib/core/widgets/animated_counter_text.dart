import 'package:flutter/material.dart';

class AnimatedCounterText extends StatelessWidget {
  final num value;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounterText({
    super.key,
    required this.value,
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        final displayStr = val.toStringAsFixed(value is int ? 0 : 1);
        return Text(
          '$displayStr$suffix',
          style: style,
        );
      },
    );
  }
}
