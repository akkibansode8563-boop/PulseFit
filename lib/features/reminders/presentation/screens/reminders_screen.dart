import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

final waterIntervalProvider = StateProvider<int>((ref) => 60); // Default 60 mins (1 hr)
final wakeAlarmTimeProvider = StateProvider<TimeOfDay>((ref) => const TimeOfDay(hour: 6, minute: 30));
final wakeAlarmEnabledProvider = StateProvider<bool>((ref) => true);
final waterReminderEnabledProvider = StateProvider<bool>((ref) => true);

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterInterval = ref.watch(waterIntervalProvider);
    final wakeTime = ref.watch(wakeAlarmTimeProvider);
    final isWakeEnabled = ref.watch(wakeAlarmEnabledProvider);
    final isWaterEnabled = ref.watch(waterReminderEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Reminders & Alarms',
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // 1. Wake-Up Alarm Card
          _buildReminderCard(
            title: 'Wake-Up Alarm',
            subtitle: 'Start your morning refreshed & energized',
            icon: Icons.alarm_rounded,
            iconColor: AppColors.warning,
            isEnabled: isWakeEnabled,
            onToggle: (val) => ref.read(wakeAlarmEnabledProvider.notifier).state = val,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: wakeTime,
                    );
                    if (picked != null) {
                      ref.read(wakeAlarmTimeProvider.notifier).state = picked;
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          wakeTime.format(context),
                          style: GoogleFonts.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Change Time',
                              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.primaryDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Water Reminder Interval Card
          _buildReminderCard(
            title: 'Water Hydration Reminder',
            subtitle: 'Custom interval notifications to stay hydrated',
            icon: Icons.water_drop_rounded,
            iconColor: AppColors.water,
            isEnabled: isWaterEnabled,
            onToggle: (val) => ref.read(waterReminderEnabledProvider.notifier).state = val,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                Text(
                  'Select Reminder Interval:',
                  style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildIntervalChip(ref, '30 Mins', 30, waterInterval),
                    const SizedBox(width: 8),
                    _buildIntervalChip(ref, '1 Hour', 60, waterInterval),
                    const SizedBox(width: 8),
                    _buildIntervalChip(ref, '2 Hours', 120, waterInterval),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalChip(WidgetRef ref, String label, int minutes, int currentInterval) {
    final isSelected = currentInterval == minutes;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(waterIntervalProvider.notifier).state = minutes,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text(subtitle, style: GoogleFonts.sora(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeThumbColor: AppColors.primaryDark,
              ),
            ],
          ),
          if (isEnabled) child,
        ],
      ),
    );
  }
}
