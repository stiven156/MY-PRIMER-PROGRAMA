import 'package:flutter/foundation.dart';

@immutable
class MembershipPlanModel {
  final String id;
  final String gymId;
  final String name;
  final String description;
  final double price;

  /// Duration of the plan in calendar days.
  final int durationDays;

  /// Brand colour for this plan card as a hex string, e.g. "#4CAF50".
  final String color;

  final List<String> features;
  final bool isActive;
  final bool isPopular;

  /// Maximum number of days the member is allowed to freeze this plan.
  final int maxFreeze;

  final bool includesPersonalTraining;

  /// Maximum sessions allowed per week. Null means unlimited.
  final int? sessionsPerWeek;

  final DateTime createdAt;

  const MembershipPlanModel({
    required this.id,
    required this.gymId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.color,
    this.features = const [],
    this.isActive = true,
    this.isPopular = false,
    this.maxFreeze = 0,
    this.includesPersonalTraining = false,
    this.sessionsPerWeek,
    required this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// Cost per day.
  double get pricePerDay => durationDays > 0 ? price / durationDays : price;

  /// Human-friendly duration label, e.g. "1 Month" or "1 Year".
  String get durationLabel {
    if (durationDays == 365) return '1 Year';
    if (durationDays == 180) return '6 Months';
    if (durationDays == 90) return '3 Months';
    if (durationDays == 30) return '1 Month';
    return '$durationDays Days';
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gymId': gymId,
      'name': name,
      'description': description,
      'price': price,
      'durationDays': durationDays,
      'color': color,
      'features': features,
      'isActive': isActive,
      'isPopular': isPopular,
      'maxFreeze': maxFreeze,
      'includesPersonalTraining': includesPersonalTraining,
      'sessionsPerWeek': sessionsPerWeek,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) {
    return MembershipPlanModel(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      durationDays: (json['durationDays'] as num).toInt(),
      color: json['color'] as String? ?? '#FF6B35',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      isPopular: json['isPopular'] as bool? ?? false,
      maxFreeze: (json['maxFreeze'] as num?)?.toInt() ?? 0,
      includesPersonalTraining:
          json['includesPersonalTraining'] as bool? ?? false,
      sessionsPerWeek: (json['sessionsPerWeek'] as num?)?.toInt(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  MembershipPlanModel copyWith({
    String? id,
    String? gymId,
    String? name,
    String? description,
    double? price,
    int? durationDays,
    String? color,
    List<String>? features,
    bool? isActive,
    bool? isPopular,
    int? maxFreeze,
    bool? includesPersonalTraining,
    int? sessionsPerWeek,
    DateTime? createdAt,
    bool clearSessionsPerWeek = false,
  }) {
    return MembershipPlanModel(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      color: color ?? this.color,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
      maxFreeze: maxFreeze ?? this.maxFreeze,
      includesPersonalTraining:
          includesPersonalTraining ?? this.includesPersonalTraining,
      sessionsPerWeek:
          clearSessionsPerWeek ? null : (sessionsPerWeek ?? this.sessionsPerWeek),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Mock plans
  // ---------------------------------------------------------------------------

  /// Returns the four standard mock membership plans.
  static List<MembershipPlanModel> mockPlans({String gymId = 'gym_mock_001'}) {
    final now = DateTime(2024, 1, 1);
    return [
      MembershipPlanModel(
        id: 'plan_basic',
        gymId: gymId,
        name: 'Básico',
        description:
            'Access to all gym equipment during standard hours. Perfect for beginners.',
        price: 30.0,
        durationDays: 30,
        color: '#78909C',
        features: [
          'Acceso a equipamiento',
          'Zona de pesas',
          'Vestuarios y duchas',
          'Horario estándar 06:00-22:00',
        ],
        isActive: true,
        isPopular: false,
        maxFreeze: 5,
        includesPersonalTraining: false,
        sessionsPerWeek: null,
        createdAt: now,
      ),
      MembershipPlanModel(
        id: 'plan_standard',
        gymId: gymId,
        name: 'Estándar',
        description:
            'Everything in Básico plus group classes and priority booking.',
        price: 50.0,
        durationDays: 30,
        color: '#42A5F5',
        features: [
          'Todo lo de Básico',
          'Clases grupales ilimitadas',
          'Reserva prioritaria',
          'Acceso a Zona Funcional',
          'App FitPro Manager',
        ],
        isActive: true,
        isPopular: true,
        maxFreeze: 10,
        includesPersonalTraining: false,
        sessionsPerWeek: null,
        createdAt: now,
      ),
      MembershipPlanModel(
        id: 'plan_pro',
        gymId: gymId,
        name: 'Pro',
        description:
            'Quarterly plan with personal training sessions included. Best value.',
        price: 120.0,
        durationDays: 90,
        color: '#FF6B35',
        features: [
          'Todo lo de Estándar',
          '4 sesiones de entrenamiento personal',
          'Plan nutricional básico',
          'Análisis de composición corporal',
          'Acceso 24/7',
          'Freeze hasta 15 días',
        ],
        isActive: true,
        isPopular: false,
        maxFreeze: 15,
        includesPersonalTraining: true,
        sessionsPerWeek: null,
        createdAt: now,
      ),
      MembershipPlanModel(
        id: 'plan_elite',
        gymId: gymId,
        name: 'Elite',
        description:
            'The full FitPro experience for an entire year. Unlimited everything.',
        price: 400.0,
        durationDays: 365,
        color: '#FFD700',
        features: [
          'Todo lo de Pro',
          'Entrenamiento personal ilimitado',
          'Nutricionista asignado',
          'Seguimiento mensual de métricas',
          'Acceso a todas las instalaciones',
          'Freeze hasta 30 días',
          'Traer 1 acompañante por mes gratis',
          'Descuentos en tienda y cafetería',
        ],
        isActive: true,
        isPopular: false,
        maxFreeze: 30,
        includesPersonalTraining: true,
        sessionsPerWeek: null,
        createdAt: now,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembershipPlanModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MembershipPlanModel(id: $id, name: $name, price: \$$price, '
      'durationDays: $durationDays)';
}
