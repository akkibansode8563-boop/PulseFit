import '../../../../core/error/result.dart';
import '../entities/sleep_record.dart';

abstract class ISleepRepository {
  Future<Result<SleepRecord?>> getTodaySleepRecord();
  Future<Result<SleepRecord>> logSleepRecord(SleepRecord record);
}
