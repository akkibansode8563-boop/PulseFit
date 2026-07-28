import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/nutrition/presentation/providers/nutrition_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/water/presentation/providers/water_provider.dart';
import '../theme/app_colors.dart';

class DynamicRoutineTimelineDialog extends ConsumerWidget {
  const DynamicRoutineTimelineDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final waterAsync = ref.watch(waterProvider);
    final mealsAsync = ref.watch(nutritionProvider);

    final profile = profileAsync.valueOrNull;
    final waterLogs = waterAsync.valueOrNull ?? [];
    final meals = mealsAsync.valueOrNull ?? [];

    final wakeTimeStr = profile?.idealWakeTime ?? '06:30';
    final sleepTimeStr = profile?.idealSleepTime ?? '22:00';

    final List<Map<String, dynamic>> timelineEvents = [];

    // 1. Wake up event from profile
    timelineEvents.add({
      'time': _formatTimeString(wakeTimeStr),
      'rawTime': _parseTimeString(wakeTimeStr),
      'title': 'Wake Up Target',
      'subtitle': 'Morning hydration & wellness check',
      'icon': Icons.alarm_rounded,
      'color': AppColors.warning,
    });

    // 2. Real Water Intake logs
    for (final water in waterLogs) {
      final tod = TimeOfDay.fromDateTime(water.loggedAt);
      final noteStr = water.note?.isNotEmpty == true ? '${water.note} • ' : '';
      timelineEvents.add({
        'time': tod.format(context),
        'rawTime': water.loggedAt,
        'title': 'Water Intake',
        'subtitle': '$noteStr${water.amountMl} ml logged',
        'icon': Icons.water_drop_rounded,
        'color': AppColors.water,
      });
    }

    // 3. Real Meal logs
    for (final meal in meals) {
      final tod = TimeOfDay.fromDateTime(meal.loggedAt);
      final itemsSummary = meal.items.map((i) => i.name).join(', ');
      timelineEvents.add({
        'time': tod.format(context),
        'rawTime': meal.loggedAt,
        'title': '${meal.mealType.name.toUpperCase()} — ${meal.title}',
        'subtitle': itemsSummary.isNotEmpty
            ? '$itemsSummary (${meal.totalCalories} kcal)'
            : '${meal.totalCalories} kcal',
        'icon': Icons.restaurant_rounded,
        'color': AppColors.primaryDark,
      });
    }

    // 4. Bedtime Sleep event from profile
    timelineEvents.add({
      'time': _formatTimeString(sleepTimeStr),
      'rawTime': _parseTimeString(sleepTimeStr),
      'title': 'Bedtime Sleep Target',
      'subtitle': 'Rest & Recovery (${(profile?.sleepGoalMinutes ?? 480) ~/ 60} Hours Goal)',
      'icon': Icons.nightlight_round,
      'color': const Color(0xFF6C7B73),
    });

    // Sort all events chronologically by rawTime
    timelineEvents.sort((a, b) {
      final dtA = a['rawTime'] as DateTime;
      final dtB = b['rawTime'] as DateTime;
      return dtA.compareTo(dtB);
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timeline_rounded, color: AppColors.primaryDark, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Routine Timeline',
                        style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        "Actual Today's Logged Activity",
                        style: GoogleFonts.sora(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline ListView
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: timelineEvents.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No activities logged today yet.',
                          style: GoogleFonts.sora(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: timelineEvents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = timelineEvents[index];
                        final Color iconColor = event['color'] as Color;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                event['time'] as String,
                                style: GoogleFonts.sora(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: iconColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Event details
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(event['icon'] as IconData, color: iconColor, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event['title'] as String,
                                            style: GoogleFonts.sora(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            event['subtitle'] as String,
                                            style: GoogleFonts.sora(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static DateTime _parseTimeString(String timeStr) {
    final now = DateTime.now();
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return now;
    }
  }

  static String _formatTimeString(String timeStr) {
    try {
      final dt = _parseTimeString(timeStr);
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minStr = dt.minute.toString().padLeft(2, '0');
      return '${hour.toString().padLeft(2, '0')}:$minStr $period';
    } catch (_) {
      return timeStr;
    }
  }
}

// Retain alias for existing imports
typedef DailyRoutineTimelineDialog = DynamicRoutineTimelineDialog;
