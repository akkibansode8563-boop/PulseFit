import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/i_workout_repository.dart';
import '../models/workout_session_model.dart';

class WorkoutRepositoryImpl implements IWorkoutRepository {
  final List<WorkoutSessionModel> _localWorkouts = [
    WorkoutSessionModel(
      id: 'workout_1',
      title: 'Upper Body Hypertrophy',
      targetGoal: 'Build Muscle',
      durationMinutes: 50,
      loggedAt: DateTime.now().subtract(const Duration(hours: 5)),
      exercises: const [
        Exercise(
          id: 'ex_1',
          name: 'Barbell Bench Press',
          targetMuscleGroup: 'Chest',
          sets: [
            ExerciseSet(setNumber: 1, reps: 10, weightKg: 70),
            ExerciseSet(setNumber: 2, reps: 8, weightKg: 75),
            ExerciseSet(setNumber: 3, reps: 6, weightKg: 80),
          ],
        ),
        Exercise(
          id: 'ex_2',
          name: 'Incline Dumbbell Press',
          targetMuscleGroup: 'Upper Chest',
          sets: [
            ExerciseSet(setNumber: 1, reps: 12, weightKg: 24),
            ExerciseSet(setNumber: 2, reps: 10, weightKg: 26),
          ],
        ),
      ],
    ),
  ];

  @override
  Future<Result<List<WorkoutSession>>> getTodayWorkouts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return Result.success(List.unmodifiable(_localWorkouts));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<WorkoutSession>> logWorkout(WorkoutSession session) async {
    try {
      final model = WorkoutSessionModel.fromDomain(session);
      _localWorkouts.insert(0, model);
      await Future.delayed(const Duration(milliseconds: 200));
      return Result.success(model);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteWorkout(String workoutId) async {
    try {
      _localWorkouts.removeWhere((w) => w.id == workoutId);
      await Future.delayed(const Duration(milliseconds: 200));
      return Result.success(null);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }
}
