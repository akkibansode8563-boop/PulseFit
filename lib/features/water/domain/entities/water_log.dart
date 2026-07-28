import 'package:flutter/foundation.dart';

@immutable
class WaterLog {
  final String id;
  final int amountMl;
  final DateTime loggedAt;
  final String? note; // e.g. '3 Sips', '1 Glass'

  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
    this.note,
  });

  WaterLog copyWith({
    String? id,
    int? amountMl,
    DateTime? loggedAt,
    String? note,
  }) {
    return WaterLog(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      loggedAt: loggedAt ?? this.loggedAt,
      note: note ?? this.note,
    );
  }
}
