import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/water_log.dart';
import '../../domain/repositories/i_water_repository.dart';
import '../models/water_log_model.dart';

class WaterRepositoryImpl implements IWaterRepository {
  final List<WaterLogModel> _localWaterLogs = [];

  @override
  Future<Result<List<WaterLog>>> getTodayWaterLogs() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final now = DateTime.now();
      // Automatic Daily Cycle Reset: Filter only today's logs
      final todayLogs = _localWaterLogs.where((log) {
        return log.loggedAt.year == now.year &&
            log.loggedAt.month == now.month &&
            log.loggedAt.day == now.day;
      }).toList();

      return Result.success(List.unmodifiable(todayLogs));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<WaterLog>> logWater(int amountMl, {String? note}) async {
    try {
      final newLog = WaterLogModel(
        id: 'water_${DateTime.now().millisecondsSinceEpoch}',
        amountMl: amountMl,
        loggedAt: DateTime.now(),
        note: note,
      );
      _localWaterLogs.insert(0, newLog);
      await Future.delayed(const Duration(milliseconds: 150));
      return Result.success(newLog);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteWaterLog(String logId) async {
    try {
      _localWaterLogs.removeWhere((log) => log.id == logId);
      await Future.delayed(const Duration(milliseconds: 150));
      return Result.success(null);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resetTodayWater() async {
    try {
      _localWaterLogs.clear();
      await Future.delayed(const Duration(milliseconds: 150));
      return Result.success(null);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }
}
