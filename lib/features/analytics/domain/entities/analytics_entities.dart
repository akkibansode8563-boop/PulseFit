import 'package:flutter/foundation.dart';

@immutable
class DailyHealthSummary {
  final DateTime date;
  final int caloriesLogged;
  final int proteinLoggedGrams;
  final int waterLoggedMl;
  final double workoutVolumeKg;
  final int sleepMinutes;
  final int healthScore; // 0 - 100

  const DailyHealthSummary({
    required this.date,
    required this.caloriesLogged,
    required this.proteinLoggedGrams,
    required this.waterLoggedMl,
    required this.workoutVolumeKg,
    required this.sleepMinutes,
    required this.healthScore,
  });

  double get sleepHours => sleepMinutes / 60.0;
}
