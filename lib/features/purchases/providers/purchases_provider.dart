import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mercados/features/purchases/models/purchase_order.dart';
import 'package:mercados/features/purchases/models/supplier.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PurchasesState {
  final List<Supplier> suppliers;
  final List<PurchaseOrder> orders;
  final bool isLoading;
  final String? error;

  const PurchasesState({
    this.suppliers = const [],
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  PurchasesState copyWith({
    List<Supplier>? suppliers,
    List<PurchaseOrder>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PurchasesState(
      suppliers: suppliers ?? this.suppliers,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

final _now = DateTime.now();

List<Supplier> _buildSampleSuppliers() {
  return [
    Supplier(
      id: 'sup-001',
      name: 'Distribuidora Bepensa S.A.',
      contactName: 'Roberto Salas',
      phone: '+52 999 234 5678',
      email: 'ventas@bepensa.mx',
      address: 'Av. Periférico Sur 1024, Mérida, Yucatán',
      taxId: 'DBE850312ABC',
      notes: 'Principal distribuidor de bebidas. Entrega los martes y viernes.',
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 365)),
    ),
    Supplier(
      id: 'sup-002',
      name: 'Lácteos del Norte S.C.',
      contactName: 'María Guzmán',
      phone: '+52 811 456 7890',
      email: 'm.guzman@lacteosn.com',
      address: 'Carr. Monterrey-Laredo Km 12, Monterrey, N.L.',
      taxId: 'LNO920615XYZ',
      notes: 'Proveedor de leche, quesos y derivados. Requiere refrigeración.',
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 300)),
    ),
    Supplier(
      id: 'sup-003',
      name: 'Grupo Bimbo S.A.B. de C.V.',
      contactName: 'Agente Comercial Regional',
      phone: '+52 55 5268 2000',
      email: 'clientes@bimbo.com.mx',
      address: 'Prolongación Paseo de la Reforma 1000, CDMX',
      taxId: 'GBI920208911',
      notes: 'Entrega diaria de pan y pasteles.',
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 280)),
    ),
    Supplier(
      id: 'sup-004',
      name: 'Carnes Selectas Hermanos Ríos',
      contactName: 'Felipe Ríos',
      phone: '+52 442 312 4567',
      email: 'frios@carnesrios.com',
      address: 'Mercado de Abastos Local 34, Querétaro, Qro.',
      taxId: 'CSH780910JKL',
      notes: 'Carnes frescas. Pago de contado. Entrega lunes, miércoles y viernes.',
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 200)),
    ),
    Supplier(
      id: 'sup-005',
      name: 'Procter & Gamble de México',
      contactName: 'Lic. Sandra Vidal',
      phone: '+52 55 5002 7000',
      email: 's.vidal@pg.com',
      address: 'Blvd. Manuel Ávila Camacho 36, Tlalnepantla, Edo. Méx.',
      taxId: 'PGM920101MNO',
      notes: 'Productos de limpieza e higiene personal. Crédito 30 días.',
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 400)),
    ),
    Supplier(
      id: 'sup-006',
      name: 'Comercializadora Frutas del Campo',
      contactName: 'Don Pedro Alcántara',
      phone: '+52 777 890 1234',
      email: 'pedroalcantara@frutasdcampo.com',
      address: 'Central de Abastos Nave E-22, Cuernavaca, Mor.',
      taxId: 'CFC010605PQR',
      notes: 'Frutas y verduras de temporada. Entrega cada dos días. Precio según mercado.',
      isActive: false,
      createdAt: _now.subtract(const Duration(days: 150)),
    ),
  ];
}

