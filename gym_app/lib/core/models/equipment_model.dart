import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum EquipmentCategory {
  cardio,
  freeWeights,
  machines,
  cables,
  functional,
  accessories,
  recovery,
  other;

  String get displayName {
    switch (this) {
      case EquipmentCategory.cardio:
        return 'Cardio';
      case EquipmentCategory.freeWeights:
        return 'Free Weights';
      case EquipmentCategory.machines:
        return 'Machines';
      case EquipmentCategory.cables:
        return 'Cables';
      case EquipmentCategory.functional:
        return 'Functional';
      case EquipmentCategory.accessories:
        return 'Accessories';
      case EquipmentCategory.recovery:
        return 'Recovery';
      case EquipmentCategory.other:
        return 'Other';
    }
  }

  static EquipmentCategory fromString(String value) {
    return EquipmentCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EquipmentCategory.other,
    );
  }
}

enum EquipmentStatus {
  operational,
  needsMaintenance,
  inMaintenance,
  outOfService,
  retired;

  String get displayName {
    switch (this) {
      case EquipmentStatus.operational:
        return 'Operational';
      case EquipmentStatus.needsMaintenance:
        return 'Needs Maintenance';
      case EquipmentStatus.inMaintenance:
        return 'In Maintenance';
      case EquipmentStatus.outOfService:
        return 'Out of Service';
      case EquipmentStatus.retired:
        return 'Retired';
    }
  }

  static EquipmentStatus fromString(String value) {
    return EquipmentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EquipmentStatus.operational,
    );
  }
}

// ---------------------------------------------------------------------------
// EquipmentItem
// ---------------------------------------------------------------------------

@immutable
class EquipmentItem {
  final String id;
  final String gymId;
  final String name;
  final EquipmentCategory category;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final EquipmentStatus status;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String? notes;
  final String? imageUrl;

  /// Number of identical units at this location.
  final int quantity;

  /// Room or area within the gym, e.g. "Cardio Zone".
  final String? location;

  const EquipmentItem({
    required this.id,
    required this.gymId,
    required this.name,
    required this.category,
    this.brand,
    this.model,
    this.serialNumber,
    this.purchaseDate,
    this.purchasePrice,
    this.status = EquipmentStatus.operational,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.notes,
    this.imageUrl,
    this.quantity = 1,
    this.location,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// True when next maintenance is overdue or within the next 7 days.
  bool get isMaintenanceDue {
    if (nextMaintenanceDate == null) return false;
    return nextMaintenanceDate!
        .isBefore(DateTime.now().add(const Duration(days: 7)));
  }

  /// Days elapsed since the last maintenance, or null if unknown.
  int? get daysSinceLastMaintenance {
    if (lastMaintenanceDate == null) return null;
    return DateTime.now().difference(lastMaintenanceDate!).inDays;
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gymId': gymId,
      'name': name,
      'category': category.name,
      'brand': brand,
      'model': model,
      'serialNumber': serialNumber,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchasePrice': purchasePrice,
      'status': status.name,
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'nextMaintenanceDate': nextMaintenanceDate?.toIso8601String(),
      'notes': notes,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'location': location,
    };
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      name: json['name'] as String,
      category: EquipmentCategory.fromString(
          json['category'] as String? ?? 'other'),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serialNumber'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      status: EquipmentStatus.fromString(
          json['status'] as String? ?? 'operational'),
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? DateTime.parse(json['lastMaintenanceDate'] as String)
          : null,
      nextMaintenanceDate: json['nextMaintenanceDate'] != null
          ? DateTime.parse(json['nextMaintenanceDate'] as String)
          : null,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      location: json['location'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  EquipmentItem copyWith({
    String? id,
    String? gymId,
    String? name,
    EquipmentCategory? category,
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? purchaseDate,
    double? purchasePrice,
    EquipmentStatus? status,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? notes,
    String? imageUrl,
    int? quantity,
    String? location,
    bool clearBrand = false,
    bool clearModel = false,
    bool clearSerialNumber = false,
    bool clearPurchaseDate = false,
    bool clearPurchasePrice = false,
    bool clearLastMaintenanceDate = false,
    bool clearNextMaintenanceDate = false,
    bool clearNotes = false,
    bool clearImageUrl = false,
    bool clearLocation = false,
  }) {
    return EquipmentItem(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: clearBrand ? null : (brand ?? this.brand),
      model: clearModel ? null : (model ?? this.model),
      serialNumber:
          clearSerialNumber ? null : (serialNumber ?? this.serialNumber),
      purchaseDate:
          clearPurchaseDate ? null : (purchaseDate ?? this.purchaseDate),
      purchasePrice:
          clearPurchasePrice ? null : (purchasePrice ?? this.purchasePrice),
      status: status ?? this.status,
      lastMaintenanceDate: clearLastMaintenanceDate
          ? null
          : (lastMaintenanceDate ?? this.lastMaintenanceDate),
      nextMaintenanceDate: clearNextMaintenanceDate
          ? null
          : (nextMaintenanceDate ?? this.nextMaintenanceDate),
      notes: clearNotes ? null : (notes ?? this.notes),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      quantity: quantity ?? this.quantity,
      location: clearLocation ? null : (location ?? this.location),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EquipmentItem(id: $id, name: $name, status: ${status.name})';
}
