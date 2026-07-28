import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../providers/gps_activity_provider.dart';

class GpsActivityScreen extends ConsumerStatefulWidget {
  const GpsActivityScreen({super.key});

  @override
  ConsumerState<GpsActivityScreen> createState() => _GpsActivityScreenState();
}

class _GpsActivityScreenState extends ConsumerState<GpsActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gpsActivityProvider.notifier).requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activity = ref.watch(gpsActivityProvider);
    final notifier = ref.read(gpsActivityProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'GPS Activity Tracker',
          style: GoogleFonts.sora(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Permission warning
            if (activity.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_rounded, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        activity.error!,
                        style: GoogleFonts.sora(fontSize: 13, color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            // Activity Type Selector
            if (!activity.isTracking) ...[
              Text(
                'Select Activity',
                style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              Row(
                children: ActivityType.values.map((type) {
                  final selected = activity.activityType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => notifier.selectActivity(type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected ? AppColors.primaryDark : AppColors.border,
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: selected ? [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
                        ),
                        child: Column(
                          children: [
                            Text(type.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 6),
                            Text(
                              type.label,
                              style: GoogleFonts.sora(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: selected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            // Live Dashboard - Big Metrics
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, const Color(0xFF5B9A54)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  // Activity Label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(activity.activityType.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        activity.activityType.label,
                        style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (activity.isTracking && !activity.isPaused) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Elapsed Timer (Big)
                  Text(
                    notifier.formattedElapsed,
                    style: GoogleFonts.sora(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                  ),
                  Text(
                    activity.isPaused ? 'PAUSED' : (activity.isTracking ? 'LIVE' : 'Ready'),
                    style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 3),
                  ),
                  const SizedBox(height: 28),

                  // 3 Key Metrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _metricCard(
                        label: 'Distance',
                        value: '${activity.distanceKm}',
                        unit: 'km',
                        icon: Icons.route_rounded,
                      ),
                      _divider(),
                      _metricCard(
                        label: 'Speed',
                        value: '${activity.speedKmh}',
                        unit: 'km/h',
                        icon: Icons.speed_rounded,
                      ),
                      _divider(),
                      _metricCard(
                        label: 'Calories',
                        value: '${activity.caloriesBurned.toStringAsFixed(0)}',
                        unit: 'kcal',
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pace
                  Text(
                    'Pace: ${notifier.formattedPace}',
                    style: GoogleFonts.sora(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Controls
            if (!activity.isTracking)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text(
                    'Start ${activity.activityType.label}',
                    style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: AppColors.primaryDark.withValues(alpha: 0.4),
                  ),
                  onPressed: notifier.startTracking,
                ),
              ),

            if (activity.isTracking) ...[
              Row(
                children: [
                  // Pause / Resume
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(activity.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 24),
                      label: Text(
                        activity.isPaused ? 'Resume' : 'Pause',
                        style: GoogleFonts.sora(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.primaryDark)),
                      ),
                      onPressed: activity.isPaused ? notifier.resumeTracking : notifier.pauseTracking,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Finish
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.stop_circle_rounded, size: 24),
                      label: Text('Finish', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        final capturedContext = context;
                        await notifier.finishTracking();
                        // Send completion lockscreen notification
                        await NotificationService().showActivityCompleted(
                          activityType: activity.activityType.label,
                          distance: activity.distanceKm.toString(),
                          duration: notifier.formattedElapsed,
                          calories: activity.caloriesBurned.toStringAsFixed(0),
                        );
                        if (mounted) _showSummaryDialog(capturedContext, activity, notifier);
                      },
                    ),
                  ),
                ],
              ),
            ],

            // Reset after done
            if (!activity.isTracking && activity.distanceKm > 0) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text('New Activity', style: GoogleFonts.sora()),
                onPressed: notifier.resetActivity,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metricCard({required String label, required String value, required String unit, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(unit, style: GoogleFonts.sora(fontSize: 11, color: Colors.white60)),
        Text(label, style: GoogleFonts.sora(fontSize: 11, color: Colors.white54)),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 50, width: 1, color: Colors.white24);
  }

  void _showSummaryDialog(BuildContext context, GpsActivityState activity, GpsActivityNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('${activity.activityType.emoji} Activity Complete!', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('Distance', '${activity.distanceKm} km'),
            _summaryRow('Duration', notifier.formattedElapsed),
            _summaryRow('Calories Burned', '${activity.caloriesBurned.toStringAsFixed(0)} kcal'),
            _summaryRow('Pace', notifier.formattedPace),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white),
            onPressed: () {
              notifier.resetActivity();
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.sora(color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.sora(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
