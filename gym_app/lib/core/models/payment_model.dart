import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  bankTransfer,
  qrCode,
  paypal,
  other;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.qrCode:
        return 'QR Code';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

enum PaymentStatus {
  completed,
  pending,
  overdue,
  refunded,
  cancelled;

  String get displayName {
    switch (this) {
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.overdue:
        return 'Overdue';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

// ---------------------------------------------------------------------------
// Payment
// ---------------------------------------------------------------------------

@immutable
class Payment {
  final String id;
  final String memberId;
  final String memberName;
  final String gymId;
  final double amount;
  final DateTime date;
  final String membershipPlanId;
  final String membershipPlanName;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? notes;
  final String receiptNumber;
  final DateTime? dueDate;
  final String currency;

  const Payment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.gymId,
    required this.amount,
    required this.date,
    required this.membershipPlanId,
    required this.membershipPlanName,
    required this.method,
    required this.status,
    this.notes,
    required this.receiptNumber,
    this.dueDate,
    this.currency = 'USD',
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  bool get isOverdue {
    if (dueDate == null) return false;
    return status == PaymentStatus.pending &&
        dueDate!.isBefore(DateTime.now());
  }

  String get formattedAmount => '${currency} ${amount.toStringAsFixed(2)}';

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'gymId': gymId,
      'amount': amount,
      'date': date.toIso8601String(),
      'membershipPlanId': membershipPlanId,
      'membershipPlanName': membershipPlanName,
      'method': method.name,
      'status': status.name,
      'notes': notes,
      'receiptNumber': receiptNumber,
      'dueDate': dueDate?.toIso8601String(),
      'currency': currency,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      gymId: json['gymId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      membershipPlanId: json['membershipPlanId'] as String,
      membershipPlanName: json['membershipPlanName'] as String,
      method:
          PaymentMethod.fromString(json['method'] as String? ?? 'cash'),
      status:
          PaymentStatus.fromString(json['status'] as String? ?? 'pending'),
      notes: json['notes'] as String?,
      receiptNumber: json['receiptNumber'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Payment copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? gymId,
    double? amount,
    DateTime? date,
    String? membershipPlanId,
    String? membershipPlanName,
    PaymentMethod? method,
    PaymentStatus? status,
    String? notes,
    String? receiptNumber,
    DateTime? dueDate,
    String? currency,
    bool clearNotes = false,
    bool clearDueDate = false,
  }) {
    return Payment(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      gymId: gymId ?? this.gymId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      membershipPlanId: membershipPlanId ?? this.membershipPlanId,
      membershipPlanName: membershipPlanName ?? this.membershipPlanName,
      method: method ?? this.method,
      status: status ?? this.status,
      notes: clearNotes ? null : (notes ?? this.notes),
      receiptNumber: receiptNumber ?? this.receiptNumber,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      currency: currency ?? this.currency,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Payment(id: $id, amount: $formattedAmount, status: ${status.name})';
}
