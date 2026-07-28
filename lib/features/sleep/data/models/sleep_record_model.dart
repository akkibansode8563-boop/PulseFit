import '../../domain/entities/sleep_record.dart';

class SleepRecordModel extends SleepRecord {
  const SleepRecordModel({
    required super.id,
    required super.durationMinutes,
    required super.deepSleepPercentage,
    required super.remSleepPercentage,
    required super.lightSleepPercentage,
    required super.sleepQualityScore,
    required super.recoveryScore,
    required super.loggedAt,
  });

  factory SleepRecordModel.fromDomain(SleepRecord record) {
    return SleepRecordModel(
      id: record.id,
      durationMinutes: record.durationMinutes,
      deepSleepPercentage: record.deepSleepPercentage,
      remSleepPercentage: record.remSleepPercentage,
      lightSleepPercentage: record.lightSleepPercentage,
      sleepQualityScore: record.sleepQualityScore,
      recoveryScore: record.recoveryScore,
      loggedAt: record.loggedAt,
    );
  }

  factory SleepRecordModel.fromJson(Map<String, dynamic> json) {
    return SleepRecordModel(
      id: json['id'] as String,
      durationMinutes: json['durationMinutes'] as int? ?? 480,
      deepSleepPercentage: json['deepSleepPercentage'] as int? ?? 25,
      remSleepPercentage: json['remSleepPercentage'] as int? ?? 20,
      lightSleepPercentage: json['lightSleepPercentage'] as int? ?? 55,
      sleepQualityScore: json['sleepQualityScore'] as int? ?? 85,
      recoveryScore: json['recoveryScore'] as int? ?? 88,
      loggedAt: DateTime.tryParse(json['loggedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'durationMinutes': durationMinutes,
        'deepSleepPercentage': deepSleepPercentage,
        'remSleepPercentage': remSleepPercentage,
        'lightSleepPercentage': lightSleepPercentage,
        'sleepQualityScore': sleepQualityScore,
        'recoveryScore': recoveryScore,
        'loggedAt': loggedAt.toIso8601String(),
      };
}