List<PurchaseOrder> _buildSampleOrders(List<Supplier> suppliers) {
  final sup1 = suppliers.firstWhere((s) => s.id == 'sup-001');
  final sup2 = suppliers.firstWhere((s) => s.id == 'sup-002');
  final sup3 = suppliers.firstWhere((s) => s.id == 'sup-003');
  final sup4 = suppliers.firstWhere((s) => s.id == 'sup-004');

  return [
    PurchaseOrder.fromItems(
      id: 'ord-001',
      supplierId: sup1.id,
      supplierName: sup1.name,
      items: [
        PurchaseOrderItem.create(
          productId: 'prod-001',
          productName: 'Coca-Cola 600ml',
          quantity: 200,
          purchasePrice: 8.50,
        ),
        PurchaseOrderItem.create(
          productId: 'prod-002',
          productName: 'Agua Natural 1.5L',
          quantity: 150,
          purchasePrice: 5.00,
        ),
        PurchaseOrderItem.create(
          productId: 'prod-014',
          productName: 'Jugo de Naranja 1L',
          quantity: 80,
          purchasePrice: 22.00,
        ),
      ],
      taxRate: 16,
      status: PurchaseOrderStatus.received,
      notes: 'Pedido quincenal bebidas. Todo recibido conforme.',
      orderedAt: _now.subtract(const Duration(days: 10)),
      receivedAt: _now.subtract(const Duration(days: 8)),
      employeeId: 'emp-001',
    ),
    PurchaseOrder.fromItems(
      id: 'ord-002',
      supplierId: sup2.id,
      supplierName: sup2.name,
      items: [
        PurchaseOrderItem.create(
          productId: 'prod-003',
          productName: 'Leche Entera 1L',
          quantity: 100,
          purchasePrice: 18.00,
        ),
        PurchaseOrderItem.create(
          productId: 'prod-004',
          productName: 'Yogurt Natural 1kg',
          quantity: 40,
          purchasePrice: 35.00,
        ),
        PurchaseOrderItem.create(
          productId: 'prod-015',
          productName: 'Queso Manchego 400g',
          quantity: 30,
          purchasePrice: 55.00,
        ),
      ],
      taxRate: 0,
      status: PurchaseOrderStatus.pending,
      notes: 'Reponer stock de lácteos urgente. Verificar temperatura en recepción.',
      orderedAt: _now.subtract(const Duration(days: 1)),
      employeeId: 'emp-001',
    ),
    PurchaseOrder.fromItems(
      id: 'ord-003',
      supplierId: sup3.id,
      supplierName: sup3.name,
      items: [
        PurchaseOrderItem.create(
          productId: 'prod-005',
          productName: 'Pan Blanco 680g',
          quantity: 60,
          purchasePrice: 22.00,
        ),
        PurchaseOrderItem.create(
          productId: 'prod-016',
          productName: 'Galletas de Avena 420g',
          quantity: 80,
          purchasePrice: 28.00,
        ),
      ],
      taxRate: 16,
      status: PurchaseOrderStatus.partial,
      notes: 'Recibido solo pan blanco. Galletas pendientes para mañana.',
      orderedAt: _now.subtract(const Duration(days: 3)),
      receivedAt: _now.subtract(const Duration(days: 2)),
      employeeId: 'emp-002',
    ),
    PurchaseOrder.fromItems(
      id: 'ord-004',
      supplierId: sup4.id,
      supplierName: sup4.name,
      items: [
        PurchaseOrderItem.create(
          productId: 'prod-006',
          productName: 'Pechuga de Pollo 1kg',
          quantity: 20,
          purchasePrice: 65.00,
        ),
        PurchaseOrderItem.create(
          productId: 'prod-017',
          productName: 'Carne Molida 500g',
          quantity: 15,
          purchasePrice: 55.00,
        ),
      ],
      taxRate: 0,
      status: PurchaseOrderStatus.cancelled,
      notes: 'Cancelado por problemas de calidad en la inspección.',
      orderedAt: _now.subtract(const Duration(days: 15)),
      employeeId: 'emp-001',
    ),
    PurchaseOrder.fromItems(
      id: 'ord-005',
      supplierId: sup1.id,
      supplierName: sup1.name,
      items: [
        PurchaseOrderItem.create(
          productId: 'prod-001',
          productName: 'Coca-Cola 600ml',
          quantity: 300,
          purchasePrice: 8.50,
        ),
        PurchaseOrderItem.create(
          productId: 'prod-020',
          productName: 'Café Molido 500g',
          quantity: 50,
          purchasePrice: 68.00,
        ),
      ],
      taxRate: 16,
      status: PurchaseOrderStatus.pending,
      notes: 'Pedido urgente. Confirmar con el almacén antes de recibir.',
      orderedAt: _now.subtract(const Duration(hours: 6)),
      employeeId: 'emp-001',
    ),
  ];
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class PurchasesNotifier extends StateNotifier<PurchasesState> {
  final _uuid = const Uuid();

  PurchasesNotifier() : super(const PurchasesState()) {
    loadSuppliers();
    loadOrders();
  }

  // ── Suppliers ─────────────────────────────────────────────────────────────

  Future<void> loadSuppliers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // TODO(supabase): final data = await supabase.from('suppliers').select().order('name');
    final suppliers = _buildSampleSuppliers();
    state = state.copyWith(suppliers: suppliers, isLoading: false);
  }

  Future<void> addSupplier(Supplier supplier) async {
    // TODO(supabase): await supabase.from('suppliers').insert(supplier.toJson());
    final updated = [...state.suppliers, supplier];
    state = state.copyWith(suppliers: updated);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    // TODO(supabase): await supabase.from('suppliers').update(supplier.toJson()).eq('id', supplier.id);
    final updated = state.suppliers
        .map((s) => s.id == supplier.id ? supplier : s)
        .toList();
    state = state.copyWith(suppliers: updated);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<void> loadOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // TODO(supabase): final data = await supabase.from('purchases').select('*, purchase_items(*)').order('ordered_at', ascending: false);
    final suppliers = state.suppliers.isEmpty ? _buildSampleSuppliers() : state.suppliers;
    final orders = _buildSampleOrders(suppliers);
    state = state.copyWith(orders: orders);
  }

  Future<void> createOrder({
    required String supplierId,
    required String supplierName,
    required List<PurchaseOrderItem> items,
    required double taxRate,
    required String notes,
    required String employeeId,
  }) async {
    final order = PurchaseOrder.fromItems(
      id: _uuid.v4(),
      supplierId: supplierId,
      supplierName: supplierName,
      items: items,
      taxRate: taxRate,
      status: PurchaseOrderStatus.pending,
      notes: notes,
      orderedAt: DateTime.now(),
      employeeId: employeeId,
    );
    // TODO(supabase): await supabase.from('purchases').insert(order.toJson());
    state = state.copyWith(orders: [...state.orders, order]);
  }

  Future<void> receiveOrder(String orderId, {bool partial = false}) async {
    final index = state.orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final updated = [...state.orders];
    updated[index] = updated[index].copyWith(
      status: partial
          ? PurchaseOrderStatus.partial
          : PurchaseOrderStatus.received,
      receivedAt: DateTime.now(),
    );
    // TODO(supabase): update purchase status and increment product stock for each item
    state = state.copyWith(orders: updated);
  }

  Future<void> cancelOrder(String orderId) async {
    final index = state.orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final updated = [...state.orders];
    updated[index] = updated[index].copyWith(
      status: PurchaseOrderStatus.cancelled,
    );
    // TODO(supabase): await supabase.from('purchases').update({'status': 'cancelled'}).eq('id', orderId);
    state = state.copyWith(orders: updated);
  }

  // ── Computed getters ──────────────────────────────────────────────────────

  List<PurchaseOrder> get pendingOrders =>
      state.orders.where((o) => o.isPending).toList();

  List<Supplier> get activeSuppliers =>
      state.suppliers.where((s) => s.isActive).toList();
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final purchasesProvider =
    StateNotifierProvider<PurchasesNotifier, PurchasesState>(
  (ref) => PurchasesNotifier(),
);

final pendingOrdersProvider = Provider<List<PurchaseOrder>>((ref) {
  return ref.watch(purchasesProvider.notifier).pendingOrders;
});

final activeSuppliersProvider = Provider<List<Supplier>>((ref) {
  return ref.watch(purchasesProvider.notifier).activeSuppliers;
});
