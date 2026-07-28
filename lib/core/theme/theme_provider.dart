import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light); // Lock single default light theme mode

  void toggleTheme() {
    state = ThemeMode.light; // Always stay on light theme mode
  }

  void setThemeMode(ThemeMode mode) {
    state = ThemeMode.light;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
