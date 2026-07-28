import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/medical_entities.dart';
import '../../domain/repositories/i_medical_repository.dart';
import '../models/medical_models.dart';

class MedicalRepositoryImpl implements IMedicalRepository {
  final List<MedicineReminderModel> _reminders = [
    const MedicineReminderModel(
      id: 'med_1',
      medicineName: 'Multivitamin Complex',
      dosage: '1 Capsule',
      timeOfDay: '08:00 AM',
      category: MedicineCategory.pill,
      isTaken: true,
    ),
    const MedicineReminderModel(
      id: 'med_2',
      medicineName: 'Omega-3 Fish Oil',
      dosage: '1000 mg Softgel',
      timeOfDay: '01:00 PM',
      category: MedicineCategory.pill,
      isTaken: false,
    ),
  ];

  final List<MedicalRecordModel> _records = [
    MedicalRecordModel(
      id: 'rec_1',
      title: 'Annual Blood Panel Analysis',
      doctorName: 'Dr. Sarah Jenkins',
      category: RecordCategory.labResult,
      date: DateTime.now().subtract(const Duration(days: 14)),
      summary: 'Lipid panel, fasting glucose, and Vitamin D levels within optimal health ranges.',
    ),
  ];

  @override
  Future<Result<List<MedicineReminder>>> getMedicineReminders() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      return Result.success(List.unmodifiable(_reminders));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<MedicineReminder>> toggleMedicineTaken(String id) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        final existing = _reminders[index];
        final updated = existing.copyWith(isTaken: !existing.isTaken);
        _reminders[index] = MedicineReminderModel.fromDomain(updated);
        await Future.delayed(const Duration(milliseconds: 100));
        return Result.success(_reminders[index]);
      }
      return Result.error(CacheFailure('Reminder not found'));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<MedicineReminder>> addMedicineReminder(MedicineReminder reminder) async {
    try {
      final model = MedicineReminderModel.fromDomain(reminder);
      _reminders.add(model);
      await Future.delayed(const Duration(milliseconds: 150));
      return Result.success(model);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<MedicalRecord>>> getMedicalRecords() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      return Result.success(List.unmodifiable(_records));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<MedicalRecord>> addMedicalRecord(MedicalRecord record) async {
    try {
      final model = MedicalRecordModel.fromDomain(record);
      _records.insert(0, model);
      await Future.delayed(const Duration(milliseconds: 150));
      return Result.success(model);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }
}
