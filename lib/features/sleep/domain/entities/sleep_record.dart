import 'package:flutter/foundation.dart';

@immutable
class SleepRecord {
  final String id;
  final int durationMinutes;
  final int deepSleepPercentage;
  final int remSleepPercentage;
  final int lightSleepPercentage;
  final int sleepQualityScore; // 1 - 100
  final int recoveryScore;     // 1 - 100
  final DateTime loggedAt;

  const SleepRecord({
    required this.id,
    required this.durationMinutes,
    required this.deepSleepPercentage,
    required this.remSleepPercentage,
    required this.lightSleepPercentage,
    required this.sleepQualityScore,
    required this.recoveryScore,
    required this.loggedAt,
  });

  double get durationHours => durationMinutes / 60.0;

  SleepRecord copyWith({
    String? id,
    int? durationMinutes,
    int? deepSleepPercentage,
    int? remSleepPercentage,
    int? lightSleepPercentage,
    int? sleepQualityScore,
    int? recoveryScore,
    DateTime? loggedAt,
  }) {
    return SleepRecord(
      id: id ?? this.id,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      deepSleepPercentage: deepSleepPercentage ?? this.deepSleepPercentage,
      remSleepPercentage: remSleepPercentage ?? this.remSleepPercentage,
      lightSleepPercentage: lightSleepPercentage ?? this.lightSleepPercentage,
      sleepQualityScore: sleepQualityScore ?? this.sleepQualityScore,
      recoveryScore: recoveryScore ?? this.recoveryScore,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }
}
