import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/workout_session.dart';
import '../providers/workout_provider.dart';
import 'gps_activity_screen.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutProvider);
    final profileAsync = ref.watch(profileProvider);

    final primaryGoal = profileAsync.valueOrNull?.primaryGoal.name ?? 'Build Muscle';

    return Scaffold(
      backgroundColor: AppColors.mintBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mintBackground,
        title: Text('Workout AI & Logger', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded, color: AppColors.lightTextPrimary),
            tooltip: 'GPS Outdoor Tracker',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GpsActivityScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.lightTextPrimary),
            tooltip: 'Log Workout Session',
            onPressed: () => _showQuickLogWorkoutModal(context, ref, primaryGoal),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickLogWorkoutModal(context, ref, primaryGoal),
        backgroundColor: AppColors.mintPrimary,
        icon: const Icon(Icons.fitness_center, color: AppColors.lightTextPrimary),
        label: Text('Log Workout', style: GoogleFonts.outfit(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold)),
      ),
      body: workoutsAsync.when(
        data: (sessions) => _buildWorkoutContent(context, ref, sessions, primaryGoal),
        loading: () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              LoadingShimmer(height: 140),
              SizedBox(height: 16),
              LoadingShimmer(height: 80),
              SizedBox(height: 16),
              LoadingShimmer(height: 200),
            ],
          ),
        ),
        error: (err, stack) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(workoutProvider),
        ),
      ),
    );
  }

  Widget _buildWorkoutContent(BuildContext context, WidgetRef ref, List<WorkoutSession> sessions, String goal) {
    final totalVolume = sessions.fold(0.0, (sum, s) => sum + s.totalVolumeKg);
    final totalSets = sessions.fold(0, (sum, s) => sum + s.totalSets);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.lightTextPrimary),
                  const SizedBox(width: 8),
                  Text('Adaptive AI Routine Recommendation', style: GoogleFonts.outfit(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Goal: $goal • Suggested Session: Lower Body & Core Hypertrophy (45 mins)',
                style: GoogleFonts.outfit(color: AppColors.lightTextSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCol('Total Volume', '${totalVolume.toStringAsFixed(0)} kg', AppColors.lightTextPrimary),
                  _buildStatCol('Sets Completed', '$totalSets sets', AppColors.lightTextPrimary),
                  _buildStatCol('Sessions', '${sessions.length}', AppColors.lightTextPrimary),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text("Today's Workout Sessions", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.lightTextPrimary)),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          EmptyStateWidget(
            title: 'No Workouts Logged Today',
            message: 'Log your sets, reps, and weights to track your progressive overload volume.',
            actionLabel: 'Log First Session',
            onAction: () => _showQuickLogWorkoutModal(context, ref, goal),
          )
        else
          ...sessions.map((session) => _buildSessionCard(ref, session)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.lightTextSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildSessionCard(WidgetRef ref, WorkoutSession session) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.mintPrimary.withValues(alpha: 0.3),
          child: const Icon(Icons.fitness_center, color: AppColors.lightTextPrimary),
        ),
        title: Text(session.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
        subtitle: Text(
          '${session.durationMinutes} mins • ${session.totalVolumeKg.toStringAsFixed(0)} kg volume • ${session.exercises.length} exercises',
          style: GoogleFonts.outfit(color: AppColors.lightTextSecondary),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () => ref.read(workoutProvider.notifier).deleteWorkout(session.id),
        ),
        children: session.exercises.map((e) => ListTile(
          dense: true,
          title: Text(e.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          subtitle: Text('${e.sets.length} sets • ${e.targetMuscleGroup}', style: GoogleFonts.outfit(color: AppColors.lightTextSecondary)),
          trailing: Text('${e.totalVolumeKg.toStringAsFixed(0)} kg', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
        )).toList(),
      ),
    );
  }

  void _showQuickLogWorkoutModal(BuildContext context, WidgetRef ref, String defaultGoal) {
    final titleController = TextEditingController(text: 'Push Day Hypertrophy');
    final durationController = TextEditingController(text: '45');

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
              Text('Log Workout Session', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.lightTextPrimary)),
              const SizedBox(height: 16),
              TextField(controller: titleController, style: GoogleFonts.outfit(color: AppColors.lightTextPrimary), decoration: const InputDecoration(labelText: 'Session Title')),
              const SizedBox(height: 12),
              TextField(controller: durationController, keyboardType: TextInputType.number, style: GoogleFonts.outfit(color: AppColors.lightTextPrimary), decoration: const InputDecoration(labelText: 'Duration (minutes)')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: AppColors.lightTextPrimary),
                  label: Text('Save Workout Session', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintPrimary),
                  onPressed: () {
                    final duration = int.tryParse(durationController.text) ?? 45;
                    ref.read(workoutProvider.notifier).logWorkoutSession(
                          title: titleController.text,
                          targetGoal: defaultGoal,
                          durationMinutes: duration,
                          exercises: const [
                            Exercise(
                              id: 'ex_temp_1',
                              name: 'Bench Press',
                              targetMuscleGroup: 'Chest',
                              sets: [
                                ExerciseSet(setNumber: 1, reps: 10, weightKg: 60),
                                ExerciseSet(setNumber: 2, reps: 8, weightKg: 70),
                              ],
                            ),
                          ],
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
