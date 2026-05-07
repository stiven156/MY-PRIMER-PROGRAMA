import 'package:flutter/foundation.dart';
import 'package:gym_app/core/models/exercise_model.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum WorkoutGoal {
  strength,
  weightLoss,
  endurance,
  muscleMass,
  generalFitness,
  sportsPerformance;

  String get displayName {
    switch (this) {
      case WorkoutGoal.strength:
        return 'Strength';
      case WorkoutGoal.weightLoss:
        return 'Weight Loss';
      case WorkoutGoal.endurance:
        return 'Endurance';
      case WorkoutGoal.muscleMass:
        return 'Muscle Mass';
      case WorkoutGoal.generalFitness:
        return 'General Fitness';
      case WorkoutGoal.sportsPerformance:
        return 'Sports Performance';
    }
  }

  static WorkoutGoal fromString(String value) {
    return WorkoutGoal.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WorkoutGoal.generalFitness,
    );
  }
}

enum WorkoutDifficulty {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case WorkoutDifficulty.beginner:
        return 'Beginner';
      case WorkoutDifficulty.intermediate:
        return 'Intermediate';
      case WorkoutDifficulty.advanced:
        return 'Advanced';
    }
  }

  static WorkoutDifficulty fromString(String value) {
    return WorkoutDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WorkoutDifficulty.intermediate,
    );
  }
}

// ---------------------------------------------------------------------------
// ExerciseSet
// ---------------------------------------------------------------------------

@immutable
class ExerciseSet {
  final int setNumber;
  final int? targetReps;
  final double? targetWeight;

  /// Target duration in seconds (used for timed exercises).
  final int? targetDuration;

  final int? actualReps;
  final double? actualWeight;
  final bool completed;

  /// Rate of perceived exertion, 1–10.
  final int? rpe;

  const ExerciseSet({
    required this.setNumber,
    this.targetReps,
    this.targetWeight,
    this.targetDuration,
    this.actualReps,
    this.actualWeight,
    this.completed = false,
    this.rpe,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'targetReps': targetReps,
      'targetWeight': targetWeight,
      'targetDuration': targetDuration,
      'actualReps': actualReps,
      'actualWeight': actualWeight,
      'completed': completed,
      'rpe': rpe,
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      setNumber: (json['setNumber'] as num).toInt(),
      targetReps: (json['targetReps'] as num?)?.toInt(),
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      targetDuration: (json['targetDuration'] as num?)?.toInt(),
      actualReps: (json['actualReps'] as num?)?.toInt(),
      actualWeight: (json['actualWeight'] as num?)?.toDouble(),
      completed: json['completed'] as bool? ?? false,
      rpe: (json['rpe'] as num?)?.toInt(),
    );
  }

  ExerciseSet copyWith({
    int? setNumber,
    int? targetReps,
    double? targetWeight,
    int? targetDuration,
    int? actualReps,
    double? actualWeight,
    bool? completed,
    int? rpe,
    bool clearTargetReps = false,
    bool clearTargetWeight = false,
    bool clearTargetDuration = false,
    bool clearActualReps = false,
    bool clearActualWeight = false,
    bool clearRpe = false,
  }) {
    return ExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      targetReps: clearTargetReps ? null : (targetReps ?? this.targetReps),
      targetWeight:
          clearTargetWeight ? null : (targetWeight ?? this.targetWeight),
      targetDuration:
          clearTargetDuration ? null : (targetDuration ?? this.targetDuration),
      actualReps: clearActualReps ? null : (actualReps ?? this.actualReps),
      actualWeight:
          clearActualWeight ? null : (actualWeight ?? this.actualWeight),
      completed: completed ?? this.completed,
      rpe: clearRpe ? null : (rpe ?? this.rpe),
    );
  }
}

// ---------------------------------------------------------------------------
// WorkoutExercise
// ---------------------------------------------------------------------------

@immutable
class WorkoutExercise {
  final ExerciseModel exercise;
  final List<ExerciseSet> sets;

  /// Rest period between sets in seconds.
  final int restSeconds;

  final String? notes;

