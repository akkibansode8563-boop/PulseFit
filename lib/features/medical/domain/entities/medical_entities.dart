import 'package:flutter/foundation.dart';

enum MedicineCategory { pill, liquid, injection }

@immutable
class MedicineReminder {
  final String id;
  final String medicineName;
  final String dosage;
  final String timeOfDay;
  final MedicineCategory category;
  final bool isTaken;

  const MedicineReminder({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.timeOfDay,
    required this.category,
    this.isTaken = false,
  });

  MedicineReminder copyWith({
    String? id,
    String? medicineName,
    String? dosage,
    String? timeOfDay,
    MedicineCategory? category,
    bool? isTaken,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      category: category ?? this.category,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}

enum RecordCategory { labResult, prescription, vaccination }

@immutable
class MedicalRecord {
  final String id;
  final String title;
  final String doctorName;
  final RecordCategory category;
  final DateTime date;
  final String summary;
  final String? imagePath;

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.category,
    required this.date,
    required this.summary,
    this.imagePath,
  });
}
