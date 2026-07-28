import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/entities/reminder_entities.dart';
import '../../domain/repositories/i_reminder_repository.dart';

final reminderRepositoryProvider = Provider<IReminderRepository>((ref) {
  return ReminderRepositoryImpl();
});

class ReminderNotifier extends AsyncNotifier<List<PersistentReminder>> {
  @override
  FutureOr<List<PersistentReminder>> build() async {
    final repo = ref.watch(reminderRepositoryProvider);
    final res = await repo.getActiveReminders();
    return res.data ?? [];
  }

  Future<void> triggerAlarm(ReminderType type) async {
    final repo = ref.read(reminderRepositoryProvider);
    await repo.triggerTestAlarm(type);
    final updated = await repo.getActiveReminders();
    state = AsyncValue.data(updated.data ?? []);
  }

  Future<void> resolveReminder(String id) async {
    final repo = ref.read(reminderRepositoryProvider);
    await repo.resolveReminder(id);
    final updated = await repo.getActiveReminders();
    state = AsyncValue.data(updated.data ?? []);
  }
}

final reminderProvider = AsyncNotifierProvider<ReminderNotifier, List<PersistentReminder>>(
  ReminderNotifier.new,
);
