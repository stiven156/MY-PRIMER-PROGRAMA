class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;

  /// Tax identification number (RFC, NIT, RUT, etc.).
  /// Nullable — not every customer is registered as a business entity.
  final String? taxId;

  /// Maximum credit the business allows this customer to carry.
  final double creditLimit;

  /// Outstanding balance currently owed by the customer to the store.
  final double currentDebt;

  /// Loyalty points accumulated through purchases.
  final int points;

  final bool isActive;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.taxId,
    required this.creditLimit,
    required this.currentDebt,
    required this.points,
    required this.isActive,
    required this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// True when the customer has an outstanding balance greater than zero.
  bool get isInDebt => currentDebt > 0;

  /// Remaining credit the customer may still use.
  /// Clamped to 0.0 so it never reports a negative value even if the debt
  /// has exceeded the credit limit.
  double get availableCredit {
    final remaining = creditLimit - currentDebt;
    return remaining < 0 ? 0 : remaining;
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Pass [clearTaxId] = true to explicitly null out [taxId].
  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? taxId,
    double? creditLimit,
    double? currentDebt,
    int? points,
    bool? isActive,
    DateTime? createdAt,
    bool clearTaxId = false,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxId: clearTaxId ? null : (taxId ?? this.taxId),
      creditLimit: creditLimit ?? this.creditLimit,
      currentDebt: currentDebt ?? this.currentDebt,
      points: points ?? this.points,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'taxId': taxId,
      'creditLimit': creditLimit,
      'currentDebt': currentDebt,
      'points': points,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      taxId: json['taxId'] as String?,
      creditLimit: (json['creditLimit'] as num).toDouble(),
      currentDebt: (json['currentDebt'] as num).toDouble(),
      points: json['points'] as int,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.email == email &&
        other.address == address &&
        other.taxId == taxId &&
        other.creditLimit == creditLimit &&
        other.currentDebt == currentDebt &&
        other.points == points &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      name,
      phone,
      email,
      address,
      taxId,
      creditLimit,
      currentDebt,
      points,
      isActive,
      createdAt,
    ]);
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phone, '
        'currentDebt: $currentDebt, availableCredit: $availableCredit, '
        'points: $points, isActive: $isActive)';
  }
}
