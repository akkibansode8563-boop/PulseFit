import '../../../../core/error/result.dart';
import '../entities/water_log.dart';

abstract class IWaterRepository {
  Future<Result<List<WaterLog>>> getTodayWaterLogs();
  Future<Result<WaterLog>> logWater(int amountMl, {String? note});
  Future<Result<void>> deleteWaterLog(String logId);
  Future<Result<void>> resetTodayWater();
}
