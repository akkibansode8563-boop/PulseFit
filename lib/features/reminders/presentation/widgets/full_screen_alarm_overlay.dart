import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../medical/presentation/providers/medical_provider.dart';
import '../../../water/presentation/providers/water_provider.dart';
import '../../domain/entities/reminder_entities.dart';
import '../providers/reminder_provider.dart';

class FullScreenAlarmOverlay extends ConsumerWidget {
  const FullScreenAlarmOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(reminderProvider);
    final activeReminders = remindersAsync.valueOrNull ?? [];

    if (activeReminders.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentAlarm = activeReminders.first;
    HapticFeedback.vibrate();

    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.warning, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                      child: Icon(_getIcon(currentAlarm.type), size: 40, color: AppColors.warning),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 800.ms),
                    const SizedBox(height: 20),
                    Text(
                      currentAlarm.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentAlarm.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          await _handleAction(ref, currentAlarm);
                          await ref.read(reminderProvider.notifier).resolveReminder(currentAlarm.id);
                        },
                        child: Text(
                          currentAlarm.actionLabel,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Icons.water_drop;
      case ReminderType.wakeUp:
        return Icons.alarm;
      case ReminderType.sleep:
        return Icons.bedtime;
      case ReminderType.medicine:
        return Icons.medical_services;
    }
  }

  Future<void> _handleAction(WidgetRef ref, PersistentReminder reminder) async {
    switch (reminder.type) {
      case ReminderType.water:
        await ref.read(waterProvider.notifier).addWater(250);
        break;
      case ReminderType.medicine:
        await ref.read(medicalProvider.notifier).toggleMedicine('med_1');
        break;
      case ReminderType.wakeUp:
      case ReminderType.sleep:
        break;
    }
  }
}
