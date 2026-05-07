import 'package:flutter/foundation.dart';

enum MemberStatus {
  active,
  expired,
  frozen,
  cancelled,
  trial;

  String get displayName {
    switch (this) {
      case MemberStatus.active:
        return 'Active';
      case MemberStatus.expired:
        return 'Expired';
      case MemberStatus.frozen:
        return 'Frozen';
      case MemberStatus.cancelled:
        return 'Cancelled';
      case MemberStatus.trial:
        return 'Trial';
    }
  }

  static MemberStatus fromString(String value) {
    switch (value) {
      case 'active':
        return MemberStatus.active;
      case 'expired':
        return MemberStatus.expired;
      case 'frozen':
        return MemberStatus.frozen;
      case 'cancelled':
        return MemberStatus.cancelled;
      case 'trial':
        return MemberStatus.trial;
      default:
        return MemberStatus.active;
    }
  }
}

enum MemberGoal {
  weightLoss,
  muscleGain,
  endurance,
  flexibility,
  generalFitness,
  rehabilitation,
  sportsPerformance,
  weightMaintenance;

  String get displayName {
    switch (this) {
      case MemberGoal.weightLoss:
        return 'Weight Loss';
      case MemberGoal.muscleGain:
        return 'Muscle Gain';
      case MemberGoal.endurance:
        return 'Endurance';
      case MemberGoal.flexibility:
        return 'Flexibility';
      case MemberGoal.generalFitness:
        return 'General Fitness';
      case MemberGoal.rehabilitation:
        return 'Rehabilitation';
      case MemberGoal.sportsPerformance:
        return 'Sports Performance';
      case MemberGoal.weightMaintenance:
        return 'Weight Maintenance';
    }
  }

  static MemberGoal fromString(String value) {
    return MemberGoal.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MemberGoal.generalFitness,
    );
  }
}

@immutable
class MemberModel {
  final String id;
  final String gymId;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String membershipPlanId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalCheckIns;
  final bool isActive;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? notes;
  final double? weight;
  final double? height;
  final String? bloodType;
  final List<MemberGoal> goals;
  final DateTime? birthDate;
  final String? gender;
  final MemberStatus status;
  final DateTime createdAt;

  /// QR code content – typically the member's own [id].
  final String qrCode;

  final String? nfcTag;
  final DateTime? lastCheckIn;
  final int totalWorkouts;
  final int totalPoints;

