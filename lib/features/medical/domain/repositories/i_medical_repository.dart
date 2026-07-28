import '../../../../core/error/result.dart';
import '../entities/medical_entities.dart';

abstract class IMedicalRepository {
  Future<Result<List<MedicineReminder>>> getMedicineReminders();
  Future<Result<MedicineReminder>> toggleMedicineTaken(String id);
  Future<Result<MedicineReminder>> addMedicineReminder(MedicineReminder reminder);
  Future<Result<List<MedicalRecord>>> getMedicalRecords();
  Future<Result<MedicalRecord>> addMedicalRecord(MedicalRecord record);
}
