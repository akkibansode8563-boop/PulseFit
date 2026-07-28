import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool isGlowing;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppColors.radiusCard, // 28px
    this.backgroundColor,
    this.gradient,
    this.isGlowing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const defaultBg = Colors.white;

    final cardChild = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? (gradient == null ? defaultBg : null),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isGlowing
                ? AppColors.shadowColor
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isGlowing ? 30 : 16,
            offset: Offset(0, isGlowing ? 12 : 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardChild,
      );
    }

    return cardChild;
  }
}
