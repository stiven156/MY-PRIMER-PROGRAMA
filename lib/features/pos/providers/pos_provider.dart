import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/features/auth/providers/auth_provider.dart';
import 'package:mercados/features/customers/models/customer.dart';
import 'package:mercados/features/inventory/models/product.dart';
import 'package:mercados/features/inventory/providers/inventory_provider.dart';
import 'package:mercados/features/pos/models/cart_item.dart';
import 'package:mercados/features/pos/models/sale.dart';

// ---------------------------------------------------------------------------
// POS State
// ---------------------------------------------------------------------------

class PosState {
  final List<CartItem> items;
  final Customer? selectedCustomer;
  final PaymentMethod paymentMethod;
  final double amountPaid;
  final bool isProcessing;
  final Sale? lastCompletedSale;
  final String? error;

  const PosState({
    this.items = const [],
    this.selectedCustomer,
    this.paymentMethod = PaymentMethod.cash,
    this.amountPaid = 0,
    this.isProcessing = false,
    this.lastCompletedSale,
    this.error,
  });

  // ── Computed totals ────────────────────────────────────────────────────────

  /// Gross subtotal before any discounts.
  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  /// Sum of all per-line discount amounts.
  double get totalDiscount =>
      items.fold(0, (sum, item) => sum + item.discountAmount);

  /// Net taxable base: subtotal minus all discounts.
  double get taxableBase => subtotal - totalDiscount;

  /// IVA at 16 % of the taxable base.
  double get taxAmount => _round2(taxableBase * AppConstants.defaultTaxRate);

  /// Grand total: taxable base + tax.
  double get total => _round2(taxableBase + taxAmount);

  /// Change to return for cash payments.  Zero for card / transfer.
  double get change {
    if (paymentMethod != PaymentMethod.cash) return 0;
    final diff = amountPaid - total;
    return diff < 0 ? 0 : _round2(diff);
  }

  bool get isEmpty => items.isEmpty;
  bool get isReadyToComplete =>
      items.isNotEmpty &&
      !isProcessing &&
      (paymentMethod != PaymentMethod.cash || amountPaid >= total);

  PosState copyWith({
    List<CartItem>? items,
    Customer? selectedCustomer,
    PaymentMethod? paymentMethod,
    double? amountPaid,
    bool? isProcessing,
    Sale? lastCompletedSale,
    String? error,
    bool clearCustomer = false,
    bool clearError = false,
    bool clearLastSale = false,
  }) {
    return PosState(
      items: items ?? this.items,
      selectedCustomer:
          clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      isProcessing: isProcessing ?? this.isProcessing,
      lastCompletedSale: clearLastSale
          ? null
          : (lastCompletedSale ?? this.lastCompletedSale),
      error: clearError ? null : (error ?? this.error),
    );
  }

  double _round2(double v) => (v * 100).roundToDouble() / 100;
}

// ---------------------------------------------------------------------------
// POS StateNotifier
// ---------------------------------------------------------------------------

class PosNotifier extends StateNotifier<PosState> {
  PosNotifier(this._ref) : super(const PosState());

  final Ref _ref;
  final _uuid = const Uuid();
  SupabaseClient? get _client {
    try { return Supabase.instance.client; } catch (_) { return null; }
  }

  // ── Cart mutations ─────────────────────────────────────────────────────────

