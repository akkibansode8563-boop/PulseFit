import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../domain/repositories/i_analytics_repository.dart';
import '../models/analytics_models.dart';

class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  final List<DailyHealthSummaryModel> _weeklySummaries = [
    DailyHealthSummaryModel(date: DateTime.now().subtract(const Duration(days: 6)), caloriesLogged: 2100, proteinLoggedGrams: 140, waterLoggedMl: 2800, workoutVolumeKg: 1200, sleepMinutes: 450, healthScore: 82),
    DailyHealthSummaryModel(date: DateTime.now().subtract(const Duration(days: 5)), caloriesLogged: 2350, proteinLoggedGrams: 155, waterLoggedMl: 3100, workoutVolumeKg: 1400, sleepMinutes: 470, healthScore: 88),
    DailyHealthSummaryModel(date: DateTime.now().subtract(const Duration(days: 4)), caloriesLogged: 2200, proteinLoggedGrams: 150, waterLoggedMl: 3000, workoutVolumeKg: 0, sleepMinutes: 480, healthScore: 85),
    DailyHealthSummaryModel(date: DateTime.now().subtract(const Duration(days: 3)), caloriesLogged: 2450, proteinLoggedGrams: 165, waterLoggedMl: 3200, workoutVolumeKg: 1600, sleepMinutes: 460, healthScore: 92),
    DailyHealthSummaryModel(date: DateTime.now().subtract(const Duration(days: 2)), caloriesLogged: 2300, proteinLoggedGrams: 160, waterLoggedMl: 3200, workoutVolumeKg: 1500, sleepMinutes: 490, healthScore: 90),
    DailyHealthSummaryModel(date: DateTime.now().subtract(const Duration(days: 1)), caloriesLogged: 2400, proteinLoggedGrams: 160, waterLoggedMl: 3200, workoutVolumeKg: 1480, sleepMinutes: 465, healthScore: 94),
    DailyHealthSummaryModel(date: DateTime.now(), caloriesLogged: 2400, proteinLoggedGrams: 160, waterLoggedMl: 3200, workoutVolumeKg: 1480, sleepMinutes: 465, healthScore: 95),
  ];

  @override
  Future<Result<List<DailyHealthSummary>>> getWeeklyAnalytics() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return Result.success(List.unmodifiable(_weeklySummaries));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> calculateOverallHealthScore() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final avgScore = _weeklySummaries.fold(0, (sum, s) => sum + s.healthScore) ~/ _weeklySummaries.length;
      return Result.success(avgScore);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }
}
