import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/i_workout_repository.dart';

final workoutRepositoryProvider = Provider<IWorkoutRepository>((ref) {
  return WorkoutRepositoryImpl();
});

class WorkoutNotifier extends AsyncNotifier<List<WorkoutSession>> {
  @override
  FutureOr<List<WorkoutSession>> build() async {
    final repo = ref.watch(workoutRepositoryProvider);
    final result = await repo.getTodayWorkouts();
    return result.fold(
      onSuccess: (workouts) => workouts,
      onError: (failure) => throw Exception(failure.message),
    );
  }

  Future<void> logWorkoutSession({
    required String title,
    required String targetGoal,
    required List<Exercise> exercises,
    required int durationMinutes,
  }) async {
    final newSession = WorkoutSession(
      id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      targetGoal: targetGoal,
      exercises: exercises,
      durationMinutes: durationMinutes,
      loggedAt: DateTime.now(),
    );

    final repo = ref.read(workoutRepositoryProvider);
    state = const AsyncValue.loading();
    final result = await repo.logWorkout(newSession);
    result.fold(
      onSuccess: (_) async {
        final updated = await repo.getTodayWorkouts();
        state = AsyncValue.data(updated.data ?? []);
      },
      onError: (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
    );
  }

  Future<void> deleteWorkout(String workoutId) async {
    final repo = ref.read(workoutRepositoryProvider);
    state = const AsyncValue.loading();
    await repo.deleteWorkout(workoutId);
    final updated = await repo.getTodayWorkouts();
    state = AsyncValue.data(updated.data ?? []);
  }
}

final workoutProvider = AsyncNotifierProvider<WorkoutNotifier, List<WorkoutSession>>(
  WorkoutNotifier.new,
);