  /// ID of another [WorkoutExercise]'s exercise to superset with.
  final String? supersetWith;

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
    this.restSeconds = 60,
    this.notes,
    this.supersetWith,
  });

  bool get isCompleted =>
      sets.isNotEmpty && sets.every((s) => s.completed);

  double get totalVolume {
    return sets.fold(0.0, (sum, s) {
      final reps = (s.actualReps ?? s.targetReps ?? 0).toDouble();
      final weight = s.actualWeight ?? s.targetWeight ?? 0.0;
      return sum + (reps * weight);
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets.map((s) => s.toJson()).toList(),
      'restSeconds': restSeconds,
      'notes': notes,
      'supersetWith': supersetWith,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exercise:
          ExerciseModel.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: (json['sets'] as List<dynamic>)
          .map((s) => ExerciseSet.fromJson(s as Map<String, dynamic>))
          .toList(),
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 60,
      notes: json['notes'] as String?,
      supersetWith: json['supersetWith'] as String?,
    );
  }

  WorkoutExercise copyWith({
    ExerciseModel? exercise,
    List<ExerciseSet>? sets,
    int? restSeconds,
    String? notes,
    String? supersetWith,
    bool clearNotes = false,
    bool clearSupersetWith = false,
  }) {
    return WorkoutExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: clearNotes ? null : (notes ?? this.notes),
      supersetWith:
          clearSupersetWith ? null : (supersetWith ?? this.supersetWith),
    );
  }
}

// ---------------------------------------------------------------------------
// WorkoutDay
// ---------------------------------------------------------------------------

@immutable
class WorkoutDay {
  final String id;
  final String name;
  final List<WorkoutExercise> exercises;
  final bool isRestDay;
  final String? notes;

