// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum OrderType { delivery, pickup }

extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.delivery:
        return 'Domicilio';
      case OrderType.pickup:
        return 'Recoger en tienda';
    }
  }

  String get value {
    switch (this) {
      case OrderType.delivery:
        return 'delivery';
      case OrderType.pickup:
        return 'pickup';
    }
  }

  static OrderType fromString(String value) {
    switch (value) {
      case 'delivery':
        return OrderType.delivery;
      case 'pickup':
        return OrderType.pickup;
      default:
        throw ArgumentError('Unknown OrderType: "$value"');
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  onTheWay,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.onTheWay:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.onTheWay:
        return 'onTheWay';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'onTheWay':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        throw ArgumentError('Unknown OrderStatus: "$value"');
    }
  }
}

enum OrderPaymentMethod { cashOnDelivery, transfer, card }

extension OrderPaymentMethodExtension on OrderPaymentMethod {
  String get displayName {
    switch (this) {
      case OrderPaymentMethod.cashOnDelivery:
        return 'Contra entrega';
      case OrderPaymentMethod.transfer:
        return 'Transferencia';
      case OrderPaymentMethod.card:
        return 'Tarjeta';
    }
  }

  String get value {
    switch (this) {
      case OrderPaymentMethod.cashOnDelivery:
        return 'cashOnDelivery';
      case OrderPaymentMethod.transfer:
        return 'transfer';
      case OrderPaymentMethod.card:
        return 'card';
    }
  }

  static OrderPaymentMethod fromString(String value) {
    switch (value) {
      case 'cashOnDelivery':
        return OrderPaymentMethod.cashOnDelivery;
      case 'transfer':
        return OrderPaymentMethod.transfer;
      case 'card':
        return OrderPaymentMethod.card;
      default:
        throw ArgumentError('Unknown OrderPaymentMethod: "$value"');
    }
  }
}

// ---------------------------------------------------------------------------
// OrderItem
// ---------------------------------------------------------------------------

class OrderItem {
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;

  /// Line total: quantity × unitPrice.
  final double total;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  /// Convenience factory that calculates [total] automatically.
  factory OrderItem.create({
    required String productId,
    required String productName,
    required double quantity,
    required double unitPrice,
  }) {
    return OrderItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      total: quantity * unitPrice,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// When [quantity] or [unitPrice] changes but no explicit [total] is
  /// supplied, total is recalculated automatically.
  OrderItem copyWith({
    String? productId,
    String? productName,
    double? quantity,
    double? unitPrice,
    double? total,
  }) {
    final newQuantity = quantity ?? this.quantity;
    final newPrice = unitPrice ?? this.unitPrice;
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: newQuantity,
      unitPrice: newPrice,
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
      'unitPrice': unitPrice,
      'total': total,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem &&
        other.productId == productId &&
        other.productName == productName &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice &&
        other.total == total;
  }

  @override
  int get hashCode =>
      Object.hash(productId, productName, quantity, unitPrice, total);

  @override
  String toString() {
    return 'OrderItem(productId: $productId, productName: $productName, '
        'quantity: $quantity, unitPrice: $unitPrice, total: $total)';
  }
}

// ---------------------------------------------------------------------------
// Order
// ---------------------------------------------------------------------------

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<OrderItem> items;

  /// Sum of all item totals before delivery fee.
  final double subtotal;

  /// Delivery charge applied to [OrderType.delivery] orders.
  /// Should be 0 for [OrderType.pickup] orders.
  final double deliveryFee;

  /// Grand total: subtotal + deliveryFee.
  final double total;

  final OrderType type;
  final OrderStatus status;
  final OrderPaymentMethod paymentMethod;

  /// Optional customer instructions (e.g. "leave at door").
  final String? notes;

  final DateTime createdAt;

  /// Set when the order transitions to [OrderStatus.confirmed].
  final DateTime? confirmedAt;

  /// Set when the order transitions to [OrderStatus.delivered].
  final DateTime? deliveredAt;

  /// Estimated minutes until delivery or pickup is ready.
  final int? estimatedMinutes;

  /// Employee assigned to deliver the order. Null until dispatched.
  final String? deliveryPersonId;
  final String? deliveryPersonName;

