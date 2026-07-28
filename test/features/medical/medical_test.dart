import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/features/medical/domain/entities/medical_entities.dart';
import 'package:ai_health_manager/features/medical/data/repositories/medical_repository_impl.dart';

void main() {
  group('Medical Feature Tests', () {
    final repo = MedicalRepositoryImpl();

    test('getMedicineReminders returns default medication schedule', () async {
      final result = await repo.getMedicineReminders();
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.length, equals(2));
      expect(result.data?.first.medicineName, contains('Multivitamin'));
    });

    test('toggleMedicineTaken updates medication taken status', () async {
      final toggleResult = await repo.toggleMedicineTaken('med_1');
      expect(toggleResult.isSuccess, isTrue);
      expect(toggleResult.data?.isTaken, isFalse);
    });

    test('addMedicalRecord adds new document to medical history', () async {
      final initialRecords = await repo.getMedicalRecords();
      final count = initialRecords.data?.length ?? 0;

      final newRecord = MedicalRecord(
        id: 'rec_test_1',
        title: 'Vaccination Certificate',
        doctorName: 'Dr. Adams',
        category: RecordCategory.vaccination,
        date: DateTime.now(),
        summary: 'Flu shot administered.',
      );

      final addResult = await repo.addMedicalRecord(newRecord);
      expect(addResult.isSuccess, isTrue);

      final updatedRecords = await repo.getMedicalRecords();
      expect(updatedRecords.data?.length, equals(count + 1));
    });
  });
}
