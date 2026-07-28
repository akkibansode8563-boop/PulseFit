import '../../../../core/error/result.dart';
import '../entities/analytics_entities.dart';

abstract class IAnalyticsRepository {
  Future<Result<List<DailyHealthSummary>>> getWeeklyAnalytics();
  Future<Result<int>> calculateOverallHealthScore();
}
