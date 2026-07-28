import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/water_repository_impl.dart';
import '../../domain/entities/water_log.dart';
import '../../domain/repositories/i_water_repository.dart';

final waterRepositoryProvider = Provider<IWaterRepository>((ref) {
  return WaterRepositoryImpl();
});

class WaterNotifier extends AsyncNotifier<List<WaterLog>> {
  @override
  FutureOr<List<WaterLog>> build() async {
    final repo = ref.watch(waterRepositoryProvider);
    final result = await repo.getTodayWaterLogs();
    return result.fold(
      onSuccess: (logs) => logs,
      onError: (failure) => throw Exception(failure.message),
    );
  }

  Future<void> addWater(int amountMl, {String? note}) async {
    final repo = ref.read(waterRepositoryProvider);
    final result = await repo.logWater(amountMl, note: note);
    result.fold(
      onSuccess: (_) async {
        final updated = await repo.getTodayWaterLogs();
        state = AsyncValue.data(updated.data ?? []);
      },
      onError: (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
    );
  }

  Future<void> deleteWaterLog(String logId) async {
    final repo = ref.read(waterRepositoryProvider);
    await repo.deleteWaterLog(logId);
    final updated = await repo.getTodayWaterLogs();
    state = AsyncValue.data(updated.data ?? []);
  }

  Future<void> resetWater() async {
    final repo = ref.read(waterRepositoryProvider);
    await repo.resetTodayWater();
    state = const AsyncValue.data([]);
  }
}

final waterProvider = AsyncNotifierProvider<WaterNotifier, List<WaterLog>>(
  WaterNotifier.new,
);