  /// Adds [product] to the cart. If already present, increments quantity by 1.
  void addProduct(Product product) {
    final idx = state.items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      final existing = state.items[idx];
      // Do not exceed available stock.
      final maxQty = product.stock;
      if (existing.quantity >= maxQty) {
        state = state.copyWith(
          error: 'No hay más stock disponible para "${product.name}".',
        );
        return;
      }
      final updated = [...state.items];
      updated[idx] = existing.copyWith(quantity: existing.quantity + 1);
      state = state.copyWith(items: updated, clearError: true);
    } else {
      if (product.stock <= 0) {
        state = state.copyWith(
          error: '"${product.name}" no tiene stock disponible.',
        );
        return;
      }
      final newItem = CartItem(
        product: product,
        quantity: 1,
        unitPrice: product.salePrice,
      );
      state = state.copyWith(
        items: [...state.items, newItem],
        clearError: true,
      );
    }
  }

  /// Updates the quantity of the item with [productId].
  /// Removes the item if [qty] is zero or less.
  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final idx = state.items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;

    final item = state.items[idx];
    final maxQty = item.product.stock;
    final clamped = qty > maxQty ? maxQty : qty.toDouble();

    final updated = [...state.items];
    updated[idx] = item.copyWith(quantity: clamped);
    state = state.copyWith(items: updated, clearError: true);
  }

  /// Removes the item with [productId] from the cart.
  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
      clearError: true,
    );
  }

  /// Applies a [discount] percentage (0–100) to the item with [productId].
  void applyDiscount(String productId, double discount) {
    final idx = state.items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;

    final clamped = discount.clamp(0.0, 100.0);
    final updated = [...state.items];
    updated[idx] = state.items[idx].copyWith(discount: clamped);
    state = state.copyWith(items: updated, clearError: true);
  }

  // ── Customer / payment ────────────────────────────────────────────────────

  void setCustomer(Customer? customer) {
    state = state.copyWith(
      selectedCustomer: customer,
      clearCustomer: customer == null,
    );
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(
      paymentMethod: method,
      // Reset amountPaid when switching away from cash.
      amountPaid: method != PaymentMethod.cash ? state.total : state.amountPaid,
    );
  }

  void setAmountPaid(double amount) {
    state = state.copyWith(amountPaid: amount < 0 ? 0 : amount);
  }

  // ── Complete sale ─────────────────────────────────────────────────────────

  /// Processes the current cart and persists the sale to Supabase.
  /// Returns the completed [Sale] on success.
  Future<Sale> completeSale() async {
    if (state.isEmpty) {
      throw StateError('El carrito está vacío.');
    }
    if (state.paymentMethod == PaymentMethod.cash &&
        state.amountPaid < state.total) {
      throw StateError('El monto recibido es insuficiente.');
    }

    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final authState = _ref.read(authProvider);
      final currentUser = authState.currentUser;
      if (currentUser == null) throw StateError('No hay sesión activa.');

      final saleId = _uuid.v4();
      final createdAt = DateTime.now();

      final sale = Sale.fromItems(
        id: saleId,
        items: state.items,
        customerId: state.selectedCustomer?.id,
        customerName: state.selectedCustomer?.name,
        taxRate: AppConstants.defaultTaxRate * 100, // stored as 16.0
        paymentMethod: state.paymentMethod,
        amountPaid: state.paymentMethod == PaymentMethod.cash
            ? state.amountPaid
            : state.total,
        employeeId: currentUser.id,
        employeeName: currentUser.name,
        createdAt: createdAt,
      );

      // ── Persist to Supabase (skipped in demo mode) ──────────────────────
      final client = _client;
      if (client != null) {
        await client.from(AppConstants.tableSales).insert({
          'id': saleId,
          'customer_id': sale.customerId,
          'customer_name': sale.customerName,
          'subtotal': sale.subtotal,
          'discount_total': sale.discountTotal,
          'tax_rate': sale.taxRate,
          'tax_amount': sale.taxAmount,
          'total': sale.total,
          'payment_method': sale.paymentMethod.value,
          'amount_paid': sale.amountPaid,
          'change': sale.change,
          'employee_id': sale.employeeId,
          'employee_name': sale.employeeName,
          'status': sale.status.value,
          'created_at': createdAt.toIso8601String(),
        });

        // Persist line items.
        if (state.items.isNotEmpty) {
          await client.from(AppConstants.tableSaleItems).insert(
            state.items
                .map((item) => {
                      'id': _uuid.v4(),
                      'sale_id': saleId,
                      'product_id': item.product.id,
                      'product_name': item.product.name,
                      'product_code': item.product.code,
                      'quantity': item.quantity,
                      'unit_price': item.unitPrice,
                      'discount': item.discount,
                      'subtotal': item.subtotal,
                      'total': item.total,
                    })
                .toList(),
          );
        }

        // Decrement stock in inventory.
        for (final item in state.items) {
          await _ref
              .read(inventoryProvider.notifier)
              .adjustStock(item.product.id, -item.quantity.toInt(), 'Venta $saleId');
        }
      }
      // ────────────────────────────────────────────────────────────────────

      state = state.copyWith(
        isProcessing: false,
        lastCompletedSale: sale,
      );
      return sale;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error al procesar la venta: ${e.toString()}',
      );
      rethrow;
    }
  }

  // ── Clear cart ────────────────────────────────────────────────────────────

  void clearCart() {
    state = const PosState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final posProvider = StateNotifierProvider<PosNotifier, PosState>(
  (ref) => PosNotifier(ref),
);

/// Convenience provider: total number of distinct items in the cart.
final cartItemCountProvider = Provider<int>(
  (ref) => ref.watch(posProvider).items.length,
);

/// Convenience provider: cart grand total.
final cartTotalProvider = Provider<double>(
  (ref) => ref.watch(posProvider).total,
);
