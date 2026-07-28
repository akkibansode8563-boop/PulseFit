import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/sleep_record.dart';
import '../providers/sleep_provider.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepAsync = ref.watch(sleepProvider);
    final profileAsync = ref.watch(profileProvider);

    final targetMinutes = profileAsync.valueOrNull?.sleepGoalMinutes ?? 480;

    return Scaffold(
      backgroundColor: AppColors.mintBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mintBackground,
        title: Text('Sleep AI & Recovery Tracker', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bedtime_outlined, color: AppColors.lightTextPrimary),
            tooltip: 'Log Sleep Session',
            onPressed: () => _showLogSleepModal(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogSleepModal(context, ref),
        backgroundColor: AppColors.mintPrimary,
        icon: const Icon(Icons.bedtime, color: AppColors.lightTextPrimary),
        label: Text('Log Sleep', style: GoogleFonts.outfit(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold)),
      ),
      body: sleepAsync.when(
        data: (record) => record == null
            ? EmptyStateWidget(
                title: 'No Sleep Record Today',
                message: 'Track your sleep duration and stage breakdown to view your AI Recovery Score.',
                actionLabel: 'Log Sleep Session',
                onAction: () => _showLogSleepModal(context, ref),
              )
            : _buildSleepContent(context, record, targetMinutes),
        loading: () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              LoadingShimmer(height: 180),
              SizedBox(height: 16),
              LoadingShimmer(height: 100),
              SizedBox(height: 16),
              LoadingShimmer(height: 150),
            ],
          ),
        ),
        error: (err, stack) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(sleepProvider),
        ),
      ),
    );
  }

  Widget _buildSleepContent(BuildContext context, SleepRecord record, int targetMinutes) {
    final hrs = record.durationMinutes ~/ 60;
    final mins = record.durationMinutes % 60;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xFFC7F09D),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildGauge('Sleep Score', '${record.sleepQualityScore}', Colors.indigo.shade800),
                  _buildGauge('Recovery Index', '${record.recoveryScore}%', AppColors.lightTextPrimary),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Duration: ${hrs}h ${mins}m (Target: ${targetMinutes ~/ 60}h)',
                style: GoogleFonts.outfit(color: AppColors.lightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Sleep Stage Breakdown', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.lightTextPrimary)),
        const SizedBox(height: 12),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStageRow(context, 'Deep Sleep', '${record.deepSleepPercentage}%', Colors.indigo.shade800),
                const Divider(),
                _buildStageRow(context, 'REM Sleep', '${record.remSleepPercentage}%', Colors.deepOrange.shade800),
                const Divider(),
                _buildStageRow(context, 'Light Sleep', '${record.lightSleepPercentage}%', Colors.teal.shade800),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFEDCB6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.alarm_on, color: AppColors.lightTextPrimary, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart Alarm Recommendation', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.lightTextPrimary)),
                    const SizedBox(height: 4),
                    Text('Optimal wakeup window: 07:15 AM (at the end of light sleep cycle).', style: GoogleFonts.outfit(color: AppColors.lightTextSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGauge(String label, String value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white,
          child: Text(value, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(color: AppColors.lightTextSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStageRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 6, backgroundColor: color),
              const SizedBox(width: 10),
              Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
            ],
          ),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showLogSleepModal(BuildContext context, WidgetRef ref) {
    final hrsController = TextEditingController(text: '8');
    final deepController = TextEditingController(text: '25');
    final remController = TextEditingController(text: '20');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Sleep Session', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.lightTextPrimary)),
              const SizedBox(height: 16),
              TextField(controller: hrsController, keyboardType: TextInputType.number, style: GoogleFonts.outfit(color: AppColors.lightTextPrimary), decoration: const InputDecoration(labelText: 'Duration (hours)')),
              const SizedBox(height: 12),
              TextField(controller: deepController, keyboardType: TextInputType.number, style: GoogleFonts.outfit(color: AppColors.lightTextPrimary), decoration: const InputDecoration(labelText: 'Deep Sleep %')),
              const SizedBox(height: 12),
              TextField(controller: remController, keyboardType: TextInputType.number, style: GoogleFonts.outfit(color: AppColors.lightTextPrimary), decoration: const InputDecoration(labelText: 'REM Sleep %')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bedtime, color: AppColors.lightTextPrimary),
                  label: Text('Save Sleep Log', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintPrimary),
                  onPressed: () {
                    final hrs = double.tryParse(hrsController.text) ?? 8.0;
                    final deep = int.tryParse(deepController.text) ?? 25;
                    final rem = int.tryParse(remController.text) ?? 20;

                    ref.read(sleepProvider.notifier).logSleep(
                          durationMinutes: (hrs * 60).round(),
                          deepSleepPct: deep,
                          remSleepPct: rem,
                        );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
