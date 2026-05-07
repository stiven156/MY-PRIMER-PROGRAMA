import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum StaffRole {
  gymManager,
  personalTrainer,
  groupInstructor,
  receptionist,
  nutritionist,
  physio,
  cleaner,
  security;

  String get displayName {
    switch (this) {
      case StaffRole.gymManager:
        return 'Gym Manager';
      case StaffRole.personalTrainer:
        return 'Personal Trainer';
      case StaffRole.groupInstructor:
        return 'Group Instructor';
      case StaffRole.receptionist:
        return 'Receptionist';
      case StaffRole.nutritionist:
        return 'Nutritionist';
      case StaffRole.physio:
        return 'Physiotherapist';
      case StaffRole.cleaner:
        return 'Cleaner';
      case StaffRole.security:
        return 'Security';
    }
  }

  static StaffRole fromString(String value) {
    return StaffRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StaffRole.receptionist,
    );
  }
}

// ---------------------------------------------------------------------------
// StaffMember
// ---------------------------------------------------------------------------

@immutable
class StaffMember {
  final String id;
  final String gymId;
  final String name;
  final String email;
  final String? phone;
  final StaffRole role;
  final double? salary;
  final String? photoUrl;

  /// Areas of expertise (e.g. 'Powerlifting', 'Yoga', 'Nutrition').
  final List<String> specializations;

  /// Professional certifications (e.g. 'NSCA-CSCS', 'ACE CPT').
  final List<String> certifications;

  final DateTime hireDate;
  final bool isActive;
  final String? bio;

  /// Average member rating, 0.0 – 5.0.
  final double? rating;

  /// Total group classes taught.
  final int totalClasses;

  /// Total members currently assigned (mainly relevant for trainers).
  final int totalMembers;

  /// Days of week this staff member works: 1 = Monday … 7 = Sunday.
  final List<int> workingDays;

  /// Working hours as a string, e.g. "08:00-16:00".
  final String workingHours;

  const StaffMember({
    required this.id,
    required this.gymId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.salary,
    this.photoUrl,
    this.specializations = const [],
    this.certifications = const [],
    required this.hireDate,
    this.isActive = true,
    this.bio,
    this.rating,
    this.totalClasses = 0,
    this.totalMembers = 0,
    this.workingDays = const [1, 2, 3, 4, 5],
    this.workingHours = '08:00-17:00',
  });

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
      'role': role.name,
      'salary': salary,
      'photoUrl': photoUrl,
      'specializations': specializations,
      'certifications': certifications,
      'hireDate': hireDate.toIso8601String(),
      'isActive': isActive,
      'bio': bio,
      'rating': rating,
      'totalClasses': totalClasses,
      'totalMembers': totalMembers,
      'workingDays': workingDays,
      'workingHours': workingHours,
    };
  }

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: StaffRole.fromString(json['role'] as String? ?? 'receptionist'),
      salary: (json['salary'] as num?)?.toDouble(),
      photoUrl: json['photoUrl'] as String?,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hireDate: DateTime.parse(json['hireDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      bio: json['bio'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalClasses: (json['totalClasses'] as num?)?.toInt() ?? 0,
      totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
      workingDays: (json['workingDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [1, 2, 3, 4, 5],
      workingHours: json['workingHours'] as String? ?? '08:00-17:00',
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  StaffMember copyWith({
    String? id,
    String? gymId,
    String? name,
    String? email,
    String? phone,
    StaffRole? role,
    double? salary,
    String? photoUrl,
    List<String>? specializations,
    List<String>? certifications,
    DateTime? hireDate,
    bool? isActive,
    String? bio,
    double? rating,
    int? totalClasses,
    int? totalMembers,
    List<int>? workingDays,
    String? workingHours,
    bool clearPhone = false,
    bool clearSalary = false,
    bool clearPhotoUrl = false,
    bool clearBio = false,
    bool clearRating = false,
  }) {
    return StaffMember(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: clearPhone ? null : (phone ?? this.phone),
      role: role ?? this.role,
      salary: clearSalary ? null : (salary ?? this.salary),
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      specializations: specializations ?? this.specializations,
      certifications: certifications ?? this.certifications,
      hireDate: hireDate ?? this.hireDate,
      isActive: isActive ?? this.isActive,
      bio: clearBio ? null : (bio ?? this.bio),
      rating: clearRating ? null : (rating ?? this.rating),
      totalClasses: totalClasses ?? this.totalClasses,
      totalMembers: totalMembers ?? this.totalMembers,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffMember &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'StaffMember(id: $id, name: $name, role: ${role.name})';
}
