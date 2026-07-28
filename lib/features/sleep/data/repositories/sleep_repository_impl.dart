import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/sleep_record.dart';
import '../../domain/repositories/i_sleep_repository.dart';
import '../models/sleep_record_model.dart';

class SleepRepositoryImpl implements ISleepRepository {
  SleepRecordModel? _todayRecord = SleepRecordModel(
    id: 'sleep_1',
    durationMinutes: 465, // 7h 45m
    deepSleepPercentage: 24,
    remSleepPercentage: 22,
    lightSleepPercentage: 54,
    sleepQualityScore: 88,
    recoveryScore: 90,
    loggedAt: DateTime.now().subtract(const Duration(hours: 6)),
  );

  @override
  Future<Result<SleepRecord?>> getTodaySleepRecord() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      return Result.success(_todayRecord);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<SleepRecord>> logSleepRecord(SleepRecord record) async {
    try {
      _todayRecord = SleepRecordModel.fromDomain(record);
      await Future.delayed(const Duration(milliseconds: 150));
      return Result.success(_todayRecord!);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }
}
