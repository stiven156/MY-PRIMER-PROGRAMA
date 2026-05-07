import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum ClassCategory {
  yoga,
  spinning,
  zumba,
  crossfit,
  boxing,
  pilates,
  hiit,
  aerobics,
  bodyPump,
  calisthenics,
  dance,
  stretching,
  kickboxing,
  trx,
  swimming;

  String get displayName {
    switch (this) {
      case ClassCategory.yoga:
        return 'Yoga';
      case ClassCategory.spinning:
        return 'Spinning';
      case ClassCategory.zumba:
        return 'Zumba';
      case ClassCategory.crossfit:
        return 'CrossFit';
      case ClassCategory.boxing:
        return 'Boxing';
      case ClassCategory.pilates:
        return 'Pilates';
      case ClassCategory.hiit:
        return 'HIIT';
      case ClassCategory.aerobics:
        return 'Aerobics';
      case ClassCategory.bodyPump:
        return 'Body Pump';
      case ClassCategory.calisthenics:
        return 'Calisthenics';
      case ClassCategory.dance:
        return 'Dance';
      case ClassCategory.stretching:
        return 'Stretching';
      case ClassCategory.kickboxing:
        return 'Kickboxing';
      case ClassCategory.trx:
        return 'TRX';
      case ClassCategory.swimming:
        return 'Swimming';
    }
  }

  static ClassCategory fromString(String value) {
    return ClassCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ClassCategory.hiit,
    );
  }
}

enum ClassStatus {
  scheduled,
  cancelled,
  completed,
  inProgress;

  String get displayName {
    switch (this) {
      case ClassStatus.scheduled:
        return 'Scheduled';
      case ClassStatus.cancelled:
        return 'Cancelled';
      case ClassStatus.completed:
        return 'Completed';
      case ClassStatus.inProgress:
        return 'In Progress';
    }
  }

  static ClassStatus fromString(String value) {
    return ClassStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ClassStatus.scheduled,
    );
  }
}

enum ClassDifficulty {
  beginner,
  intermediate,
  advanced,
  allLevels;

  String get displayName {
    switch (this) {
      case ClassDifficulty.beginner:
        return 'Beginner';
      case ClassDifficulty.intermediate:
        return 'Intermediate';
      case ClassDifficulty.advanced:
        return 'Advanced';
      case ClassDifficulty.allLevels:
        return 'All Levels';
    }
  }

  static ClassDifficulty fromString(String value) {
    return ClassDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ClassDifficulty.allLevels,
    );
  }
}

// ---------------------------------------------------------------------------
// GymClass
// ---------------------------------------------------------------------------

@immutable
class GymClass {
  final String id;
  final String gymId;
  final String name;
  final String description;
  final String instructorId;
  final String instructorName;
  final int maxCapacity;

  /// List of member IDs enrolled in this class.
  final List<String> enrolledMemberIds;

  final DateTime startTime;
  final DateTime endTime;

  /// Brand colour for the class card as a hex string, e.g. "#FF6B35".
  final String color;

  final ClassCategory category;
  final bool isRecurring;

  /// Days of week when the class recurs: 1 = Monday … 7 = Sunday.
  final List<int>? recurringDays;

  final ClassStatus status;

  /// Room or area name within the gym, e.g. "Studio A".
  final String location;

  final int? calorieBurn;
  final ClassDifficulty difficulty;
  final String? imageUrl;

  /// Additional price per session. 0 means included in membership.
  final double price;

  const GymClass({
    required this.id,
    required this.gymId,
    required this.name,
    this.description = '',
    required this.instructorId,
    required this.instructorName,
    required this.maxCapacity,
    this.enrolledMemberIds = const [],
    required this.startTime,
    required this.endTime,
    this.color = '#FF6B35',
    required this.category,
    this.isRecurring = false,
    this.recurringDays,
    this.status = ClassStatus.scheduled,
    required this.location,
    this.calorieBurn,
    this.difficulty = ClassDifficulty.allLevels,
    this.imageUrl,
    this.price = 0.0,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  int get availableSpots => maxCapacity - enrolledMemberIds.length;

  bool get isFull => enrolledMemberIds.length >= maxCapacity;

  int get durationMinutes => endTime.difference(startTime).inMinutes;

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gymId': gymId,
      'name': name,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'maxCapacity': maxCapacity,
      'enrolledMemberIds': enrolledMemberIds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color,
      'category': category.name,
      'isRecurring': isRecurring,
      'recurringDays': recurringDays,
      'status': status.name,
      'location': location,
      'calorieBurn': calorieBurn,
      'difficulty': difficulty.name,
      'imageUrl': imageUrl,
      'price': price,
    };
  }

  factory GymClass.fromJson(Map<String, dynamic> json) {
    return GymClass(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      instructorId: json['instructorId'] as String,
      instructorName: json['instructorName'] as String,
      maxCapacity: (json['maxCapacity'] as num).toInt(),
      enrolledMemberIds: (json['enrolledMemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      color: json['color'] as String? ?? '#FF6B35',
      category: ClassCategory.fromString(
          json['category'] as String? ?? 'hiit'),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringDays: (json['recurringDays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      status:
          ClassStatus.fromString(json['status'] as String? ?? 'scheduled'),
      location: json['location'] as String? ?? '',
      calorieBurn: (json['calorieBurn'] as num?)?.toInt(),
      difficulty: ClassDifficulty.fromString(
          json['difficulty'] as String? ?? 'allLevels'),
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  GymClass copyWith({
    String? id,
    String? gymId,
    String? name,
    String? description,
    String? instructorId,
    String? instructorName,
    int? maxCapacity,
    List<String>? enrolledMemberIds,
    DateTime? startTime,
    DateTime? endTime,
    String? color,
    ClassCategory? category,
    bool? isRecurring,
    List<int>? recurringDays,
    ClassStatus? status,
    String? location,
    int? calorieBurn,
    ClassDifficulty? difficulty,
    String? imageUrl,
    double? price,
    bool clearRecurringDays = false,
    bool clearCalorieBurn = false,
    bool clearImageUrl = false,
  }) {
    return GymClass(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      enrolledMemberIds: enrolledMemberIds ?? this.enrolledMemberIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays:
          clearRecurringDays ? null : (recurringDays ?? this.recurringDays),
      status: status ?? this.status,
      location: location ?? this.location,
      calorieBurn:
          clearCalorieBurn ? null : (calorieBurn ?? this.calorieBurn),
      difficulty: difficulty ?? this.difficulty,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      price: price ?? this.price,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymClass && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GymClass(id: $id, name: $name, category: ${category.name}, '
      'status: ${status.name})';
}
