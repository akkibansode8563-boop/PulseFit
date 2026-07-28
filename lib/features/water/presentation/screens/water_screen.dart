import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/daily_routine_timeline_dialog.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/smile_celebration_overlay.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/water_provider.dart';
import '../widgets/water_wave_gauge.dart';

class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  // 1 average sip = 15 ml
  static const int _mlPerSip = 15;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(waterProvider);
    final profileAsync = ref.watch(profileProvider);
    final targetWater = profileAsync.valueOrNull?.dailyWaterGoalMl ?? 3200;

    return Scaffold(
      backgroundColor: AppColors.mintBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mintBackground,
        title: const Text('Hydration Engine',
            style: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: AppColors.lightTextPrimary),
            tooltip: 'Send Water Reminder',
            onPressed: () async {
              await NotificationService().showWaterReminder(sipsDue: 3);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('💧 Water reminder sent to your lockscreen!'), duration: Duration(seconds: 2)),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.timeline_rounded, color: AppColors.lightTextPrimary),
            tooltip: 'Daily Routine Timeline',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const DailyRoutineTimelineDialog(),
            ),
          ),
        ],
      ),
      body: waterAsync.when(
        data: (waterLogs) {
          final totalCurrent = waterLogs.fold(0, (sum, w) => sum + w.amountMl);
          final progress = totalCurrent / targetWater;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Water Wave Gauge
              Center(
                child: WaterWaveGauge(
                  progress: progress,
                  currentMl: totalCurrent,
                  targetMl: targetWater,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 28),

              // --- Sips Section ---
              Text(
                '💧 Sip Tracker',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                '1 Sip = ${_mlPerSip}ml  •  Tap or enter how many sips you took',
                style: GoogleFonts.sora(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // Sip Quick Chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildSipChip(context, ref, sips: 1, label: '+1 Sip', sublabel: '15ml'),
                  _buildSipChip(context, ref, sips: 3, label: '+3 Sips', sublabel: '45ml'),
                  _buildSipChip(context, ref, sips: 5, label: '+5 Sips', sublabel: '75ml'),
                  _buildSipChip(context, ref, sips: 10, label: '+10 Sips', sublabel: '150ml'),
                  // Custom sips input
                  _buildCustomSipsButton(context, ref),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              // --- mL Presets Section ---
              Text(
                '🥤 Quick Glass / Bottle Presets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildAddButton(context, ref, 250, '1 Glass\n250ml')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAddButton(context, ref, 500, 'Bottle\n500ml')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAddButton(context, ref, 750, 'Large\n750ml')),
                ],
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              // --- Timeline ---
              Text(
                'Today\'s Hydration Timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
              ),
              const SizedBox(height: 12),
              if (waterLogs.isEmpty)
                const EmptyStateWidget(
                  title: 'No Water Logged Today',
                  message: 'Tap sip chips or glass presets above to record hydration.',
                )
              else
                ...waterLogs.map((log) => GlassCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.secondary,
                            child: Icon(Icons.water_drop, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.note?.isNotEmpty == true
                                      ? '${log.note} • ${log.amountMl}ml'
                                      : '${log.amountMl} ml Intake',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  TimeOfDay.fromDateTime(log.loggedAt).format(context),
                                  style: GoogleFonts.sora(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                            onPressed: () => ref.read(waterProvider.notifier).deleteWaterLog(log.id),
                          ),
                        ],
                      ),
                    )),
            ],
          );
        },
        loading: () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              LoadingShimmer(height: 200),
              SizedBox(height: 16),
              LoadingShimmer(height: 80),
            ],
          ),
        ),
        error: (err, stack) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(waterProvider),
        ),
      ),
    );
  }

  /// Chip for sip-based logging
  Widget _buildSipChip(BuildContext context, WidgetRef ref,
      {required int sips, required String label, required String sublabel}) {
    final int ml = sips * _mlPerSip;
    return GestureDetector(
      onTap: () {
        ref.read(waterProvider.notifier).addWater(ml, note: '$sips Sip${sips > 1 ? "s" : ""}');
        SmileCelebrationOverlay.show(
          context,
          message: '+$sips Sip${sips > 1 ? "s" : ""} (${ml}ml) Logged! 💧',
          emoji: '💧',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.sora(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.lightTextPrimary)),
            Text(sublabel,
                style: GoogleFonts.sora(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  /// Custom sips dialog input
  Widget _buildCustomSipsButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showCustomSipsDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Custom Sips',
                style: GoogleFonts.sora(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.lightTextPrimary)),
            Text('Enter count',
                style: GoogleFonts.sora(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _showCustomSipsDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('How many sips?', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('1 sip = ${_mlPerSip}ml average',
                style: GoogleFonts.sora(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. 7',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                suffixText: 'sips',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white),
            onPressed: () {
              final sips = int.tryParse(controller.text.trim()) ?? 0;
              if (sips > 0) {
                final ml = sips * _mlPerSip;
                ref.read(waterProvider.notifier).addWater(ml, note: '$sips Sips');
                SmileCelebrationOverlay.show(
                  context,
                  message: '+$sips Sips (${ml}ml) Logged! 💧',
                  emoji: '💧',
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Log Sips'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref, int amount, String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
        ),
      ),
      onPressed: () {
        ref.read(waterProvider.notifier).addWater(amount, note: '1 Glass');
        SmileCelebrationOverlay.show(
          context,
          message: '+${amount}ml Hydration Logged! 😃',
          emoji: '💧',
        );
      },
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
