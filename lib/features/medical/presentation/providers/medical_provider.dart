import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/medical_repository_impl.dart';
import '../../domain/entities/medical_entities.dart';
import '../../domain/repositories/i_medical_repository.dart';

final medicalRepositoryProvider = Provider<IMedicalRepository>((ref) {
  return MedicalRepositoryImpl();
});

class MedicalState {
  final List<MedicineReminder> reminders;
  final List<MedicalRecord> records;

  const MedicalState({
    required this.reminders,
    required this.records,
  });
}

class MedicalNotifier extends AsyncNotifier<MedicalState> {
  @override
  FutureOr<MedicalState> build() async {
    final repo = ref.watch(medicalRepositoryProvider);
    final remindersRes = await repo.getMedicineReminders();
    final recordsRes = await repo.getMedicalRecords();

    return MedicalState(
      reminders: remindersRes.data ?? [],
      records: recordsRes.data ?? [],
    );
  }

  Future<void> toggleMedicine(String id) async {
    final repo = ref.read(medicalRepositoryProvider);
    await repo.toggleMedicineTaken(id);
    ref.invalidateSelf();
  }

  Future<void> addMedicine({
    required String name,
    required String dosage,
    required String timeOfDay,
    required MedicineCategory category,
  }) async {
    final newReminder = MedicineReminder(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      medicineName: name,
      dosage: dosage,
      timeOfDay: timeOfDay,
      category: category,
    );

    final repo = ref.read(medicalRepositoryProvider);
    state = const AsyncValue.loading();
    await repo.addMedicineReminder(newReminder);
    ref.invalidateSelf();
  }

  Future<void> addRecord({
    required String title,
    required String doctorName,
    required RecordCategory category,
    required String summary,
  }) async {
    final newRecord = MedicalRecord(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      doctorName: doctorName,
      category: category,
      date: DateTime.now(),
      summary: summary,
    );

    final repo = ref.read(medicalRepositoryProvider);
    state = const AsyncValue.loading();
    await repo.addMedicalRecord(newRecord);
    ref.invalidateSelf();
  }
}

final medicalProvider = AsyncNotifierProvider<MedicalNotifier, MedicalState>(
  MedicalNotifier.new,
);
