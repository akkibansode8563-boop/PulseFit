import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/features/water/data/repositories/water_repository_impl.dart';

void main() {
  group('Water Feature Tests', () {
    final repo = WaterRepositoryImpl();

    test('getTodayWaterLogs starts at 0ml with empty initial logs', () async {
      final result = await repo.getTodayWaterLogs();
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.length, equals(0));
    });

    test('logWater adds +250ml water entry successfully', () async {
      final initialResult = await repo.getTodayWaterLogs();
      final initialCount = initialResult.data?.length ?? 0;

      final addResult = await repo.logWater(250);
      expect(addResult.isSuccess, isTrue);
      expect(addResult.data?.amountMl, equals(250));

      final updatedResult = await repo.getTodayWaterLogs();
      expect(updatedResult.data?.length, equals(initialCount + 1));
    });

    test('deleteWaterLog removes specific water entry', () async {
      await repo.deleteWaterLog('water_1');
      final updatedResult = await repo.getTodayWaterLogs();
      expect(updatedResult.data?.any((w) => w.id == 'water_1'), isFalse);
    });

    test('resetTodayWater clears all water logs', () async {
      await repo.resetTodayWater();
      final updatedResult = await repo.getTodayWaterLogs();
      expect(updatedResult.data?.isEmpty, isTrue);
    });
  });
}
