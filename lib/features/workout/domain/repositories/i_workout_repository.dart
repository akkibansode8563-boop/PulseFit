import '../../../../core/error/result.dart';
import '../entities/workout_session.dart';

abstract class IWorkoutRepository {
  Future<Result<List<WorkoutSession>>> getTodayWorkouts();
  Future<Result<WorkoutSession>> logWorkout(WorkoutSession session);
  Future<Result<void>> deleteWorkout(String workoutId);
}
