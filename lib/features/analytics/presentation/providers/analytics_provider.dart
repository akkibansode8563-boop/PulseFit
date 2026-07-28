import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../domain/repositories/i_analytics_repository.dart';

final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl();
});

class AnalyticsState {
  final List<DailyHealthSummary> weeklySummaries;
  final int overallHealthScore;

  const AnalyticsState({
    required this.weeklySummaries,
    required this.overallHealthScore,
  });
}

class AnalyticsNotifier extends AsyncNotifier<AnalyticsState> {
  @override
  FutureOr<AnalyticsState> build() async {
    final repo = ref.watch(analyticsRepositoryProvider);
    final weeklyRes = await repo.getWeeklyAnalytics();
    final scoreRes = await repo.calculateOverallHealthScore();

    return AnalyticsState(
      weeklySummaries: weeklyRes.data ?? [],
      overallHealthScore: scoreRes.data ?? 90,
    );
  }
}

final analyticsProvider = AsyncNotifierProvider<AnalyticsNotifier, AnalyticsState>(
  AnalyticsNotifier.new,
);
