import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.soraTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.card,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textPrimary,
        onError: Colors.white,
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displaySmall: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
        bodySmall: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        unselectedLabelStyle: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
