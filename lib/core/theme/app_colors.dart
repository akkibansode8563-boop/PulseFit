import 'package:flutter/material.dart';

/// Official PulseFit Color System (Matching Brand Specification Sheet)
class AppColors {
  // Brand Primary Palette
  static const Color primary = Color(0xFF8FD36B);       // Vibrant Fresh Sage
  static const Color primaryDark = Color(0xFF5B9A54);   // Forest Green
  static const Color lightMint = Color(0xFFC8F2A3);     // Soft Light Mint Accent
  static const Color surfaceMint = Color(0xFFEEF7EA);   // Very Light Mint Card Surface

  // Aliases for legacy component references
  static const Color secondary = primaryDark;
  static const Color accent = primary;
  static const Color mintPrimary = primary;
  static const Color mintBackground = surfaceMint;

  // Neutral Backgrounds & Cards
  static const Color background = Color(0xFFF8FAF6);    // Warm Off-White Background
  static const Color darkBackground = Color(0xFF1E2A24);
  static const Color card = Color(0xFFFFFFFF);          // Pure White Card Surface
  static const Color surface = card;
  static const Color darkSurface = Color(0xFF1E2A24);
  static const Color darkSurfaceVariant = Color(0xFF2E3D35);
  static const Color border = Color(0xFFE6ECE5);        // Soft Grey Divider
  static const Color divider = border;
  static const Color shadowColor = Color(0x1A000000);

  // Typography Palette (High-Contrast Specifications)
  static const Color textPrimary = Color(0xFF1E2A24);   // Deep Charcoal (#1E2A24)
  static const Color textSecondary = Color(0xFF6C7B73); // Grey Green (#6C7B73)
  static const Color lightTextPrimary = textPrimary;
  static const Color lightTextSecondary = textSecondary;

  // Status & Feedback Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFF7B84B);
  static const Color error = Color(0xFFF46A6A);

  // Macro Palette
  static const Color protein = Color(0xFF5B9A54);
  static const Color carbs = Color(0xFF8FD36B);
  static const Color fat = Color(0xFFF7B84B);
  static const Color water = Color(0xFF4A90E2);
  static const Color macroProtein = protein;
  static const Color macroFat = fat;
  static const Color macroCarbs = carbs;

  // Border Radii
  static const double radiusCard = 20.0;
  static const double radiusButton = 16.0;
  static const double radiusChip = 50.0;
  static const double radiusBottomSheet = 28.0;

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [lightMint, primary, primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [surfaceMint, Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
