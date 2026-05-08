class Supplier {
  final String id;
  final String name;
  final String contactName;
  final String phone;
  final String email;
  final String address;

  /// Tax identification number (RFC, NIT, RUT, etc.).
  final String taxId;

  final String notes;
  final bool isActive;
  final DateTime createdAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.address,
    required this.taxId,
    required this.notes,
    required this.isActive,
    required this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Supplier copyWith({
    String? id,
    String? name,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    String? taxId,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      notes: notes ?? this.notes,
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
      'contactName': contactName,
      'phone': phone,
      'email': email,
      'address': address,
      'taxId': taxId,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      contactName: json['contactName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      taxId: json['taxId'] as String,
      notes: json['notes'] as String,
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
    return other is Supplier &&
        other.id == id &&
        other.name == name &&
        other.contactName == contactName &&
        other.phone == phone &&
        other.email == email &&
        other.address == address &&
        other.taxId == taxId &&
        other.notes == notes &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      name,
      contactName,
      phone,
      email,
      address,
      taxId,
      notes,
      isActive,
      createdAt,
    ]);
  }

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, contactName: $contactName, '
        'phone: $phone, isActive: $isActive)';
  }
}