  const MemberModel({
    required this.id,
    required this.gymId,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.membershipPlanId,
    required this.startDate,
    required this.endDate,
    this.totalCheckIns = 0,
    this.isActive = true,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.notes,
    this.weight,
    this.height,
    this.bloodType,
    this.goals = const [],
    this.birthDate,
    this.gender,
    required this.status,
    required this.createdAt,
    required this.qrCode,
    this.nfcTag,
    this.lastCheckIn,
    this.totalWorkouts = 0,
    this.totalPoints = 0,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// Days remaining until membership expiry (negative if already expired).
  int get daysUntilExpiry =>
      endDate.difference(DateTime.now()).inDays;

  /// True when the membership expires within the next 7 days.
  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    return days >= 0 && days <= 7;
  }

  /// Body mass index (kg/m²). Returns null if weight or height are unknown.
  double? get bmi {
    if (weight == null || height == null || height! <= 0) return null;
    final heightM = height! / 100.0; // convert cm to m
    return weight! / (heightM * heightM);
  }

  /// Age calculated from [birthDate]. Returns 0 if unknown.
  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gymId': gymId,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'membershipPlanId': membershipPlanId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalCheckIns': totalCheckIns,
      'isActive': isActive,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'notes': notes,
      'weight': weight,
      'height': height,
      'bloodType': bloodType,
      'goals': goals.map((g) => g.name).toList(),
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'qrCode': qrCode,
      'nfcTag': nfcTag,
      'lastCheckIn': lastCheckIn?.toIso8601String(),
      'totalWorkouts': totalWorkouts,
      'totalPoints': totalPoints,
    };
  }

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      membershipPlanId: json['membershipPlanId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalCheckIns: (json['totalCheckIns'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      notes: json['notes'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      bloodType: json['bloodType'] as String?,
      goals: (json['goals'] as List<dynamic>?)
              ?.map((g) => MemberGoal.fromString(g as String))
              .toList() ??
          [],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      gender: json['gender'] as String?,
      status: MemberStatus.fromString(json['status'] as String? ?? 'active'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      qrCode: json['qrCode'] as String? ?? json['id'] as String,
      nfcTag: json['nfcTag'] as String?,
      lastCheckIn: json['lastCheckIn'] != null
          ? DateTime.parse(json['lastCheckIn'] as String)
          : null,
      totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  MemberModel copyWith({
    String? id,
    String? gymId,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? membershipPlanId,
    DateTime? startDate,
    DateTime? endDate,
    int? totalCheckIns,
    bool? isActive,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    double? weight,
    double? height,
    String? bloodType,
    List<MemberGoal>? goals,
    DateTime? birthDate,
    String? gender,
    MemberStatus? status,
    DateTime? createdAt,
    String? qrCode,
    String? nfcTag,
    DateTime? lastCheckIn,
    int? totalWorkouts,
    int? totalPoints,
    bool clearPhone = false,
    bool clearPhotoUrl = false,
    bool clearEmergencyContactName = false,
    bool clearEmergencyContactPhone = false,
    bool clearNotes = false,
    bool clearNfcTag = false,
    bool clearLastCheckIn = false,
  }) {
    return MemberModel(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: clearPhone ? null : (phone ?? this.phone),
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      membershipPlanId: membershipPlanId ?? this.membershipPlanId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      isActive: isActive ?? this.isActive,
      emergencyContactName: clearEmergencyContactName
          ? null
          : (emergencyContactName ?? this.emergencyContactName),
      emergencyContactPhone: clearEmergencyContactPhone
          ? null
          : (emergencyContactPhone ?? this.emergencyContactPhone),
      notes: clearNotes ? null : (notes ?? this.notes),
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodType: bloodType ?? this.bloodType,
      goals: goals ?? this.goals,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      qrCode: qrCode ?? this.qrCode,
      nfcTag: clearNfcTag ? null : (nfcTag ?? this.nfcTag),
      lastCheckIn:
          clearLastCheckIn ? null : (lastCheckIn ?? this.lastCheckIn),
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  // ---------------------------------------------------------------------------
  // Mock factory
  // ---------------------------------------------------------------------------

  factory MemberModel.mock() {
    final now = DateTime.now();
    return MemberModel(
      id: 'member_mock_001',
      gymId: 'gym_mock_001',
      name: 'Jane Smith',
      email: 'jane.smith@email.com',
      phone: '+1 555-0199',
      photoUrl: 'https://i.pravatar.cc/300?img=5',
      membershipPlanId: 'plan_standard',
      startDate: now.subtract(const Duration(days: 60)),
      endDate: now.add(const Duration(days: 30)),
      totalCheckIns: 48,
      isActive: true,
      emergencyContactName: 'Bob Smith',
      emergencyContactPhone: '+1 555-0200',
      notes: 'Prefers morning sessions. Knee injury – avoid high impact.',
      weight: 65.0,
      height: 168.0,
      bloodType: 'O+',
      goals: [MemberGoal.weightLoss, MemberGoal.endurance],
      birthDate: DateTime(1995, 4, 12),
      gender: 'Female',
      status: MemberStatus.active,
      createdAt: now.subtract(const Duration(days: 60)),
      qrCode: 'member_mock_001',
      nfcTag: 'NFC-MOCK-001',
      lastCheckIn: now.subtract(const Duration(hours: 26)),
      totalWorkouts: 42,
      totalPoints: 840,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MemberModel(id: $id, name: $name, status: ${status.name})';
}
