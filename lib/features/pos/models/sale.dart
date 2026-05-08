import 'package:mercados/features/pos/models/cart_item.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum PaymentMethod { cash, card, transfer, mixed }

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.transfer:
        return 'Transferencia';
      case PaymentMethod.mixed:
        return 'Mixto';
    }
  }

  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.transfer:
        return 'transfer';
      case PaymentMethod.mixed:
        return 'mixed';
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'transfer':
        return PaymentMethod.transfer;
      case 'mixed':
        return PaymentMethod.mixed;
      default:
        throw ArgumentError('Unknown PaymentMethod: "$value"');
    }
  }
}

enum SaleStatus { completed, cancelled, refunded }

extension SaleStatusExtension on SaleStatus {
  String get displayName {
    switch (this) {
      case SaleStatus.completed:
        return 'Completada';
      case SaleStatus.cancelled:
        return 'Cancelada';
      case SaleStatus.refunded:
        return 'Reembolsada';
    }
  }

  String get value {
    switch (this) {
      case SaleStatus.completed:
        return 'completed';
      case SaleStatus.cancelled:
        return 'cancelled';
      case SaleStatus.refunded:
        return 'refunded';
    }
  }

  static SaleStatus fromString(String value) {
    switch (value) {
      case 'completed':
        return SaleStatus.completed;
      case 'cancelled':
        return SaleStatus.cancelled;
      case 'refunded':
        return SaleStatus.refunded;
      default:
        throw ArgumentError('Unknown SaleStatus: "$value"');
    }
  }
}

// ---------------------------------------------------------------------------
// Sale
// ---------------------------------------------------------------------------

class Sale {
  final String id;
  final List<CartItem> items;

  /// Optional customer reference. Null for anonymous walk-in sales.
  final String? customerId;
  final String? customerName;

  /// Sum of all line-item subtotals (gross, before any discounts).
  final double subtotal;

  /// Total monetary discount across all line items.
  final double discountTotal;

  /// Tax rate as a percentage, e.g. 16.0 for 16 %.
  final double taxRate;

  /// Tax amount in currency units. Stored so the record is self-contained.
  final double taxAmount;

  /// Grand total: (subtotal − discountTotal) + taxAmount.
  final double total;

  final PaymentMethod paymentMethod;

  /// Amount of money handed over by the customer.
  final double amountPaid;

  /// Cash change returned to the customer (amountPaid − total).
  /// May be negative or zero for card / transfer payments.
  final double change;

  final String employeeId;
  final String employeeName;
  final DateTime createdAt;
  final SaleStatus status;

  const Sale({
    required this.id,
    required this.items,
    this.customerId,
    this.customerName,
    required this.subtotal,
    required this.discountTotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    required this.employeeId,
    required this.employeeName,
    required this.createdAt,
    required this.status,
  });

  // ---------------------------------------------------------------------------
  // Convenience factory — recalculates all totals from the item list.
  // ---------------------------------------------------------------------------

  factory Sale.fromItems({
    required String id,
    required List<CartItem> items,
    String? customerId,
    String? customerName,
    required double taxRate,
    required PaymentMethod paymentMethod,
    required double amountPaid,
    required String employeeId,
    required String employeeName,
    required DateTime createdAt,
    SaleStatus status = SaleStatus.completed,
  }) {
    final subtotal =
        items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final discountTotal =
        items.fold<double>(0, (sum, item) => sum + item.discountAmount);
    final taxableAmount = subtotal - discountTotal;
    final taxAmount = taxableAmount * (taxRate / 100);
    final total = taxableAmount + taxAmount;
    final change = amountPaid - total;

    return Sale(
      id: id,
      items: items,
      customerId: customerId,
      customerName: customerName,
      subtotal: subtotal,
      discountTotal: discountTotal,
      taxRate: taxRate,
      taxAmount: taxAmount,
      total: total,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      change: change,
      employeeId: employeeId,
      employeeName: employeeName,
      createdAt: createdAt,
      status: status,
    );
  }

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// Taxable net amount: subtotal minus all discounts, before tax.
  double get netAmount => subtotal - discountTotal;

  /// Total number of individual units sold across all line items.
  double get totalUnits =>
      items.fold<double>(0, (sum, item) => sum + item.quantity);

  /// Number of distinct product lines in this sale.
  int get lineCount => items.length;

  bool get isCompleted => status == SaleStatus.completed;
  bool get isCancelled => status == SaleStatus.cancelled;
  bool get isRefunded => status == SaleStatus.refunded;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Pass [clearCustomer] = true to remove the customer association entirely.
  Sale copyWith({
    String? id,
    List<CartItem>? items,
    String? customerId,
    String? customerName,
    double? subtotal,
    double? discountTotal,
    double? taxRate,
    double? taxAmount,
    double? total,
    PaymentMethod? paymentMethod,
    double? amountPaid,
    double? change,
    String? employeeId,
    String? employeeName,
    DateTime? createdAt,
    SaleStatus? status,
    bool clearCustomer = false,
  }) {
    return Sale(
      id: id ?? this.id,
      items: items ?? this.items,
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      customerName:
          clearCustomer ? null : (customerName ?? this.customerName),
      subtotal: subtotal ?? this.subtotal,
      discountTotal: discountTotal ?? this.discountTotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      change: change ?? this.change,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((i) => i.toJson()).toList(),
      'customerId': customerId,
      'customerName': customerName,
      'subtotal': subtotal,
      'discountTotal': discountTotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'paymentMethod': paymentMethod.value,
      'amountPaid': amountPaid,
      'change': change,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'createdAt': createdAt.toIso8601String(),
      'status': status.value,
    };
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      discountTotal: (json['discountTotal'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      paymentMethod:
          PaymentMethodExtension.fromString(json['paymentMethod'] as String),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: SaleStatusExtension.fromString(json['status'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Sale) return false;
    if (other.id != id ||
        other.customerId != customerId ||
        other.customerName != customerName ||
        other.subtotal != subtotal ||
        other.discountTotal != discountTotal ||
        other.taxRate != taxRate ||
        other.taxAmount != taxAmount ||
        other.total != total ||
        other.paymentMethod != paymentMethod ||
        other.amountPaid != amountPaid ||
        other.change != change ||
        other.employeeId != employeeId ||
        other.employeeName != employeeName ||
        other.createdAt != createdAt ||
        other.status != status) return false;
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
      ...items,
      customerId,
      customerName,
      subtotal,
      discountTotal,
      taxRate,
      taxAmount,
      total,
      paymentMethod,
      amountPaid,
      change,
      employeeId,
      employeeName,
      createdAt,
      status,
    ]);
  }

  @override
  String toString() {
    return 'Sale(id: $id, items: ${items.length}, total: $total, '
        'paymentMethod: ${paymentMethod.value}, status: ${status.value}, '
        'createdAt: $createdAt)';
  }
}
