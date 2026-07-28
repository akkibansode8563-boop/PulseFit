import '../../../../core/error/result.dart';
import '../entities/reminder_entities.dart';

abstract class IReminderRepository {
  Future<Result<List<PersistentReminder>>> getActiveReminders();
  Future<Result<PersistentReminder>> triggerTestAlarm(ReminderType type);
  Future<Result<void>> resolveReminder(String id);
}