  const WorkoutDay({
    required this.id,
    required this.name,
    this.exercises = const [],
    this.isRestDay = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'isRestDay': isRestDay,
      'notes': notes,
    };
  }

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      id: json['id'] as String,
      name: json['name'] as String,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isRestDay: json['isRestDay'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  WorkoutDay copyWith({
    String? id,
    String? name,
    List<WorkoutExercise>? exercises,
    bool? isRestDay,
    String? notes,
    bool clearNotes = false,
  }) {
    return WorkoutDay(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      isRestDay: isRestDay ?? this.isRestDay,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }
}

// ---------------------------------------------------------------------------
// WorkoutPlan
// ---------------------------------------------------------------------------

@immutable
class WorkoutPlan {
  final String id;
  final String gymId;
  final String createdBy;
  final String name;
  final String description;
  final List<WorkoutDay> days;
  final int durationWeeks;
  final WorkoutDifficulty difficulty;
  final WorkoutGoal goal;
  final bool isTemplate;
  final DateTime createdAt;
  final int estimatedCalories;
  final List<String> tags;

  const WorkoutPlan({
    required this.id,
    required this.gymId,
    required this.createdBy,
    required this.name,
    this.description = '',
    this.days = const [],
    this.durationWeeks = 4,
    this.difficulty = WorkoutDifficulty.intermediate,
    this.goal = WorkoutGoal.generalFitness,
    this.isTemplate = false,
    required this.createdAt,
    this.estimatedCalories = 0,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gymId': gymId,
      'createdBy': createdBy,
      'name': name,
      'description': description,
      'days': days.map((d) => d.toJson()).toList(),
      'durationWeeks': durationWeeks,
      'difficulty': difficulty.name,
      'goal': goal.name,
      'isTemplate': isTemplate,
      'createdAt': createdAt.toIso8601String(),
      'estimatedCalories': estimatedCalories,
      'tags': tags,
    };
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      createdBy: json['createdBy'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      days: (json['days'] as List<dynamic>?)
              ?.map((d) => WorkoutDay.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      durationWeeks: (json['durationWeeks'] as num?)?.toInt() ?? 4,
      difficulty: WorkoutDifficulty.fromString(
          json['difficulty'] as String? ?? 'intermediate'),
      goal: WorkoutGoal.fromString(json['goal'] as String? ?? 'generalFitness'),
      isTemplate: json['isTemplate'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      estimatedCalories: (json['estimatedCalories'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ??
          [],
    );
  }

  WorkoutPlan copyWith({
    String? id,
    String? gymId,
    String? createdBy,
    String? name,
    String? description,
    List<WorkoutDay>? days,
    int? durationWeeks,
    WorkoutDifficulty? difficulty,
    WorkoutGoal? goal,
    bool? isTemplate,
    DateTime? createdAt,
    int? estimatedCalories,
    List<String>? tags,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      description: description ?? this.description,
      days: days ?? this.days,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      difficulty: difficulty ?? this.difficulty,
      goal: goal ?? this.goal,
      isTemplate: isTemplate ?? this.isTemplate,
      createdAt: createdAt ?? this.createdAt,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutPlan &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WorkoutPlan(id: $id, name: $name)';
}

// ---------------------------------------------------------------------------
// WorkoutSession
// ---------------------------------------------------------------------------

@immutable
class WorkoutSession {
  final String id;
  final String memberId;
  final String? workoutPlanId;
  final String? workoutDayId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<WorkoutExercise> exercises;
  final double totalVolume;
  final int caloriesBurned;
  final String? notes;
  final bool completed;
  final String gymId;

  const WorkoutSession({
    required this.id,
    required this.memberId,
    this.workoutPlanId,
    this.workoutDayId,
    required this.startTime,
    this.endTime,
    this.exercises = const [],
    this.totalVolume = 0.0,
    this.caloriesBurned = 0,
    this.notes,
    this.completed = false,
    required this.gymId,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  double get computedTotalVolume =>
      exercises.fold(0.0, (sum, e) => sum + e.totalVolume);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'workoutPlanId': workoutPlanId,
      'workoutDayId': workoutDayId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'totalVolume': totalVolume,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'completed': completed,
      'gymId': gymId,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      workoutPlanId: json['workoutPlanId'] as String?,
      workoutDayId: json['workoutDayId'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0.0,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      completed: json['completed'] as bool? ?? false,
      gymId: json['gymId'] as String,
    );
  }

  WorkoutSession copyWith({
    String? id,
    String? memberId,
    String? workoutPlanId,
    String? workoutDayId,
    DateTime? startTime,
    DateTime? endTime,
    List<WorkoutExercise>? exercises,
    double? totalVolume,
    int? caloriesBurned,
    String? notes,
    bool? completed,
    String? gymId,
    bool clearWorkoutPlanId = false,
    bool clearWorkoutDayId = false,
    bool clearEndTime = false,
    bool clearNotes = false,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      workoutPlanId:
          clearWorkoutPlanId ? null : (workoutPlanId ?? this.workoutPlanId),
      workoutDayId:
          clearWorkoutDayId ? null : (workoutDayId ?? this.workoutDayId),
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      exercises: exercises ?? this.exercises,
      totalVolume: totalVolume ?? this.totalVolume,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: clearNotes ? null : (notes ?? this.notes),
      completed: completed ?? this.completed,
      gymId: gymId ?? this.gymId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// PersonalRecord
// ---------------------------------------------------------------------------

@immutable
class PersonalRecord {
  final String id;
  final String memberId;
  final String exerciseId;
  final String exerciseName;
  final double? weight;
  final int? reps;
  final DateTime date;
  final String gymId;

  const PersonalRecord({
    required this.id,
    required this.memberId,
    required this.exerciseId,
    required this.exerciseName,
    this.weight,
    this.reps,
    required this.date,
    required this.gymId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'weight': weight,
      'reps': reps,
      'date': date.toIso8601String(),
      'gymId': gymId,
    };
  }

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      weight: (json['weight'] as num?)?.toDouble(),
      reps: (json['reps'] as num?)?.toInt(),
      date: DateTime.parse(json['date'] as String),
      gymId: json['gymId'] as String,
    );
  }

  PersonalRecord copyWith({
    String? id,
    String? memberId,
    String? exerciseId,
    String? exerciseName,
    double? weight,
    int? reps,
    DateTime? date,
    String? gymId,
    bool clearWeight = false,
    bool clearReps = false,
  }) {
    return PersonalRecord(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: clearWeight ? null : (weight ?? this.weight),
      reps: clearReps ? null : (reps ?? this.reps),
      date: date ?? this.date,
      gymId: gymId ?? this.gymId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PersonalRecord(exerciseName: $exerciseName, weight: $weight, reps: $reps)';
}
