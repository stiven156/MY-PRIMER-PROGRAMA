// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum PurchaseOrderStatus { pending, received, partial, cancelled }

extension PurchaseOrderStatusExtension on PurchaseOrderStatus {
  String get displayName {
    switch (this) {
      case PurchaseOrderStatus.pending:
        return 'Pendiente';
      case PurchaseOrderStatus.received:
        return 'Recibido';
      case PurchaseOrderStatus.partial:
        return 'Parcial';
      case PurchaseOrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get value {
    switch (this) {
      case PurchaseOrderStatus.pending:
        return 'pending';
      case PurchaseOrderStatus.received:
        return 'received';
      case PurchaseOrderStatus.partial:
        return 'partial';
      case PurchaseOrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static PurchaseOrderStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PurchaseOrderStatus.pending;
      case 'received':
        return PurchaseOrderStatus.received;
      case 'partial':
        return PurchaseOrderStatus.partial;
      case 'cancelled':
        return PurchaseOrderStatus.cancelled;
      default:
        throw ArgumentError('Unknown PurchaseOrderStatus: "$value"');
    }
  }
}

// ---------------------------------------------------------------------------
// PurchaseOrderItem
// ---------------------------------------------------------------------------

class PurchaseOrderItem {
  final String productId;
  final String productName;
  final double quantity;
  final double purchasePrice;

  /// Line total: quantity × purchasePrice.
  final double total;

  const PurchaseOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
    required this.total,
  });

  /// Convenience factory that calculates [total] automatically.
  factory PurchaseOrderItem.create({
    required String productId,
    required String productName,
    required double quantity,
    required double purchasePrice,
  }) {
    return PurchaseOrderItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      purchasePrice: purchasePrice,
      total: quantity * purchasePrice,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// When [quantity] or [purchasePrice] changes but no explicit [total] is
  /// supplied the total is recalculated automatically.
  PurchaseOrderItem copyWith({
    String? productId,
    String? productName,
    double? quantity,
    double? purchasePrice,
    double? total,
  }) {
    final newQuantity = quantity ?? this.quantity;
    final newPrice = purchasePrice ?? this.purchasePrice;
    return PurchaseOrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: newQuantity,
      purchasePrice: newPrice,
      total: total ?? (newQuantity * newPrice),
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'total': total,
    };
  }

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseOrderItem &&
        other.productId == productId &&
        other.productName == productName &&
        other.quantity == quantity &&
        other.purchasePrice == purchasePrice &&
        other.total == total;
  }

  @override
  int get hashCode =>
      Object.hash(productId, productName, quantity, purchasePrice, total);

  @override
  String toString() {
    return 'PurchaseOrderItem(productId: $productId, productName: $productName, '
        'quantity: $quantity, purchasePrice: $purchasePrice, total: $total)';
  }
}

// ---------------------------------------------------------------------------
// PurchaseOrder
// ---------------------------------------------------------------------------

class PurchaseOrder {
  final String id;
  final String supplierId;
  final String supplierName;
  final List<PurchaseOrderItem> items;

  /// Sum of all item totals before tax.
  final double subtotal;

  /// Tax amount in currency units.
  final double tax;

  /// Grand total: subtotal + tax.
  final double total;

  final PurchaseOrderStatus status;
  final String notes;
  final DateTime orderedAt;

  /// Set when the order (fully or partially) arrives at the warehouse.
  final DateTime? receivedAt;

  final String employeeId;

  const PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.notes,
    required this.orderedAt,
    this.receivedAt,
    required this.employeeId,
  });

  // ---------------------------------------------------------------------------
  // Convenience factory — derives subtotal, tax, and total from the item list.
  // ---------------------------------------------------------------------------

  factory PurchaseOrder.fromItems({
    required String id,
    required String supplierId,
    required String supplierName,
    required List<PurchaseOrderItem> items,
    required double taxRate,
    PurchaseOrderStatus status = PurchaseOrderStatus.pending,
    required String notes,
    required DateTime orderedAt,
    DateTime? receivedAt,
    required String employeeId,
  }) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    final tax = subtotal * (taxRate / 100);
    final total = subtotal + tax;

    return PurchaseOrder(
      id: id,
      supplierId: supplierId,
      supplierName: supplierName,
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: status,
      notes: notes,
      orderedAt: orderedAt,
      receivedAt: receivedAt,
      employeeId: employeeId,
    );
  }

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  bool get isPending => status == PurchaseOrderStatus.pending;
  bool get isReceived => status == PurchaseOrderStatus.received;
  bool get isPartial => status == PurchaseOrderStatus.partial;
  bool get isCancelled => status == PurchaseOrderStatus.cancelled;

  /// Number of distinct product lines in the order.
  int get lineCount => items.length;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Pass [clearReceivedAt] = true to explicitly null out [receivedAt].
  PurchaseOrder copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    List<PurchaseOrderItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    PurchaseOrderStatus? status,
    String? notes,
    DateTime? orderedAt,
    DateTime? receivedAt,
    String? employeeId,
    bool clearReceivedAt = false,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      orderedAt: orderedAt ?? this.orderedAt,
      receivedAt:
          clearReceivedAt ? null : (receivedAt ?? this.receivedAt),
      employeeId: employeeId ?? this.employeeId,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status.value,
      'notes': notes,
      'orderedAt': orderedAt.toIso8601String(),
      'receivedAt': receivedAt?.toIso8601String(),
      'employeeId': employeeId,
    };
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: PurchaseOrderStatusExtension.fromString(
          json['status'] as String),
      notes: json['notes'] as String,
      orderedAt: DateTime.parse(json['orderedAt'] as String),
      receivedAt: json['receivedAt'] != null
          ? DateTime.parse(json['receivedAt'] as String)
          : null,
      employeeId: json['employeeId'] as String,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PurchaseOrder) return false;
    if (other.id != id ||
        other.supplierId != supplierId ||
        other.supplierName != supplierName ||
        other.subtotal != subtotal ||
        other.tax != tax ||
        other.total != total ||
        other.status != status ||
        other.notes != notes ||
        other.orderedAt != orderedAt ||
        other.receivedAt != receivedAt ||
        other.employeeId != employeeId) return false;
    if (other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      supplierId,
      supplierName,
      ...items,
      subtotal,
      tax,
      total,
      status,
      notes,
      orderedAt,
      receivedAt,
      employeeId,
    ]);
  }

  @override
  String toString() {
    return 'PurchaseOrder(id: $id, supplierName: $supplierName, '
        'items: ${items.length}, total: $total, '
        'status: ${status.value}, orderedAt: $orderedAt)';
  }
}
