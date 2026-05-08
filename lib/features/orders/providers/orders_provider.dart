import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum OrderStatus {
  pending,
  preparing,
  onTheWay,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.preparing:
        return 'En Preparación';
      case OrderStatus.onTheWay:
        return 'En Camino';
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
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.onTheWay:
        return 'on_the_way';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String v) {
    switch (v) {
      case 'pending':
        return OrderStatus.pending;
      case 'preparing':
        return OrderStatus.preparing;
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Returns the logically next status (null if terminal).
  OrderStatus? get next {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.onTheWay;
      case OrderStatus.onTheWay:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }

  bool get isTerminal =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;
}

enum OrderType { delivery, pickup }

extension OrderTypeExtension on OrderType {
  String get displayName =>
      this == OrderType.delivery ? 'Domicilio' : 'Recoger en tienda';
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final OrderStatus status;
  final OrderType type;
  final String? deliveryAddress;
  final String? deliveryPersonId;
  final String? deliveryPersonName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final double deliveryFee;
  final double discount;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.status,
    required this.type,
    this.deliveryAddress,
    this.deliveryPersonId,
    this.deliveryPersonName,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.deliveryFee = 0,
    this.discount = 0,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  double get total => subtotal + deliveryFee - discount;

  String get itemsSummary {
    if (items.isEmpty) return '';
    if (items.length == 1) {
      return '${items[0].quantity}x ${items[0].productName}';
    }
    final first = '${items[0].quantity}x ${items[0].productName}';
    return '$first +${items.length - 1} más';
  }

  Duration get elapsed => DateTime.now().difference(createdAt);

  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    OrderStatus? status,
    OrderType? type,
    String? deliveryAddress,
    String? deliveryPersonId,
    String? deliveryPersonName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    double? deliveryFee,
    double? discount,
    bool clearDeliveryPerson = false,
    bool clearAddress = false,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      status: status ?? this.status,
      type: type ?? this.type,
      deliveryAddress:
          clearAddress ? null : (deliveryAddress ?? this.deliveryAddress),
      deliveryPersonId: clearDeliveryPerson
          ? null
          : (deliveryPersonId ?? this.deliveryPersonId),
      deliveryPersonName: clearDeliveryPerson
          ? null
          : (deliveryPersonName ?? this.deliveryPersonName),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
    );
  }
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final OrderStatus? filterStatus;
  final DateTime lastRefresh;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.filterStatus,
    required this.lastRefresh,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    OrderStatus? filterStatus,
    bool clearFilter = false,
    DateTime? lastRefresh,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      filterStatus:
          clearFilter ? null : (filterStatus ?? this.filterStatus),
      lastRefresh: lastRefresh ?? this.lastRefresh,
    );
  }

  List<Order> get pendingOrders =>
      orders.where((o) => o.status == OrderStatus.pending).toList();

  List<Order> get activeOrders => orders
      .where((o) =>
          o.status == OrderStatus.preparing ||
          o.status == OrderStatus.onTheWay)
      .toList();

  List<Order> get completedOrders => orders
      .where((o) =>
          o.status == OrderStatus.delivered ||
          o.status == OrderStatus.cancelled)
      .toList();

  List<Order> get filteredOrders {
    if (filterStatus == null) return orders;
    return orders.where((o) => o.status == filterStatus).toList();
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

int _orderCounter = 12;

List<Order> _buildSampleOrders() {
  final now = DateTime.now();
  return [
    Order(
      id: 'ord-001',
      orderNumber: '#0001',
      customerId: 'cust-001',
      customerName: 'Laura Pérez',
      customerPhone: '+51 987 001 111',
      items: const [
        OrderItem(
            productId: 'prod-001',
            productName: 'Coca-Cola 600ml',
            quantity: 3,
            unitPrice: 14.00),
        OrderItem(
            productId: 'prod-003',
            productName: 'Leche Entera 1L',
            quantity: 2,
            unitPrice: 24.00),
      ],
      status: OrderStatus.pending,
      type: OrderType.delivery,
      deliveryAddress: 'Av. Arequipa 1234, Lima',
      createdAt: now.subtract(const Duration(minutes: 8)),
      updatedAt: now.subtract(const Duration(minutes: 8)),
      deliveryFee: 5.00,
    ),
    Order(
      id: 'ord-002',
      orderNumber: '#0002',
      customerId: 'cust-002',
      customerName: 'Roberto Quispe',
      customerPhone: '+51 987 002 222',
      items: const [
        OrderItem(
            productId: 'prod-005',
            productName: 'Pan Blanco 680g',
            quantity: 1,
            unitPrice: 32.00),
        OrderItem(
            productId: 'prod-007',
            productName: 'Manzana Roja 1kg',
            quantity: 2,
            unitPrice: 39.00),
        OrderItem(
            productId: 'prod-011',
            productName: 'Shampoo 400ml',
            quantity: 1,
            unitPrice: 55.00),
      ],
      status: OrderStatus.preparing,
      type: OrderType.delivery,
      deliveryAddress: 'Jr. Lampa 456, Cercado',
      deliveryPersonId: 'emp-004',
      deliveryPersonName: 'Ana Torres',
      createdAt: now.subtract(const Duration(minutes: 25)),
      updatedAt: now.subtract(const Duration(minutes: 10)),
      deliveryFee: 5.00,
    ),
    Order(
      id: 'ord-003',
      orderNumber: '#0003',
      customerId: 'cust-003',
      customerName: 'Carmen Salinas',
      customerPhone: '+51 987 003 333',
      items: const [
        OrderItem(
            productId: 'prod-009',
            productName: 'Detergente Líquido 1L',
            quantity: 2,
            unitPrice: 48.00),
        OrderItem(
            productId: 'prod-010',
            productName: 'Cloro 1L',
            quantity: 1,
            unitPrice: 22.00),
      ],
      status: OrderStatus.onTheWay,
      type: OrderType.delivery,
      deliveryAddress: 'Calle Los Pinos 789, Miraflores',
      deliveryPersonId: 'emp-004',
      deliveryPersonName: 'Ana Torres',
      createdAt: now.subtract(const Duration(minutes: 55)),
      updatedAt: now.subtract(const Duration(minutes: 5)),
      deliveryFee: 5.00,
    ),
    Order(
      id: 'ord-004',
      orderNumber: '#0004',
      customerId: 'cust-004',
      customerName: 'Diego Vargas',
      customerPhone: '+51 987 004 444',
      items: const [
        OrderItem(
            productId: 'prod-020',
            productName: 'Café Molido 500g',
            quantity: 1,
            unitPrice: 98.00),
        OrderItem(
            productId: 'prod-003',
            productName: 'Leche Entera 1L',
            quantity: 3,
            unitPrice: 24.00),
      ],
      status: OrderStatus.delivered,
      type: OrderType.pickup,
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(minutes: 30)),
    ),
    Order(
      id: 'ord-005',
      orderNumber: '#0005',
      customerId: 'cust-005',
      customerName: 'Sofía Mendoza',
      customerPhone: '+51 987 005 555',
      items: const [
        OrderItem(
            productId: 'prod-015',
            productName: 'Queso Manchego 400g',
            quantity: 2,
            unitPrice: 78.00),
        OrderItem(
            productId: 'prod-016',
            productName: 'Galletas de Avena 420g',
            quantity: 3,
            unitPrice: 42.00),
      ],
      status: OrderStatus.pending,
      type: OrderType.pickup,
      createdAt: now.subtract(const Duration(minutes: 3)),
      updatedAt: now.subtract(const Duration(minutes: 3)),
    ),
    Order(
      id: 'ord-006',
      orderNumber: '#0006',
      customerId: 'cust-006',
      customerName: 'Héctor Ramos',
      customerPhone: '+51 987 006 666',
      items: const [
        OrderItem(
            productId: 'prod-006',
            productName: 'Pechuga de Pollo 1kg',
            quantity: 2,
            unitPrice: 95.00),
        OrderItem(
            productId: 'prod-013',
            productName: 'Arroz Blanco 1kg',
            quantity: 3,
            unitPrice: 26.00),
        OrderItem(
            productId: 'prod-001',
            productName: 'Coca-Cola 600ml',
            quantity: 4,
            unitPrice: 14.00),
      ],
      status: OrderStatus.cancelled,
      type: OrderType.delivery,
      deliveryAddress: 'Av. Brasil 321, Pueblo Libre',
      createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
      updatedAt: now.subtract(const Duration(hours: 1)),
      deliveryFee: 5.00,
    ),
  ];
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class OrdersNotifier extends StateNotifier<OrdersState> {
  OrdersNotifier()
      : super(OrdersState(lastRefresh: DateTime.now())) {
    loadOrders();
    _startAutoRefresh();
  }

  final _uuid = const Uuid();
  Timer? _refreshTimer;

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // Simulate occasional new incoming order.
      if (!mounted) return;
      state = state.copyWith(lastRefresh: DateTime.now());
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // TODO(supabase): replace with real-time subscription
    state = state.copyWith(
      orders: _buildSampleOrders(),
      isLoading: false,
      lastRefresh: DateTime.now(),
    );
  }

  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    final idx = state.orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final updated = List<Order>.from(state.orders);
    updated[idx] = updated[idx].copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    // TODO(supabase): await supabase.from('orders').update({'status': newStatus.value}).eq('id', orderId);
    state = state.copyWith(orders: updated);
  }

  Future<void> assignDelivery(
    String orderId,
    String deliveryPersonId,
    String deliveryPersonName,
  ) async {
    final idx = state.orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final updated = List<Order>.from(state.orders);
    updated[idx] = updated[idx].copyWith(
      deliveryPersonId: deliveryPersonId,
      deliveryPersonName: deliveryPersonName,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(orders: updated);
  }

  Future<void> cancelOrder(String orderId) async {
    await updateStatus(orderId, OrderStatus.cancelled);
  }

  void setFilter(OrderStatus? status) {
    state = state.copyWith(
      filterStatus: status,
      clearFilter: status == null,
    );
  }

  /// Adds a new order (used by the client app).
  Future<Order> placeOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required List<OrderItem> items,
    required OrderType type,
    String? deliveryAddress,
    String? notes,
    double deliveryFee = 0,
  }) async {
    _orderCounter++;
    final order = Order(
      id: _uuid.v4(),
      orderNumber: '#${_orderCounter.toString().padLeft(4, '0')}',
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      status: OrderStatus.pending,
      type: type,
      deliveryAddress: deliveryAddress,
      notes: notes,
      deliveryFee: deliveryFee,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(orders: [order, ...state.orders]);
    return order;
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>(
  (ref) => OrdersNotifier(),
);

final pendingOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider).pendingOrders;
});

final activeOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider).activeOrders;
});

final completedOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider).completedOrders;
});
