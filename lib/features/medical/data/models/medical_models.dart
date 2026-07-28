import '../../domain/entities/medical_entities.dart';

class MedicineReminderModel extends MedicineReminder {
  const MedicineReminderModel({
    required super.id,
    required super.medicineName,
    required super.dosage,
    required super.timeOfDay,
    required super.category,
    super.isTaken,
  });

  factory MedicineReminderModel.fromDomain(MedicineReminder reminder) {
    return MedicineReminderModel(
      id: reminder.id,
      medicineName: reminder.medicineName,
      dosage: reminder.dosage,
      timeOfDay: reminder.timeOfDay,
      category: reminder.category,
      isTaken: reminder.isTaken,
    );
  }

  factory MedicineReminderModel.fromJson(Map<String, dynamic> json) {
    return MedicineReminderModel(
      id: json['id'] as String,
      medicineName: json['medicineName'] as String? ?? 'Medication',
      dosage: json['dosage'] as String? ?? '1 tablet',
      timeOfDay: json['timeOfDay'] as String? ?? '08:00 AM',
      category: MedicineCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MedicineCategory.pill,
      ),
      isTaken: json['isTaken'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicineName': medicineName,
        'dosage': dosage,
        'timeOfDay': timeOfDay,
        'category': category.name,
        'isTaken': isTaken,
      };
}

class MedicalRecordModel extends MedicalRecord {
  const MedicalRecordModel({
    required super.id,
    required super.title,
    required super.doctorName,
    required super.category,
    required super.date,
    required super.summary,
    super.imagePath,
  });

  factory MedicalRecordModel.fromDomain(MedicalRecord record) {
    return MedicalRecordModel(
      id: record.id,
      title: record.title,
      doctorName: record.doctorName,
      category: record.category,
      date: record.date,
      summary: record.summary,
      imagePath: record.imagePath,
    );
  }

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Medical Document',
      doctorName: json['doctorName'] as String? ?? 'Dr. Smith',
      category: RecordCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => RecordCategory.labResult,
      ),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      summary: json['summary'] as String? ?? 'No summary available',
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'doctorName': doctorName,
        'category': category.name,
        'date': date.toIso8601String(),
        'summary': summary,
        'imagePath': imagePath,
      };
}
