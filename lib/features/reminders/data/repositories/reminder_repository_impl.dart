import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/reminder_entities.dart';
import '../../domain/repositories/i_reminder_repository.dart';

class ReminderRepositoryImpl implements IReminderRepository {
  final List<PersistentReminder> _activeReminders = [
    PersistentReminder(
      id: 'rem_water_init',
      type: ReminderType.water,
      title: '💧 Hydration Time!',
      message: 'You have not logged water in the last 2 hours. Please drink 250ml now to meet your daily 3,200ml goal!',
      timestamp: DateTime.now(),
      actionLabel: 'Log +250ml Water Now',
    ),
  ];

  @override
  Future<Result<List<PersistentReminder>>> getActiveReminders() async {
    try {
      final active = _activeReminders.where((r) => !r.isDismissed).toList();
      return Result.success(List.unmodifiable(active));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<PersistentReminder>> triggerTestAlarm(ReminderType type) async {
    try {
      final newId = 'rem_${DateTime.now().millisecondsSinceEpoch}';
      late PersistentReminder reminder;

      switch (type) {
        case ReminderType.water:
          reminder = PersistentReminder(
            id: newId,
            type: ReminderType.water,
            title: '💧 Hydration Alarm!',
            message: 'Your body needs water for muscle performance. Log 250ml immediately!',
            timestamp: DateTime.now(),
            actionLabel: 'Log +250ml Water Now',
          );
          break;
        case ReminderType.wakeUp:
          reminder = PersistentReminder(
            id: newId,
            type: ReminderType.wakeUp,
            title: '⏰ Good Morning Alarm!',
            message: 'Time to wake up! Check your sleep quality & recovery index now.',
            timestamp: DateTime.now(),
            actionLabel: 'Check Recovery Score',
          );
          break;
        case ReminderType.sleep:
          reminder = PersistentReminder(
            id: newId,
            type: ReminderType.sleep,
            title: '🌙 Bedtime Schedule Alarm!',
            message: 'Prepare for 8 hours of restorative sleep to achieve 90%+ recovery tomorrow.',
            timestamp: DateTime.now(),
            actionLabel: 'Log Bedtime Prep',
          );
          break;
        case ReminderType.medicine:
          reminder = PersistentReminder(
            id: newId,
            type: ReminderType.medicine,
            title: '💊 Medication Schedule Alert!',
            message: 'Time to take Multivitamins & Omega 3 dosage as prescribed.',
            timestamp: DateTime.now(),
            actionLabel: 'Mark Dose Taken',
          );
          break;
      }

      _activeReminders.add(reminder);
      return Result.success(reminder);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resolveReminder(String id) async {
    try {
      final index = _activeReminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _activeReminders[index] = _activeReminders[index].copyWith(isDismissed: true);
      }
      return Result.success(null);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }
}
