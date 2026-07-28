import '../../domain/entities/water_log.dart';

class WaterLogModel extends WaterLog {
  const WaterLogModel({
    required super.id,
    required super.amountMl,
    required super.loggedAt,
    super.note,
  });

  factory WaterLogModel.fromDomain(WaterLog log) {
    return WaterLogModel(
      id: log.id,
      amountMl: log.amountMl,
      loggedAt: log.loggedAt,
      note: log.note,
    );
  }

  factory WaterLogModel.fromJson(Map<String, dynamic> json) {
    return WaterLogModel(
      id: json['id'] as String,
      amountMl: json['amountMl'] as int? ?? 250,
      loggedAt: DateTime.tryParse(json['loggedAt'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'loggedAt': loggedAt.toIso8601String(),
      if (note != null) 'note': note,
    };
  }
}
