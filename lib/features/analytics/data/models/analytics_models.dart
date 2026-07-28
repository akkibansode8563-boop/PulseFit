import '../../domain/entities/analytics_entities.dart';

class DailyHealthSummaryModel extends DailyHealthSummary {
  const DailyHealthSummaryModel({
    required super.date,
    required super.caloriesLogged,
    required super.proteinLoggedGrams,
    required super.waterLoggedMl,
    required super.workoutVolumeKg,
    required super.sleepMinutes,
    required super.healthScore,
  });

  factory DailyHealthSummaryModel.fromDomain(DailyHealthSummary domain) {
    return DailyHealthSummaryModel(
      date: domain.date,
      caloriesLogged: domain.caloriesLogged,
      proteinLoggedGrams: domain.proteinLoggedGrams,
      waterLoggedMl: domain.waterLoggedMl,
      workoutVolumeKg: domain.workoutVolumeKg,
      sleepMinutes: domain.sleepMinutes,
      healthScore: domain.healthScore,
    );
  }

  factory DailyHealthSummaryModel.fromJson(Map<String, dynamic> json) {
    return DailyHealthSummaryModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      caloriesLogged: json['caloriesLogged'] as int? ?? 0,
      proteinLoggedGrams: json['proteinLoggedGrams'] as int? ?? 0,
      waterLoggedMl: json['waterLoggedMl'] as int? ?? 0,
      workoutVolumeKg: (json['workoutVolumeKg'] as num?)?.toDouble() ?? 0.0,
      sleepMinutes: json['sleepMinutes'] as int? ?? 0,
      healthScore: json['healthScore'] as int? ?? 85,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'caloriesLogged': caloriesLogged,
        'proteinLoggedGrams': proteinLoggedGrams,
        'waterLoggedMl': waterLoggedMl,
        'workoutVolumeKg': workoutVolumeKg,
        'sleepMinutes': sleepMinutes,
        'healthScore': healthScore,
      };
}
