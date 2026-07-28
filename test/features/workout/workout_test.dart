import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/features/workout/domain/entities/workout_session.dart';
import 'package:ai_health_manager/features/workout/data/repositories/workout_repository_impl.dart';

void main() {
  group('Workout Feature Tests', () {
    final repo = WorkoutRepositoryImpl();

    test('progressive overload totalVolumeKg computes volume correctly', () {
      const exercise = Exercise(
        id: 'ex_1',
        name: 'Bench Press',
        targetMuscleGroup: 'Chest',
        sets: [
          ExerciseSet(setNumber: 1, reps: 10, weightKg: 80), // 800 kg
          ExerciseSet(setNumber: 2, reps: 8, weightKg: 85),  // 680 kg
        ],
      );

      expect(exercise.totalVolumeKg, equals(1480.0));
    });

    test('getTodayWorkouts returns initial cached workout session', () async {
      final result = await repo.getTodayWorkouts();
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.first.title, contains('Upper Body'));
    });

    test('logWorkout adds new workout session successfully', () async {
      final initialResult = await repo.getTodayWorkouts();
      final initialCount = initialResult.data?.length ?? 0;

      final newSession = WorkoutSession(
        id: 'test_workout_99',
        title: 'Leg Day Blast',
        targetGoal: 'Build Muscle',
        durationMinutes: 60,
        loggedAt: DateTime.now(),
        exercises: const [
          Exercise(
            id: 'ex_leg_1',
            name: 'Squat',
            targetMuscleGroup: 'Quads',
            sets: [ExerciseSet(setNumber: 1, reps: 10, weightKg: 100)],
          ),
        ],
      );

      final logResult = await repo.logWorkout(newSession);
      expect(logResult.isSuccess, isTrue);

      final updatedResult = await repo.getTodayWorkouts();
      expect(updatedResult.data?.length, equals(initialCount + 1));
    });
  });
}
