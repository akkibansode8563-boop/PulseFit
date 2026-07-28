import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:ai_health_manager/features/reminders/domain/entities/reminder_entities.dart';

void main() {
  group('Persistent Reminders Feature Tests', () {
    final repo = ReminderRepositoryImpl();

    test('getActiveReminders returns initial un-dismissed hydration alarm', () async {
      final res = await repo.getActiveReminders();
      expect(res.isSuccess, isTrue);
      expect(res.data?.isNotEmpty, isTrue);
      expect(res.data?.first.type, equals(ReminderType.water));
    });

    test('triggerTestAlarm creates new active full-screen alarm correctly', () async {
      final triggerRes = await repo.triggerTestAlarm(ReminderType.medicine);
      expect(triggerRes.isSuccess, isTrue);
      expect(triggerRes.data?.type, equals(ReminderType.medicine));

      final activeList = await repo.getActiveReminders();
      expect(activeList.data?.any((r) => r.type == ReminderType.medicine), isTrue);
    });

    test('resolveReminder dismisses target active alarm', () async {
      final activeList = await repo.getActiveReminders();
      final targetId = activeList.data!.first.id;

      final resolveRes = await repo.resolveReminder(targetId);
      expect(resolveRes.isSuccess, isTrue);

      final updatedList = await repo.getActiveReminders();
      expect(updatedList.data?.any((r) => r.id == targetId), isFalse);
    });
  });
}