  const Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.type,
    required this.status,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.confirmedAt,
    this.deliveredAt,
    this.estimatedMinutes,
    this.deliveryPersonId,
    this.deliveryPersonName,
  });

  // ---------------------------------------------------------------------------
  // Convenience factory — derives subtotal and total from the item list.
  // ---------------------------------------------------------------------------

  factory Order.fromItems({
    required String id,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required List<OrderItem> items,
    required double deliveryFee,
    required OrderType type,
    OrderStatus status = OrderStatus.pending,
    required OrderPaymentMethod paymentMethod,
    String? notes,
    required DateTime createdAt,
    DateTime? confirmedAt,
    DateTime? deliveredAt,
    int? estimatedMinutes,
    String? deliveryPersonId,
    String? deliveryPersonName,
  }) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    final total = subtotal + deliveryFee;

    return Order(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      type: type,
      status: status,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: createdAt,
      confirmedAt: confirmedAt,
      deliveredAt: deliveredAt,
      estimatedMinutes: estimatedMinutes,
      deliveryPersonId: deliveryPersonId,
      deliveryPersonName: deliveryPersonName,
    );
  }

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  bool get isPending => status == OrderStatus.pending;
  bool get isConfirmed => status == OrderStatus.confirmed;
  bool get isPreparing => status == OrderStatus.preparing;
  bool get isReady => status == OrderStatus.ready;
  bool get isOnTheWay => status == OrderStatus.onTheWay;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;

  bool get isDelivery => type == OrderType.delivery;
  bool get isPickup => type == OrderType.pickup;

  /// Number of distinct product lines in this order.
  int get lineCount => items.length;

  /// Total number of individual units across all line items.
  double get totalUnits =>
      items.fold<double>(0, (sum, item) => sum + item.quantity);

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderType? type,
    OrderStatus? status,
    OrderPaymentMethod? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? deliveredAt,
    int? estimatedMinutes,
    String? deliveryPersonId,
    String? deliveryPersonName,
    bool clearNotes = false,
    bool clearConfirmedAt = false,
    bool clearDeliveredAt = false,
    bool clearEstimatedMinutes = false,
    bool clearDeliveryPerson = false,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      confirmedAt:
          clearConfirmedAt ? null : (confirmedAt ?? this.confirmedAt),
      deliveredAt:
          clearDeliveredAt ? null : (deliveredAt ?? this.deliveredAt),
      estimatedMinutes: clearEstimatedMinutes
          ? null
          : (estimatedMinutes ?? this.estimatedMinutes),
      deliveryPersonId: clearDeliveryPerson
          ? null
          : (deliveryPersonId ?? this.deliveryPersonId),
      deliveryPersonName: clearDeliveryPerson
          ? null
          : (deliveryPersonName ?? this.deliveryPersonName),
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'type': type.value,
      'status': status.value,
      'paymentMethod': paymentMethod.value,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'deliveryPersonId': deliveryPersonId,
      'deliveryPersonName': deliveryPersonName,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      customerAddress: json['customerAddress'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      type: OrderTypeExtension.fromString(json['type'] as String),
      status: OrderStatusExtension.fromString(json['status'] as String),
      paymentMethod: OrderPaymentMethodExtension.fromString(
          json['paymentMethod'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      estimatedMinutes: json['estimatedMinutes'] as int?,
      deliveryPersonId: json['deliveryPersonId'] as String?,
      deliveryPersonName: json['deliveryPersonName'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Order) return false;
    if (other.id != id ||
        other.customerId != customerId ||
        other.customerName != customerName ||
        other.customerPhone != customerPhone ||
        other.customerAddress != customerAddress ||
        other.subtotal != subtotal ||
        other.deliveryFee != deliveryFee ||
        other.total != total ||
        other.type != type ||
        other.status != status ||
        other.paymentMethod != paymentMethod ||
        other.notes != notes ||
        other.createdAt != createdAt ||
        other.confirmedAt != confirmedAt ||
        other.deliveredAt != deliveredAt ||
        other.estimatedMinutes != estimatedMinutes ||
        other.deliveryPersonId != deliveryPersonId ||
        other.deliveryPersonName != deliveryPersonName) return false;
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
      customerId,
      customerName,
      customerPhone,
      customerAddress,
      ...items,
      subtotal,
      deliveryFee,
      total,
      type,
      status,
      paymentMethod,
      notes,
      createdAt,
      confirmedAt,
      deliveredAt,
      estimatedMinutes,
      deliveryPersonId,
      deliveryPersonName,
    ]);
  }

  @override
  String toString() {
    return 'Order(id: $id, customerName: $customerName, '
        'items: ${items.length}, total: $total, '
        'type: ${type.value}, status: ${status.value}, '
        'createdAt: $createdAt)';
  }
}
