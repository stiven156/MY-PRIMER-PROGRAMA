import 'package:flutter/foundation.dart';

@immutable
class BodyMeasurement {
  final String id;
  final String memberId;
  final DateTime date;

  // Composition
  final double? weight;
  final double? bodyFat;
  final double? muscleMass;

  // Circumferences (cm)
  final double? neck;
  final double? shoulders;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? leftBicep;
  final double? rightBicep;
  final double? leftForearm;
  final double? rightForearm;
  final double? leftThigh;
  final double? rightThigh;
  final double? leftCalf;
  final double? rightCalf;

  final String? notes;
  final String? photoUrl;

  const BodyMeasurement({
    required this.id,
    required this.memberId,
    required this.date,
    this.weight,
    this.bodyFat,
    this.muscleMass,
    this.neck,
    this.shoulders,
    this.chest,
    this.waist,
    this.hips,
    this.leftBicep,
    this.rightBicep,
    this.leftForearm,
    this.rightForearm,
    this.leftThigh,
    this.rightThigh,
    this.leftCalf,
    this.rightCalf,
    this.notes,
    this.photoUrl,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// BMI = weight (kg) / height (m)².
  /// [heightCm] must be provided because height is not stored per measurement.
  double? bmi(double? heightCm) {
    if (weight == null || heightCm == null || heightCm <= 0) return null;
    final hm = heightCm / 100.0;
    return weight! / (hm * hm);
  }

  /// Human-friendly weight category based on BMI.
  String weightCategory(double? heightCm) {
    final b = bmi(heightCm);
    if (b == null) return 'Unknown';
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    if (b < 35.0) return 'Obese Class I';
    if (b < 40.0) return 'Obese Class II';
    return 'Obese Class III';
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'date': date.toIso8601String(),
      'weight': weight,
      'bodyFat': bodyFat,
      'muscleMass': muscleMass,
      'neck': neck,
      'shoulders': shoulders,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'leftBicep': leftBicep,
      'rightBicep': rightBicep,
      'leftForearm': leftForearm,
      'rightForearm': rightForearm,
      'leftThigh': leftThigh,
      'rightThigh': rightThigh,
      'leftCalf': leftCalf,
      'rightCalf': rightCalf,
      'notes': notes,
      'photoUrl': photoUrl,
    };
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num?)?.toDouble(),
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      muscleMass: (json['muscleMass'] as num?)?.toDouble(),
      neck: (json['neck'] as num?)?.toDouble(),
      shoulders: (json['shoulders'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      leftBicep: (json['leftBicep'] as num?)?.toDouble(),
      rightBicep: (json['rightBicep'] as num?)?.toDouble(),
      leftForearm: (json['leftForearm'] as num?)?.toDouble(),
      rightForearm: (json['rightForearm'] as num?)?.toDouble(),
      leftThigh: (json['leftThigh'] as num?)?.toDouble(),
      rightThigh: (json['rightThigh'] as num?)?.toDouble(),
      leftCalf: (json['leftCalf'] as num?)?.toDouble(),
      rightCalf: (json['rightCalf'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  BodyMeasurement copyWith({
    String? id,
    String? memberId,
    DateTime? date,
    double? weight,
    double? bodyFat,
    double? muscleMass,
    double? neck,
    double? shoulders,
    double? chest,
    double? waist,
    double? hips,
    double? leftBicep,
    double? rightBicep,
    double? leftForearm,
    double? rightForearm,
    double? leftThigh,
    double? rightThigh,
    double? leftCalf,
    double? rightCalf,
    String? notes,
    String? photoUrl,
    bool clearWeight = false,
    bool clearBodyFat = false,
    bool clearMuscleMass = false,
    bool clearNotes = false,
    bool clearPhotoUrl = false,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      date: date ?? this.date,
      weight: clearWeight ? null : (weight ?? this.weight),
      bodyFat: clearBodyFat ? null : (bodyFat ?? this.bodyFat),
      muscleMass: clearMuscleMass ? null : (muscleMass ?? this.muscleMass),
      neck: neck ?? this.neck,
      shoulders: shoulders ?? this.shoulders,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      leftBicep: leftBicep ?? this.leftBicep,
      rightBicep: rightBicep ?? this.rightBicep,
      leftForearm: leftForearm ?? this.leftForearm,
      rightForearm: rightForearm ?? this.rightForearm,
      leftThigh: leftThigh ?? this.leftThigh,
      rightThigh: rightThigh ?? this.rightThigh,
      leftCalf: leftCalf ?? this.leftCalf,
      rightCalf: rightCalf ?? this.rightCalf,
      notes: clearNotes ? null : (notes ?? this.notes),
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyMeasurement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BodyMeasurement(id: $id, memberId: $memberId, date: $date, weight: $weight)';
}
