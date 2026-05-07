import 'package:flutter/foundation.dart';

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  core,
  quadriceps,
  hamstrings,
  glutes,
  calves,
  fullBody,
  cardio;

  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.quadriceps:
        return 'Quadriceps';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.fullBody:
        return 'Full Body';
      case MuscleGroup.cardio:
        return 'Cardio';
    }
  }

  static MuscleGroup fromString(String value) {
    return MuscleGroup.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MuscleGroup.fullBody,
    );
  }
}

enum Equipment {
  noEquipment,
  barbell,
  dumbbell,
  kettlebell,
  resistanceBand,
  pullupBar,
  cables,
  machine,
  trx,
  medicineBall,
  box;

  String get displayName {
    switch (this) {
      case Equipment.noEquipment:
        return 'No Equipment';
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.resistanceBand:
        return 'Resistance Band';
      case Equipment.pullupBar:
        return 'Pull-up Bar';
      case Equipment.cables:
        return 'Cables';
      case Equipment.machine:
        return 'Machine';
      case Equipment.trx:
        return 'TRX';
      case Equipment.medicineBall:
        return 'Medicine Ball';
      case Equipment.box:
        return 'Box / Plyo Box';
    }
  }

  static Equipment fromString(String value) {
    return Equipment.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Equipment.noEquipment,
    );
  }
}

enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return 'Beginner';
      case ExerciseDifficulty.intermediate:
        return 'Intermediate';
      case ExerciseDifficulty.advanced:
        return 'Advanced';
    }
  }

  static ExerciseDifficulty fromString(String value) {
    return ExerciseDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExerciseDifficulty.intermediate,
    );
  }
}

enum ExerciseType {
  strength,
  cardio,
  flexibility,
  plyometric,
  calisthenics;

  String get displayName {
    switch (this) {
      case ExerciseType.strength:
        return 'Strength';
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.flexibility:
        return 'Flexibility';
      case ExerciseType.plyometric:
        return 'Plyometric';
      case ExerciseType.calisthenics:
        return 'Calisthenics';
    }
  }

  static ExerciseType fromString(String value) {
    return ExerciseType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExerciseType.strength,
    );
  }
}

@immutable
class ExerciseModel {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final Equipment equipment;
  final ExerciseDifficulty difficulty;

  /// Step-by-step instructions for performing the exercise.
  final String instructions;

  /// Pro tips and common cues.
  final List<String> tips;

  final ExerciseType type;

  /// Approximate calories burned per minute at moderate intensity.
  final double caloriesPerMinute;

  final String? demoImageUrl;

  /// True when no equipment is needed (bodyweight exercise).
  final bool isBodyweight;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    this.difficulty = ExerciseDifficulty.intermediate,
    required this.instructions,
    this.tips = const [],
    required this.type,
    this.caloriesPerMinute = 5.0,
    this.demoImageUrl,
    this.isBodyweight = false,
  });

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryMuscle': primaryMuscle.name,
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
      'equipment': equipment.name,
      'difficulty': difficulty.name,
      'instructions': instructions,
      'tips': tips,
      'type': type.name,
      'caloriesPerMinute': caloriesPerMinute,
      'demoImageUrl': demoImageUrl,
      'isBodyweight': isBodyweight,
    };
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscle:
          MuscleGroup.fromString(json['primaryMuscle'] as String? ?? 'fullBody'),
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => MuscleGroup.fromString(e as String))
              .toList() ??
          [],
      equipment:
          Equipment.fromString(json['equipment'] as String? ?? 'noEquipment'),
      difficulty: ExerciseDifficulty.fromString(
          json['difficulty'] as String? ?? 'intermediate'),
      instructions: json['instructions'] as String? ?? '',
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      type: ExerciseType.fromString(json['type'] as String? ?? 'strength'),
      caloriesPerMinute:
          (json['caloriesPerMinute'] as num?)?.toDouble() ?? 5.0,
      demoImageUrl: json['demoImageUrl'] as String?,
      isBodyweight: json['isBodyweight'] as bool? ?? false,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  ExerciseModel copyWith({
    String? id,
    String? name,
    MuscleGroup? primaryMuscle,
    List<MuscleGroup>? secondaryMuscles,
    Equipment? equipment,
    ExerciseDifficulty? difficulty,
    String? instructions,
    List<String>? tips,
    ExerciseType? type,
    double? caloriesPerMinute,
    String? demoImageUrl,
    bool? isBodyweight,
    bool clearDemoImageUrl = false,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      type: type ?? this.type,
      caloriesPerMinute: caloriesPerMinute ?? this.caloriesPerMinute,
      demoImageUrl:
          clearDemoImageUrl ? null : (demoImageUrl ?? this.demoImageUrl),
      isBodyweight: isBodyweight ?? this.isBodyweight,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ExerciseModel(id: $id, name: $name, primaryMuscle: ${primaryMuscle.name})';
}
