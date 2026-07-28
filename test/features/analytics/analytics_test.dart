import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/features/analytics/data/repositories/analytics_repository_impl.dart';

void main() {
  group('Analytics Feature Tests', () {
    final repo = AnalyticsRepositoryImpl();

    test('getWeeklyAnalytics returns 7 days of historical health summaries', () async {
      final result = await repo.getWeeklyAnalytics();
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.length, equals(7));
      expect(result.data?.first.caloriesLogged, greaterThan(0));
    });

    test('calculateOverallHealthScore computes high average wellness index', () async {
      final scoreRes = await repo.calculateOverallHealthScore();
      expect(scoreRes.isSuccess, isTrue);
      expect(scoreRes.data, greaterThanOrEqualTo(85));
    });
  });
}
