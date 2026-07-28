import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sleep_repository_impl.dart';
import '../../domain/entities/sleep_record.dart';
import '../../domain/repositories/i_sleep_repository.dart';

final sleepRepositoryProvider = Provider<ISleepRepository>((ref) {
  return SleepRepositoryImpl();
});

class SleepNotifier extends AsyncNotifier<SleepRecord?> {
  @override
  FutureOr<SleepRecord?> build() async {
    final repo = ref.watch(sleepRepositoryProvider);
    final result = await repo.getTodaySleepRecord();
    return result.fold(
      onSuccess: (record) => record,
      onError: (failure) => throw Exception(failure.message),
    );
  }

  Future<void> logSleep({
    required int durationMinutes,
    required int deepSleepPct,
    required int remSleepPct,
  }) async {
    final lightPct = (100 - deepSleepPct - remSleepPct).clamp(0, 100);

    // Calculate AI Recovery & Quality score algorithmically
    final qualityScore = ((durationMinutes / 480.0 * 50) + (deepSleepPct * 1.2) + (remSleepPct * 1.0)).clamp(1.0, 100.0).round();
    final recoveryScore = ((qualityScore * 0.85) + 12).clamp(1.0, 100.0).round();

    final record = SleepRecord(
      id: 'sleep_${DateTime.now().millisecondsSinceEpoch}',
      durationMinutes: durationMinutes,
      deepSleepPercentage: deepSleepPct,
      remSleepPercentage: remSleepPct,
      lightSleepPercentage: lightPct,
      sleepQualityScore: qualityScore,
      recoveryScore: recoveryScore,
      loggedAt: DateTime.now(),
    );

    final repo = ref.read(sleepRepositoryProvider);
    state = const AsyncValue.loading();
    final result = await repo.logSleepRecord(record);
    result.fold(
      onSuccess: (saved) => state = AsyncValue.data(saved),
      onError: (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
    );
  }
}

final sleepProvider = AsyncNotifierProvider<SleepNotifier, SleepRecord?>(
  SleepNotifier.new,
);
