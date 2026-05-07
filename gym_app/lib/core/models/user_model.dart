import 'package:flutter/foundation.dart';

enum UserRole {
  superAdmin,
  gymAdmin,
  trainer,
  member;

  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.gymAdmin:
        return 'Gym Admin';
      case UserRole.trainer:
        return 'Trainer';
      case UserRole.member:
        return 'Member';
    }
  }

  String get value {
    switch (this) {
      case UserRole.superAdmin:
        return 'superAdmin';
      case UserRole.gymAdmin:
        return 'gymAdmin';
      case UserRole.trainer:
        return 'trainer';
      case UserRole.member:
        return 'member';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'superAdmin':
        return UserRole.superAdmin;
      case 'gymAdmin':
        return UserRole.gymAdmin;
      case 'trainer':
        return UserRole.trainer;
      case 'member':
      default:
        return UserRole.member;
    }
  }
}

@immutable
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? gymId;
  final UserRole role;
  final DateTime createdAt;
  final int xpPoints;
  final int level;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final String? bio;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.gymId,
    required this.role,
    required this.createdAt,
    this.xpPoints = 0,
    this.level = 1,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.bio,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

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

  bool get isAdmin =>
      role == UserRole.superAdmin || role == UserRole.gymAdmin;

  bool get isTrainer => role == UserRole.trainer;

  bool get isMember => role == UserRole.member;

  /// XP required to reach the next level (each level costs 500 XP).
  int get xpToNextLevel => level * 500;

  /// Fractional progress towards the next level (0.0 – 1.0).
  double get levelProgress {
    final xpInCurrentLevel = xpPoints % 500;
    return xpInCurrentLevel / 500.0;
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'gymId': gymId,
      'role': role.value,
      'createdAt': createdAt.toIso8601String(),
      'xpPoints': xpPoints,
      'level': level,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'bio': bio,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      gymId: json['gymId'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'member'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      xpPoints: (json['xpPoints'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      phoneNumber: json['phoneNumber'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? gymId,
    UserRole? role,
    DateTime? createdAt,
    int? xpPoints,
    int? level,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    String? bio,
    bool clearPhotoUrl = false,
    bool clearGymId = false,
    bool clearPhoneNumber = false,
    bool clearBirthDate = false,
    bool clearGender = false,
    bool clearBio = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      gymId: clearGymId ? null : (gymId ?? this.gymId),
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      xpPoints: xpPoints ?? this.xpPoints,
      level: level ?? this.level,
      phoneNumber:
          clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      gender: clearGender ? null : (gender ?? this.gender),
      bio: clearBio ? null : (bio ?? this.bio),
    );
  }

  // ---------------------------------------------------------------------------
  // Mock factories
  // ---------------------------------------------------------------------------

  factory UserModel.mock() {
    return UserModel(
      id: 'user_mock_001',
      email: 'john.doe@fitpro.com',
      name: 'John Doe',
      photoUrl: 'https://i.pravatar.cc/300?img=12',
      gymId: 'gym_mock_001',
      role: UserRole.member,
      createdAt: DateTime(2024, 1, 15),
      xpPoints: 1250,
      level: 3,
      phoneNumber: '+1 555-0123',
      birthDate: DateTime(1992, 6, 20),
      gender: 'Male',
      bio: 'Fitness enthusiast and weekend warrior. Loves lifting and running.',
    );
  }

  factory UserModel.mockAdmin() {
    return UserModel(
      id: 'user_admin_001',
      email: 'admin@fitpro.com',
      name: 'Carlos Rodríguez',
      photoUrl: 'https://i.pravatar.cc/300?img=33',
      gymId: 'gym_mock_001',
      role: UserRole.gymAdmin,
      createdAt: DateTime(2023, 8, 1),
      xpPoints: 5000,
      level: 10,
      phoneNumber: '+1 555-9999',
      birthDate: DateTime(1985, 3, 10),
      gender: 'Male',
      bio: 'Gym owner and certified personal trainer with 15 years experience.',
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: ${role.value})';
}
