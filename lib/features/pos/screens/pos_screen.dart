import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mercados/core/utils/formatters.dart';
import 'package:mercados/features/customers/models/customer.dart';
import 'package:mercados/features/inventory/models/product.dart';
import 'package:mercados/features/pos/models/sale.dart';
import 'package:mercados/features/pos/providers/pos_provider.dart';
import 'package:mercados/features/pos/widgets/product_search_tile.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Sample POS product catalogue (20 items)
// ═══════════════════════════════════════════════════════════════════════════════

final _kCatalogueDate = DateTime(2025, 5, 8);

final List<Product> _kSampleProducts = [
  Product(
    id: 'pos-001', code: '7501003126001', name: 'Leche Entera 1L',
    description: 'Leche ultrapasteurizada 1 litro',
    categoryId: 'cat-2', categoryName: 'Lácteos',
    purchasePrice: 18.00, salePrice: 24.00,
    stock: 45, minStock: 10, maxStock: 120,
    unit: ProductUnit.liter, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-002', code: '7501031300012', name: 'Pan de Caja Blanco',
    description: 'Pan de caja blanco 680 g',
    categoryId: 'cat-3', categoryName: 'Panadería',
    purchasePrice: 22.00, salePrice: 32.00,
    stock: 20, minStock: 5, maxStock: 80,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-003', code: '7506305009013', name: 'Arroz Grano Largo 1kg',
    description: 'Arroz de grano largo 1 kg',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 18.00, salePrice: 26.00,
    stock: 80, minStock: 20, maxStock: 200,
    unit: ProductUnit.kg, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-004', code: '7501455311004', name: 'Aceite Vegetal 1L',
    description: 'Aceite vegetal comestible 1 litro',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 28.00, salePrice: 38.00,
    stock: 35, minStock: 10, maxStock: 100,
    unit: ProductUnit.liter, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-005', code: '7501455310005', name: 'Azúcar Estándar 1kg',
    description: 'Azúcar refinada 1 kilogramo',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 15.00, salePrice: 22.00,
    stock: 60, minStock: 15, maxStock: 150,
    unit: ProductUnit.kg, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-006', code: '7501088800006', name: 'Sal de Mesa 1kg',
    description: 'Sal de mesa yodada 1 kg',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 6.00, salePrice: 10.00,
    stock: 90, minStock: 20, maxStock: 200,
    unit: ProductUnit.kg, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-007', code: '7502001107038', name: 'Café Molido 500g',
    description: 'Café molido tostado oscuro 500 g',
    categoryId: 'cat-1', categoryName: 'Bebidas',
    purchasePrice: 68.00, salePrice: 98.00,
    stock: 18, minStock: 5, maxStock: 60,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-008', code: '7500543500008', name: 'Huevos Blancos 12pz',
    description: 'Cartón de 12 huevos blancos',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 32.00, salePrice: 48.00,
    stock: 30, minStock: 8, maxStock: 80,
    unit: ProductUnit.box, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-009', code: '7503000400009', name: 'Mantequilla 90g',
    description: 'Mantequilla con sal 90 g',
    categoryId: 'cat-2', categoryName: 'Lácteos',
    purchasePrice: 14.00, salePrice: 22.00,
    stock: 25, minStock: 8, maxStock: 60,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-010', code: '7502003008018', name: 'Queso Manchego 400g',
    description: 'Queso manchego rebanado 400 g',
    categoryId: 'cat-2', categoryName: 'Lácteos',
    purchasePrice: 55.00, salePrice: 78.00,
    stock: 3, minStock: 5, maxStock: 40,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-011', code: '7501055311011', name: 'Jamón de Pavo 200g',
    description: 'Jamón de pavo rebanado 200 g',
    categoryId: 'cat-6', categoryName: 'Carnes',
    purchasePrice: 28.00, salePrice: 42.00,
    stock: 15, minStock: 5, maxStock: 50,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-012', code: '7500450001012', name: 'Atún en Agua 140g',
    description: 'Atún en agua lata 140 g',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 14.00, salePrice: 20.00,
    stock: 55, minStock: 15, maxStock: 120,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-013', code: '7501085001013', name: 'Frijoles Negros 1kg',
    description: 'Frijoles negros secos 1 kg',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 20.00, salePrice: 30.00,
    stock: 40, minStock: 10, maxStock: 100,
    unit: ProductUnit.kg, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-014', code: '7500435014014', name: 'Pasta Espagueti 500g',
    description: 'Espagueti de trigo duro 500 g',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 12.00, salePrice: 18.00,
    stock: 50, minStock: 10, maxStock: 120,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-015', code: '7501055315015', name: 'Salsa de Tomate 400g',
    description: 'Salsa de tomate natural 400 g',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 10.00, salePrice: 16.00,
    stock: 45, minStock: 10, maxStock: 100,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-016', code: '7501005616016', name: 'Mayonesa 445g',
    description: 'Mayonesa regular 445 g',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 28.00, salePrice: 40.00,
    stock: 22, minStock: 8, maxStock: 60,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-017', code: '7501031100231', name: 'Cereal de Avena 420g',
    description: 'Cereal integral de avena 420 g',
    categoryId: 'cat-4', categoryName: 'Abarrotes',
    purchasePrice: 28.00, salePrice: 42.00,
    stock: 4, minStock: 5, maxStock: 80,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-018', code: '7501055300158', name: 'Refresco Cola 600ml',
    description: 'Refresco de cola 600 ml',
    categoryId: 'cat-1', categoryName: 'Bebidas',
    purchasePrice: 8.50, salePrice: 14.00,
    stock: 240, minStock: 30, maxStock: 500,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-019', code: '7501055304989', name: 'Agua Natural 1.5L',
    description: 'Agua purificada 1.5 litros',
    categoryId: 'cat-1', categoryName: 'Bebidas',
    purchasePrice: 5.00, salePrice: 9.50,
    stock: 120, minStock: 20, maxStock: 300,
    unit: ProductUnit.unit, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
  Product(
    id: 'pos-020', code: '7501001600103', name: 'Jabón de Tocador x3',
    description: 'Jabón de barra pack de 3 piezas',
    categoryId: 'cat-8', categoryName: 'Higiene Personal',
    purchasePrice: 20.00, salePrice: 32.00,
    stock: 2, minStock: 10, maxStock: 80,
    unit: ProductUnit.box, isActive: true,
    createdAt: _kCatalogueDate, updatedAt: _kCatalogueDate,
  ),
];

// Demo customer used when the cashier clicks "Seleccionar" without a full
// customer-search dialog wired up.
final _kDemoCustomer = Customer(
  id: 'cust-demo',
  name: 'María García',
  phone: '+52 999 000 0001',
  email: 'maria@email.com',
  address: '',
  creditLimit: 0,
  currentDebt: 0,
  points: 0,
  isActive: true,
  createdAt: DateTime(2025),
);

// ═══════════════════════════════════════════════════════════════════════════════
// PosScreen
// ═══════════════════════════════════════════════════════════════════════════════

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late DateTime _clockTime;
  late Timer _clockTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _clockTime = DateTime.now();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() => _clockTime = DateTime.now());
      },
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _amountCtrl.dispose();
    _searchFocus.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  // ── Filtering ────────────────────────────────────────────────────────────

  List<Product> get _filteredProducts {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _kSampleProducts;
    return _kSampleProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q);
    }).toList();
  }

  // ── Success dialog ───────────────────────────────────────────────────────

  void _showSuccessDialog(PosState pos) {
    final sale = pos.lastCompletedSale!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SaleSuccessDialog(
        sale: sale,
        onNewSale: () {
          ref.read(posProvider.notifier).clearCart();
          _amountCtrl.clear();
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pos = ref.watch(posProvider);

    // React to completed sales.
    ref.listen<PosState>(posProvider, (prev, next) {
      if (next.lastCompletedSale != null &&
          prev?.lastCompletedSale?.id != next.lastCompletedSale?.id) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            if (mounted) _showSuccessDialog(next);
          },
        );
      }
    });

    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LEFT: product search
          Expanded(
            flex: 3,
            child: _LeftPanel(
              clockTime: _clockTime,
              searchCtrl: _searchCtrl,
              searchFocus: _searchFocus,
              searchQuery: _searchQuery,
              filteredProducts: _filteredProducts,
              onSearchChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          // RIGHT: cart
          SizedBox(
            width: 400,
            child: _RightPanel(
              pos: pos,
              amountCtrl: _amountCtrl,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEFT PANEL — search bar + product grid
// ═══════════════════════════════════════════════════════════════════════════════

class _LeftPanel extends ConsumerWidget {
  const _LeftPanel({
    required this.clockTime,
    required this.searchCtrl,
    required this.searchFocus,
    required this.searchQuery,
    required this.filteredProducts,
    required this.onSearchChanged,
  });

  final DateTime clockTime;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final String searchQuery;
  final List<Product> filteredProducts;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header bar ───────────────────────────────────────────────────
        Container(
          color: colorScheme.primary,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.point_of_sale,
                  color: colorScheme.onPrimary, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Punto de Venta',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Live clock + date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatDate(clockTime),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.80),
                    ),
                  ),
                  Text(
                    formatTime(clockTime),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Search field ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            controller: searchCtrl,
            focusNode: searchFocus,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar producto por nombre o código...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        searchCtrl.clear();
                        onSearchChanged('');
                        searchFocus.requestFocus();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
            ),
          ),
        ),

        // Results header
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              Text(
                searchQuery.isEmpty
                    ? 'Catálogo completo'
                    : 'Resultados para "$searchQuery"',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${filteredProducts.length} productos',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Grid ─────────────────────────────────────────────────────────
        Expanded(
          child: filteredProducts.isEmpty
              ? _EmptySearch(query: searchQuery)
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (ctx, index) {
                    final product = filteredProducts[index];
                    return ProductSearchTile(
                      product: product,
                      onTap: () => ref
                          .read(posProvider.notifier)
                          .addProduct(product),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off,
              size: 56,
              color: colorScheme.onSurface.withValues(alpha: 0.25)),
          const SizedBox(height: 12),
          Text(
            'Sin resultados para "$query"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.45)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RIGHT PANEL — cart, totals, payment, complete
// ═══════════════════════════════════════════════════════════════════════════════

class _RightPanel extends ConsumerWidget {
  const _RightPanel({
    required this.pos,
    required this.amountCtrl,
  });

  final PosState pos;
  final TextEditingController amountCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(posProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cart header ──────────────────────────────────────────────────
          _CartHeader(pos: pos, notifier: notifier),

          // ── Error banner ─────────────────────────────────────────────────
          if (pos.error != null)
            _ErrorBanner(
              message: pos.error!,
              onDismiss: notifier.clearError,
            ),

          // ── Items list ───────────────────────────────────────────────────
          Expanded(
            child: pos.isEmpty
                ? _EmptyCart()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: pos.items.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, indent: 12, endIndent: 12),
                    itemBuilder: (_, idx) {
                      final item = pos.items[idx];
                      return _CartItemRow(
                        item: item,
                        onIncrement: () => notifier.updateQuantity(
                          item.product.id,
                          item.quantity.toInt() + 1,
                        ),
                        onDecrement: () => notifier.updateQuantity(
                          item.product.id,
                          item.quantity.toInt() - 1,
                        ),
                        onDelete: () =>
                            notifier.removeItem(item.product.id),
                      );
                    },
                  ),
          ),

          const Divider(height: 1),

          // ── Totals + payment ─────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Customer row
                _CustomerSelector(pos: pos, notifier: notifier),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Subtotal / discount / tax
                _LabelValueRow(
                  label: 'Subtotal',
                  value: formatCurrency(pos.subtotal),
                ),
                if (pos.totalDiscount > 0) ...[
                  const SizedBox(height: 4),
                  _LabelValueRow(
                    label: 'Descuentos',
                    value: '- ${formatCurrency(pos.totalDiscount)}',
                    valueColor: Colors.orange.shade700,
                  ),
                ],
                const SizedBox(height: 4),
                _LabelValueRow(
                  label: 'IVA (16%)',
                  value: formatCurrency(pos.taxAmount),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Grand total
                Row(
                  children: [
                    Text(
                      'TOTAL',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatCurrency(pos.total),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Payment method
                Text(
                  'Método de pago',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                _PaymentChips(pos: pos, notifier: notifier),

                // Cash fields
                if (pos.paymentMethod == PaymentMethod.cash) ...[
                  const SizedBox(height: 10),
                  _CashFields(
                    pos: pos,
                    amountCtrl: amountCtrl,
                    notifier: notifier,
                  ),
                ],
                const SizedBox(height: 14),

                // Complete sale CTA
                _CompleteSaleButton(pos: pos, notifier: notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart header ──────────────────────────────────────────────────────────────

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.pos, required this.notifier});
  final PosState pos;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: colorScheme.secondaryContainer,
      child: Row(
        children: [
          Icon(Icons.shopping_cart,
              color: colorScheme.onSecondaryContainer, size: 22),
          const SizedBox(width: 8),
          Text(
            'Carrito',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          if (pos.items.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${pos.items.length}',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Spacer(),
          if (!pos.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              color: colorScheme.error,
              tooltip: 'Vaciar carrito',
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text(
            '¿Deseas eliminar todos los artículos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              notifier.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(
      {required this.message, required this.onDismiss});
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: colorScheme.onErrorContainer, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: colorScheme.onErrorContainer, fontSize: 12),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close,
                size: 16, color: colorScheme.onErrorContainer),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── Empty cart ───────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 56,
              color: colorScheme.onSurface.withValues(alpha: 0.20)),
          const SizedBox(height: 10),
          Text(
            'Carrito vacío',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.40)),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona un producto del catálogo',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.30)),
          ),
        ],
      ),
    );
  }
}

// ─── Cart item row ────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final dynamic item; // CartItem — avoids extra import boilerplate
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name + unit price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatCurrency(item.unitPrice as double)}'
                  ' / ${item.product.unit.abbreviation}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Qty − / count / +
          _QtyControl(
            qty: (item.quantity as double).toInt(),
            onDecrement: onDecrement,
            onIncrement: onIncrement,
          ),
          const SizedBox(width: 8),

          // Line total
          SizedBox(
            width: 66,
            child: Text(
              formatCurrency(item.total as double),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4),

          // Delete button
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close,
                  size: 15,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniButton(
          icon: Icons.remove,
          color: colorScheme.error,
          onTap: onDecrement,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        _MiniButton(
          icon: Icons.add,
          color: colorScheme.primary,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

// ─── Customer selector ────────────────────────────────────────────────────────

class _CustomerSelector extends StatelessWidget {
  const _CustomerSelector({required this.pos, required this.notifier});
  final PosState pos;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(Icons.person_outline,
            size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            pos.selectedCustomer?.name ??
                'Cliente general (sin registro)',
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: pos.selectedCustomer != null
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              fontStyle: pos.selectedCustomer == null
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            if (pos.selectedCustomer == null) {
              notifier.setCustomer(_kDemoCustomer);
            } else {
              notifier.setCustomer(null);
            }
          },
          child: Text(
            pos.selectedCustomer == null ? 'Seleccionar' : 'Quitar',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

// ─── Label/value row ──────────────────────────────────────────────────────────

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextStyle? base = theme.textTheme.bodySmall;

    return Row(
      children: [
        Text(label,
            style:
                base?.copyWith(color: colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(value,
            style: base?.copyWith(
              color: valueColor,
            )),
      ],
    );
  }
}

// ─── Payment chips ────────────────────────────────────────────────────────────

class _PaymentChips extends StatelessWidget {
  const _PaymentChips({required this.pos, required this.notifier});
  final PosState pos;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PayChip(
          label: 'Efectivo',
          icon: Icons.payments_outlined,
          selected: pos.paymentMethod == PaymentMethod.cash,
          onSelected: (_) =>
              notifier.setPaymentMethod(PaymentMethod.cash),
        ),
        const SizedBox(width: 6),
        _PayChip(
          label: 'Tarjeta',
          icon: Icons.credit_card,
          selected: pos.paymentMethod == PaymentMethod.card,
          onSelected: (_) =>
              notifier.setPaymentMethod(PaymentMethod.card),
        ),
        const SizedBox(width: 6),
        _PayChip(
          label: 'Transferencia',
          icon: Icons.account_balance_outlined,
          selected: pos.paymentMethod == PaymentMethod.transfer,
          onSelected: (_) =>
              notifier.setPaymentMethod(PaymentMethod.transfer),
        ),
      ],
    );
  }
}

class _PayChip extends StatelessWidget {
  const _PayChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        avatar: Icon(icon, size: 14),
        selected: selected,
        showCheckmark: false,
        onSelected: onSelected,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      ),
    );
  }
}

// ─── Cash fields ──────────────────────────────────────────────────────────────

class _CashFields extends StatelessWidget {
  const _CashFields({
    required this.pos,
    required this.amountCtrl,
    required this.notifier,
  });

  final PosState pos;
  final TextEditingController amountCtrl;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Amount received
        TextField(
          controller: amountCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onChanged: (v) {
            notifier.setAmountPaid(double.tryParse(v) ?? 0.0);
          },
          decoration: InputDecoration(
            labelText: 'Monto recibido',
            prefixText: '\$ ',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 6),
        // Change display
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: pos.change > 0
                ? Colors.green.shade50
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: pos.change > 0
                  ? Colors.green.shade300
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cambio:',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text(
                formatCurrency(pos.change),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: pos.change > 0
                      ? Colors.green.shade800
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Complete sale button ─────────────────────────────────────────────────────

class _CompleteSaleButton extends ConsumerWidget {
  const _CompleteSaleButton(
      {required this.pos, required this.notifier});
  final PosState pos;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canComplete = pos.isReadyToComplete;

    return SizedBox(
      height: 50,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: canComplete
              ? const Color(0xFF2E7D32)
              : Colors.grey.shade400,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        icon: pos.isProcessing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Icon(Icons.check_circle_outline,
                color: Colors.white),
        label: Text(
          pos.isProcessing ? 'Procesando...' : 'COMPLETAR VENTA',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            fontSize: 15,
          ),
        ),
        onPressed: canComplete && !pos.isProcessing
            ? () async {
                try {
                  await notifier.completeSale();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor:
                            Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              }
            : null,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sale success dialog
// ═══════════════════════════════════════════════════════════════════════════════

class _SaleSuccessDialog extends StatelessWidget {
  const _SaleSuccessDialog({
    required this.sale,
    required this.onNewSale,
  });

  final dynamic sale; // Sale
  final VoidCallback onNewSale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ────────────────────────────────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    size: 48, color: Colors.green.shade700),
              ),
              const SizedBox(height: 14),
              Text(
                '¡Venta Completada!',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                formatDateTime(sale.createdAt as DateTime),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 18),
              const Divider(),

              // ── Ticket ──────────────────────────────────────────────────
              _TicketLine(
                label: 'Artículos',
                value: '${(sale.items as List).length} líneas',
              ),
              _TicketLine(
                label: 'Subtotal',
                value: formatCurrency(sale.subtotal as double),
              ),
              if ((sale.discountTotal as double) > 0)
                _TicketLine(
                  label: 'Descuentos',
                  value:
                      '- ${formatCurrency(sale.discountTotal as double)}',
                  valueColor: Colors.orange.shade700,
                ),
              _TicketLine(
                label: 'IVA (16%)',
                value: formatCurrency(sale.taxAmount as double),
              ),
              const Divider(height: 10),
              _TicketLine(
                label: 'TOTAL',
                value: formatCurrency(sale.total as double),
                bold: true,
              ),
              _TicketLine(
                label: 'Método de pago',
                value: (sale.paymentMethod as PaymentMethod).displayName,
              ),
              if (sale.paymentMethod == PaymentMethod.cash) ...[
                _TicketLine(
                  label: 'Recibido',
                  value: formatCurrency(sale.amountPaid as double),
                ),
                _TicketLine(
                  label: 'Cambio',
                  value: formatCurrency(
                    (sale.change as double) < 0
                        ? 0
                        : sale.change as double,
                  ),
                  valueColor: Colors.green.shade700,
                  bold: true,
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nueva Venta'),
                  onPressed: onNewSale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketLine extends StatelessWidget {
  const _TicketLine({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle? base = bold
        ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: base?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style: base?.copyWith(
                color: valueColor,
                fontWeight: bold ? FontWeight.bold : null,
              )),
        ],
      ),
    );
  }
}
