import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum ChallengeType {
  mostCheckIns,
  mostWeightLifted,
  mostWorkouts,
  mostCaloriesBurned,
  mostClasses,
  custom;

  String get displayName {
    switch (this) {
      case ChallengeType.mostCheckIns:
        return 'Most Check-Ins';
      case ChallengeType.mostWeightLifted:
        return 'Most Weight Lifted';
      case ChallengeType.mostWorkouts:
        return 'Most Workouts';
      case ChallengeType.mostCaloriesBurned:
        return 'Most Calories Burned';
      case ChallengeType.mostClasses:
        return 'Most Classes Attended';
      case ChallengeType.custom:
        return 'Custom';
    }
  }

  static ChallengeType fromString(String value) {
    return ChallengeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChallengeType.custom,
    );
  }
}

// ---------------------------------------------------------------------------
// ChallengeParticipant
// ---------------------------------------------------------------------------

@immutable
class ChallengeParticipant {
  final String memberId;
  final String memberName;
  final String? memberPhotoUrl;
  final double score;
  final int rank;
  final DateTime joinedAt;

  const ChallengeParticipant({
    required this.memberId,
    required this.memberName,
    this.memberPhotoUrl,
    this.score = 0,
    this.rank = 0,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'memberPhotoUrl': memberPhotoUrl,
      'score': score,
      'rank': rank,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipant(
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      memberPhotoUrl: json['memberPhotoUrl'] as String?,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  ChallengeParticipant copyWith({
    String? memberId,
    String? memberName,
    String? memberPhotoUrl,
    double? score,
    int? rank,
    DateTime? joinedAt,
    bool clearMemberPhotoUrl = false,
  }) {
    return ChallengeParticipant(
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      memberPhotoUrl: clearMemberPhotoUrl
          ? null
          : (memberPhotoUrl ?? this.memberPhotoUrl),
      score: score ?? this.score,
      rank: rank ?? this.rank,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeParticipant &&
          runtimeType == other.runtimeType &&
          memberId == other.memberId;

  @override
  int get hashCode => memberId.hashCode;
}

// ---------------------------------------------------------------------------
// Challenge
// ---------------------------------------------------------------------------

@immutable
class Challenge {
  final String id;
  final String gymId;
  final String title;
  final String description;
  final String? imageUrl;
  final ChallengeType type;
  final DateTime startDate;
  final DateTime endDate;
  final List<ChallengeParticipant> participants;
  final int xpReward;
  final bool isActive;
  final String createdBy;

  /// Winning threshold (e.g. 20.0 for "20 check-ins to win").
  final double target;

  /// Unit of the score (e.g. 'check-ins', 'kg lifted', 'calories').
  final String unit;

  /// Optional description of the physical prize.
  final String? prize;

  const Challenge({
    required this.id,
    required this.gymId,
    required this.title,
    this.description = '',
    this.imageUrl,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.participants = const [],
    this.xpReward = 0,
    this.isActive = true,
    required this.createdBy,
    required this.target,
    required this.unit,
    this.prize,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  bool get isEnded => DateTime.now().isAfter(endDate);

  int get daysLeft {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Top 10 participants sorted by score descending.
  List<ChallengeParticipant> get topParticipants {
    final sorted = [...participants]
      ..sort((a, b) => b.score.compareTo(a.score));
    return sorted.take(10).toList();
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gymId': gymId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'xpReward': xpReward,
      'isActive': isActive,
      'createdBy': createdBy,
      'target': target,
      'unit': unit,
      'prize': prize,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      type: ChallengeType.fromString(json['type'] as String? ?? 'custom'),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) =>
                  ChallengeParticipant.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy'] as String,
      target: (json['target'] as num).toDouble(),
      unit: json['unit'] as String,
      prize: json['prize'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Challenge copyWith({
    String? id,
    String? gymId,
    String? title,
    String? description,
    String? imageUrl,
    ChallengeType? type,
    DateTime? startDate,
    DateTime? endDate,
    List<ChallengeParticipant>? participants,
    int? xpReward,
    bool? isActive,
    String? createdBy,
    double? target,
    String? unit,
    String? prize,
    bool clearImageUrl = false,
    bool clearPrize = false,
  }) {
    return Challenge(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participants: participants ?? this.participants,
      xpReward: xpReward ?? this.xpReward,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      prize: clearPrize ? null : (prize ?? this.prize),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Challenge &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Challenge(id: $id, title: $title, type: ${type.name})';
}
