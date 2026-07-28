import '../../domain/entities/workout_session.dart';

class ExerciseSetModel extends ExerciseSet {
  const ExerciseSetModel({
    required super.setNumber,
    required super.reps,
    required super.weightKg,
    super.isCompleted,
  });

  factory ExerciseSetModel.fromJson(Map<String, dynamic> json) {
    return ExerciseSetModel(
      setNumber: json['setNumber'] as int? ?? 1,
      reps: json['reps'] as int? ?? 10,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'reps': reps,
        'weightKg': weightKg,
        'isCompleted': isCompleted,
      };
}

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.targetMuscleGroup,
    required super.sets,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Exercise',
      targetMuscleGroup: json['targetMuscleGroup'] as String? ?? 'Full Body',
      sets: (json['sets'] as List<dynamic>?)
              ?.map((s) => ExerciseSetModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetMuscleGroup': targetMuscleGroup,
        'sets': sets.map((s) => ExerciseSetModel(setNumber: s.setNumber, reps: s.reps, weightKg: s.weightKg, isCompleted: s.isCompleted).toJson()).toList(),
      };
}

class WorkoutSessionModel extends WorkoutSession {
  const WorkoutSessionModel({
    required super.id,
    required super.title,
    required super.targetGoal,
    required super.exercises,
    required super.durationMinutes,
    required super.loggedAt,
  });

  factory WorkoutSessionModel.fromDomain(WorkoutSession session) {
    return WorkoutSessionModel(
      id: session.id,
      title: session.title,
      targetGoal: session.targetGoal,
      exercises: session.exercises,
      durationMinutes: session.durationMinutes,
      loggedAt: session.loggedAt,
    );
  }

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Workout Session',
      targetGoal: json['targetGoal'] as String? ?? 'Hypertrophy',
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      durationMinutes: json['durationMinutes'] as int? ?? 45,
      loggedAt: DateTime.tryParse(json['loggedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetGoal': targetGoal,
        'exercises': exercises.map((e) => ExerciseModel(id: e.id, name: e.name, targetMuscleGroup: e.targetMuscleGroup, sets: e.sets).toJson()).toList(),
        'durationMinutes': durationMinutes,
        'loggedAt': loggedAt.toIso8601String(),
      };
}
