import 'package:flutter/foundation.dart';

enum GymPlan {
  basic,
  pro,
  enterprise;

  String get displayName {
    switch (this) {
      case GymPlan.basic:
        return 'Basic';
      case GymPlan.pro:
        return 'Pro';
      case GymPlan.enterprise:
        return 'Enterprise';
    }
  }

  String get value {
    switch (this) {
      case GymPlan.basic:
        return 'basic';
      case GymPlan.pro:
        return 'pro';
      case GymPlan.enterprise:
        return 'enterprise';
    }
  }

  int get planMaxMembers {
    switch (this) {
      case GymPlan.basic:
        return 100;
      case GymPlan.pro:
        return 500;
      case GymPlan.enterprise:
        return 99999;
    }
  }

  double get monthlyPrice {
    switch (this) {
      case GymPlan.basic:
        return 29.99;
      case GymPlan.pro:
        return 79.99;
      case GymPlan.enterprise:
        return 199.99;
    }
  }

  static GymPlan fromString(String value) {
    switch (value) {
      case 'pro':
        return GymPlan.pro;
      case 'enterprise':
        return GymPlan.enterprise;
      case 'basic':
      default:
        return GymPlan.basic;
    }
  }
}

/// All possible gym amenity options used throughout the app.
const List<String> kAmenityOptions = [
  'Estacionamiento',
  'Piscina',
  'Sauna',
  'Vestuarios',
  'Cafetería',
  'Tienda',
  'WiFi',
  'TV',
  'Duchas',
  'Taquillas',
  'Zona Cardio',
  'Pesas Libres',
  'Máquinas',
  'Zona Funcional',
  'Spinning',
  'Yoga Studio',
  'Crossfit Box',
  'Pista de combate',
  'Solario',
];

@immutable
class GymModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String country;
  final String phone;
  final String email;
  final String? logoUrl;
  final String? website;
  final String? instagram;

  /// Opening time as a string in "HH:mm" format, e.g. "06:00".
  final String openTime;

  /// Closing time as a string in "HH:mm" format, e.g. "22:00".
  final String closeTime;

  final String ownerId;

  /// Primary brand colour as a hex string, e.g. "#FF6B35".
  final String primaryColor;

  /// Secondary brand colour as a hex string, e.g. "#1A1A2E".
  final String secondaryColor;

  final GymPlan plan;
  final int membersCount;
  final int maxMembers;

  /// Selected amenities from [kAmenityOptions].
  final List<String> amenities;

  final bool isActive;
  final DateTime createdAt;
  final String description;

  /// Map of weekday name (lowercase English) to open/closed boolean.
  /// Keys: 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'.
  final Map<String, bool> workingDays;

  const GymModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.phone,
    required this.email,
    this.logoUrl,
    this.website,
    this.instagram,
    required this.openTime,
    required this.closeTime,
    required this.ownerId,
    this.primaryColor = '#FF6B35',
    this.secondaryColor = '#1A1A2E',
    this.plan = GymPlan.basic,
    this.membersCount = 0,
    this.maxMembers = 100,
    this.amenities = const [],
    this.isActive = true,
    required this.createdAt,
    this.description = '',
    required this.workingDays,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  bool get isFull => membersCount >= maxMembers;

  double get occupancyRate =>
      maxMembers > 0 ? membersCount / maxMembers : 0.0;

  /// Human-readable list of open weekday abbreviations.
  List<String> get openDaysDisplay {
    const dayNames = {
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
    };
    return workingDays.entries
        .where((e) => e.value)
        .map((e) => dayNames[e.key] ?? e.key)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'phone': phone,
      'email': email,
      'logoUrl': logoUrl,
      'website': website,
      'instagram': instagram,
      'openTime': openTime,
      'closeTime': closeTime,
      'ownerId': ownerId,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'plan': plan.value,
      'membersCount': membersCount,
      'maxMembers': maxMembers,
      'amenities': amenities,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'workingDays': workingDays,
    };
  }

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      logoUrl: json['logoUrl'] as String?,
      website: json['website'] as String?,
      instagram: json['instagram'] as String?,
      openTime: json['openTime'] as String? ?? '06:00',
      closeTime: json['closeTime'] as String? ?? '22:00',
      ownerId: json['ownerId'] as String,
      primaryColor: json['primaryColor'] as String? ?? '#FF6B35',
      secondaryColor: json['secondaryColor'] as String? ?? '#1A1A2E',
      plan: GymPlan.fromString(json['plan'] as String? ?? 'basic'),
      membersCount: (json['membersCount'] as num?)?.toInt() ?? 0,
      maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 100,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      description: json['description'] as String? ?? '',
      workingDays: (json['workingDays'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as bool)) ??
          _defaultWorkingDays(),
    );
  }

  static Map<String, bool> _defaultWorkingDays() => {
        'monday': true,
        'tuesday': true,
        'wednesday': true,
        'thursday': true,
        'friday': true,
        'saturday': true,
        'sunday': false,
      };

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  GymModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? country,
    String? phone,
    String? email,
    String? logoUrl,
    String? website,
    String? instagram,
    String? openTime,
    String? closeTime,
    String? ownerId,
    String? primaryColor,
    String? secondaryColor,
    GymPlan? plan,
    int? membersCount,
    int? maxMembers,
    List<String>? amenities,
    bool? isActive,
    DateTime? createdAt,
    String? description,
    Map<String, bool>? workingDays,
    bool clearLogoUrl = false,
    bool clearWebsite = false,
    bool clearInstagram = false,
  }) {
    return GymModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoUrl: clearLogoUrl ? null : (logoUrl ?? this.logoUrl),
      website: clearWebsite ? null : (website ?? this.website),
      instagram: clearInstagram ? null : (instagram ?? this.instagram),
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      ownerId: ownerId ?? this.ownerId,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      plan: plan ?? this.plan,
      membersCount: membersCount ?? this.membersCount,
      maxMembers: maxMembers ?? this.maxMembers,
      amenities: amenities ?? this.amenities,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      workingDays: workingDays ?? this.workingDays,
    );
  }

  // ---------------------------------------------------------------------------
  // Mock factory
  // ---------------------------------------------------------------------------

  factory GymModel.mock() {
    return GymModel(
      id: 'gym_mock_001',
      name: 'FitPro Elite Gym',
      address: '1234 Fitness Ave, Suite 100',
      city: 'Miami',
      country: 'USA',
      phone: '+1 305-555-0100',
      email: 'info@fitproelite.com',
      logoUrl: 'https://picsum.photos/seed/gym/200',
      website: 'https://fitproelite.com',
      instagram: '@fitproelite',
      openTime: '06:00',
      closeTime: '23:00',
      ownerId: 'user_admin_001',
      primaryColor: '#FF6B35',
      secondaryColor: '#1A1A2E',
      plan: GymPlan.pro,
      membersCount: 248,
      maxMembers: 500,
      amenities: [
        'Estacionamiento',
        'Vestuarios',
        'Duchas',
        'Taquillas',
        'WiFi',
        'TV',
        'Zona Cardio',
        'Pesas Libres',
        'Máquinas',
        'Zona Funcional',
        'Spinning',
        'Sauna',
      ],
      isActive: true,
      createdAt: DateTime(2023, 1, 10),
      description:
          'State-of-the-art fitness facility with world-class equipment and professional trainers. '
          'Your journey to a healthier life starts here.',
      workingDays: {
        'monday': true,
        'tuesday': true,
        'wednesday': true,
        'thursday': true,
        'friday': true,
        'saturday': true,
        'sunday': false,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GymModel(id: $id, name: $name, plan: ${plan.value})';
}
