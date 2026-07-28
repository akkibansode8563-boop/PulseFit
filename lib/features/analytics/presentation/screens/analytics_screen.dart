import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Analytics & Insights'),
      ),
      body: analyticsAsync.when(
        data: (state) => _buildAnalyticsContent(context, state),
        loading: () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              LoadingShimmer(height: 140),
              SizedBox(height: 16),
              LoadingShimmer(height: 200),
              SizedBox(height: 16),
              LoadingShimmer(height: 180),
            ],
          ),
        ),
        error: (err, stack) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(analyticsProvider),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, AnalyticsState state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          color: AppColors.darkSurface,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text('${state.overallHealthScore}', style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Overall AI Health Score', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text('Optimal Compliance (90%+ across calories, protein, hydration & recovery)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Weekly Calorie & Protein Trends', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: state.weeklySummaries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.caloriesLogged.toDouble())).toList(),
                      isCurved: true,
                      color: AppColors.warning,
                      barWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Hydration & Sleep Compliance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: state.weeklySummaries.asMap().entries.map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(toY: e.value.waterLoggedMl.toDouble() / 100, color: AppColors.secondary, width: 12),
                    ],
                  )).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
