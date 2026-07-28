import 'package:flutter/foundation.dart';

@immutable
class ExerciseSet {
  final int setNumber;
  final int reps;
  final double weightKg;
  final bool isCompleted;

  const ExerciseSet({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.isCompleted = true,
  });

  double get volumeKg => reps * weightKg;

  ExerciseSet copyWith({
    int? setNumber,
    int? reps,
    double? weightKg,
    bool? isCompleted,
  }) {
    return ExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@immutable
class Exercise {
  final String id;
  final String name;
  final String targetMuscleGroup;
  final List<ExerciseSet> sets;

  const Exercise({
    required this.id,
    required this.name,
    required this.targetMuscleGroup,
    required this.sets,
  });

  double get totalVolumeKg => sets.fold(0.0, (sum, s) => sum + s.volumeKg);
}

@immutable
class WorkoutSession {
  final String id;
  final String title;
  final String targetGoal;
  final List<Exercise> exercises;
  final int durationMinutes;
  final DateTime loggedAt;

  const WorkoutSession({
    required this.id,
    required this.title,
    required this.targetGoal,
    required this.exercises,
    required this.durationMinutes,
    required this.loggedAt,
  });

  double get totalVolumeKg => exercises.fold(0.0, (sum, e) => sum + e.totalVolumeKg);
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);
}
