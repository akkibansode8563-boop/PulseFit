import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/features/sleep/domain/entities/sleep_record.dart';
import 'package:ai_health_manager/features/sleep/data/repositories/sleep_repository_impl.dart';

void main() {
  group('Sleep Feature Tests', () {
    final repo = SleepRepositoryImpl();

    test('getTodaySleepRecord returns initial cached sleep record', () async {
      final result = await repo.getTodaySleepRecord();
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.durationMinutes, equals(465));
      expect(result.data?.recoveryScore, equals(90));
    });

    test('logSleepRecord persists new sleep record cleanly', () async {
      final newRecord = SleepRecord(
        id: 'sleep_test_99',
        durationMinutes: 480,
        deepSleepPercentage: 30,
        remSleepPercentage: 25,
        lightSleepPercentage: 45,
        sleepQualityScore: 92,
        recoveryScore: 95,
        loggedAt: DateTime.now(),
      );

      final logResult = await repo.logSleepRecord(newRecord);
      expect(logResult.isSuccess, isTrue);
      expect(logResult.data?.sleepQualityScore, equals(92));

      final updatedResult = await repo.getTodaySleepRecord();
      expect(updatedResult.data?.id, equals('sleep_test_99'));
    });
  });
}
