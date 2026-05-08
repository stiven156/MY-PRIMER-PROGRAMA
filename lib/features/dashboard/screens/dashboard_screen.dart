import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/core/theme/app_theme.dart';
import 'package:mercados/core/utils/formatters.dart';
import 'package:mercados/features/auth/providers/auth_provider.dart';
import 'package:mercados/features/inventory/models/product.dart';
import 'package:mercados/features/inventory/providers/inventory_provider.dart';
import 'package:mercados/features/pos/models/sale.dart';
import 'package:mercados/shared/widgets/stat_card.dart';

// ---------------------------------------------------------------------------
// Sample / stub data — replace with real providers once sales / orders
// providers are wired up to Supabase.
// ---------------------------------------------------------------------------

final _now = DateTime.now();

final List<Sale> _recentSales = [
  Sale.fromItems(
    id: 'sale-001',
    items: const [],
    customerId: 'cust-01',
    customerName: 'María González',
    taxRate: 16,
    paymentMethod: PaymentMethod.cash,
    amountPaid: 200,
    employeeId: 'emp-01',
    employeeName: 'Carlos López',
    createdAt: _now.subtract(const Duration(minutes: 15)),
  ),
  Sale.fromItems(
    id: 'sale-002',
    items: const [],
    taxRate: 16,
    paymentMethod: PaymentMethod.card,
    amountPaid: 458,
    employeeId: 'emp-01',
    employeeName: 'Carlos López',
    createdAt: _now.subtract(const Duration(hours: 1)),
  ),
  Sale.fromItems(
    id: 'sale-003',
    items: const [],
    customerId: 'cust-03',
    customerName: 'Roberto Martínez',
    taxRate: 16,
    paymentMethod: PaymentMethod.transfer,
    amountPaid: 1250,
    employeeId: 'emp-02',
    employeeName: 'Ana Pérez',
    createdAt: _now.subtract(const Duration(hours: 2, minutes: 30)),
  ),
  Sale.fromItems(
    id: 'sale-004',
    items: const [],
    taxRate: 16,
    paymentMethod: PaymentMethod.cash,
    amountPaid: 88,
    employeeId: 'emp-02',
    employeeName: 'Ana Pérez',
    createdAt: _now.subtract(const Duration(hours: 4)),
  ),
  Sale.fromItems(
    id: 'sale-005',
    items: const [],
    customerId: 'cust-07',
    customerName: 'Lucía Ramírez',
    taxRate: 16,
    paymentMethod: PaymentMethod.card,
    amountPaid: 376,
    employeeId: 'emp-01',
    employeeName: 'Carlos López',
    createdAt: _now.subtract(const Duration(hours: 5, minutes: 45)),
  ),
];

// ---------------------------------------------------------------------------
// Dashboard screen
// ---------------------------------------------------------------------------

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _DashboardContent(),
    );
  }
}

// ---------------------------------------------------------------------------
// Main content
// ---------------------------------------------------------------------------

class _DashboardContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final inventoryState = ref.watch(inventoryProvider);
    final lowStockProducts =
        ref.watch(inventoryProvider.notifier).lowStockProducts;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= AppConstants.sidebarBreakpoint;

    // Computed stats
    final totalSalesToday =
        _recentSales.fold<double>(0, (sum, s) => sum + s.amountPaid);
    final stockCount = inventoryState.products.fold<double>(
        0, (sum, p) => sum + p.stock);

    return CustomScrollView(
      slivers: [
        // ── App Bar ──────────────────────────────────────────────────────
        SliverAppBar(
          floating: true,
          snap: true,
          automaticallyImplyLeading: !isWide,
          backgroundColor: colorScheme.surface,
          title: Row(
            children: [
              if (!isWide) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.store_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Panel de Control',
                      style: textTheme.titleMedium),
                  Text(
                    _capitalizeFirst(DateFormat('EEEE d MMMM', 'es_MX')
                        .format(DateTime.now())),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notificaciones',
              onPressed: () {},
            ),
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _UserAvatar(user.name),
              ),
          ],
        ),

        SliverPadding(
          padding: AppConstants.pagePadding,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Welcome header ──────────────────────────────────────
              _WelcomeHeader(userName: user?.name ?? 'Usuario'),
              const SizedBox(height: 24),

              // ── Stat cards ──────────────────────────────────────────
              _StatCardsRow(
                totalSalesToday: totalSalesToday,
                stockCount: stockCount,
                lowStockCount: lowStockProducts.length,
                pendingOrders: 3,
                newCustomers: 7,
              ),
              const SizedBox(height: 28),

              // ── Bottom section: recent sales + side panels ───────────
              _BottomSection(
                lowStockProducts: lowStockProducts,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ]),
          ),
        ),
      ],
    );
  }

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ---------------------------------------------------------------------------
// Welcome header
// ---------------------------------------------------------------------------

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final firstName = userName.split(' ').first;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $firstName',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aquí tienes el resumen de hoy.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.point_of_sale_rounded, size: 18),
          label: const Text('Nueva venta'),
          onPressed: () => context.go(AppConstants.routePOS),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stat cards row
// ---------------------------------------------------------------------------

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.totalSalesToday,
    required this.stockCount,
    required this.lowStockCount,
    required this.pendingOrders,
    required this.newCustomers,
  });

  final double totalSalesToday;
  final double stockCount;
  final int lowStockCount;
  final int pendingOrders;
  final int newCustomers;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;

    final cards = [
      StatCard(
        title: 'Ventas Hoy',
        value: formatCurrencyCompact(totalSalesToday),
        icon: Icons.attach_money_rounded,
        subtitle: '${_recentSales.length} transacciones',
        trend: '+12%',
        trendPositive: true,
        color: AppTheme.successColor,
        onTap: () => context.go(AppConstants.routeReports),
      ),
      StatCard(
        title: 'Productos en Stock',
        value: formatNumber(stockCount, decimals: 0),
        icon: Icons.inventory_2_rounded,
        subtitle: '$lowStockCount con stock bajo',
        trend: lowStockCount > 0 ? '-$lowStockCount' : null,
        trendPositive: false,
        color: AppTheme.infoColor,
        onTap: () => context.go(AppConstants.routeInventory),
      ),
      StatCard(
        title: 'Pedidos Pendientes',
        value: '$pendingOrders',
        icon: Icons.pending_actions_rounded,
        subtitle: 'Por procesar',
        trend: pendingOrders > 0 ? '$pendingOrders nuevos' : null,
        trendPositive: false,
        color: AppTheme.warningColor,
        onTap: () => context.go(AppConstants.routePurchases),
      ),
      StatCard(
        title: 'Clientes Nuevos',
        value: '$newCustomers',
        icon: Icons.person_add_rounded,
        subtitle: 'Este mes',
        trend: '+$newCustomers',
        trendPositive: true,
        color: const Color(0xFF7B1FA2),
        onTap: () => context.go(AppConstants.routeCustomers),
      ),
    ];

    if (isNarrow) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 0,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
        children: cards,
      );
    }

    return Row(
      children: cards
          .map((c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: c,
                ),
              ))
          .toList()
        ..last = Expanded(child: cards.last),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom section
// ---------------------------------------------------------------------------

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.lowStockProducts,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<Product> lowStockProducts;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _RecentSalesTable(colorScheme: colorScheme, textTheme: textTheme),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _LowStockAlerts(
                    products: lowStockProducts,
                    colorScheme: colorScheme,
                    textTheme: textTheme),
                const SizedBox(height: 20),
                _PendingOrdersPanel(
                    colorScheme: colorScheme, textTheme: textTheme),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _RecentSalesTable(colorScheme: colorScheme, textTheme: textTheme),
        const SizedBox(height: 20),
        _LowStockAlerts(
            products: lowStockProducts,
            colorScheme: colorScheme,
            textTheme: textTheme),
        const SizedBox(height: 20),
        _PendingOrdersPanel(colorScheme: colorScheme, textTheme: textTheme),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Recent sales table
// ---------------------------------------------------------------------------

class _RecentSalesTable extends StatelessWidget {
  const _RecentSalesTable({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Ventas Recientes',
      icon: Icons.receipt_long_rounded,
      actionLabel: 'Ver todo',
      onAction: () => context.go(AppConstants.routeReports),
      child: Column(
        children: [
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Cliente',
                      style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Método',
                      style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Total',
                      textAlign: TextAlign.end,
                      style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Hora',
                      textAlign: TextAlign.end,
                      style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Sale rows
          ..._recentSales.map((sale) => _SaleRow(
                sale: sale,
                colorScheme: colorScheme,
                textTheme: textTheme,
              )),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({
    required this.sale,
    required this.colorScheme,
    required this.textTheme,
  });

  final Sale sale;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final paymentIcon = switch (sale.paymentMethod) {
      PaymentMethod.cash => Icons.payments_outlined,
      PaymentMethod.card => Icons.credit_card_rounded,
      PaymentMethod.transfer => Icons.swap_horiz_rounded,
      PaymentMethod.mixed => Icons.compare_arrows_rounded,
    };

    final paymentColor = switch (sale.paymentMethod) {
      PaymentMethod.cash => AppTheme.successColor,
      PaymentMethod.card => AppTheme.infoColor,
      PaymentMethod.transfer => AppTheme.warningColor,
      PaymentMethod.mixed => const Color(0xFF7B1FA2),
    };

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Customer
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      initials(sale.customerName ?? 'PB'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sale.customerName ?? 'Público general',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Payment method
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(paymentIcon, size: 14, color: paymentColor),
                  const SizedBox(width: 4),
                  Text(
                    sale.paymentMethod.displayName,
                    style: textTheme.bodySmall?.copyWith(color: paymentColor),
                  ),
                ],
              ),
            ),
            // Total
            Expanded(
              flex: 2,
              child: Text(
                formatCurrency(sale.amountPaid),
                textAlign: TextAlign.end,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            // Time
            Expanded(
              flex: 2,
              child: Text(
                formatRelativeDate(sale.createdAt),
                textAlign: TextAlign.end,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Low stock alerts
// ---------------------------------------------------------------------------

class _LowStockAlerts extends StatelessWidget {
  const _LowStockAlerts({
    required this.products,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<Product> products;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final visibleProducts = products.take(5).toList();

    return _SectionCard(
      title: 'Alertas de Stock',
      icon: Icons.warning_amber_rounded,
      iconColor: AppTheme.warningColor,
      actionLabel: 'Ver inventario',
      onAction: () => context.go(AppConstants.routeInventory),
      child: visibleProducts.isEmpty
          ? _EmptyState(
              icon: Icons.check_circle_outline_rounded,
              message: 'No hay productos con stock bajo',
              color: AppTheme.successColor,
            )
          : Column(
              children: visibleProducts
                  .map((p) => _LowStockRow(
                        product: p,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ))
                  .toList(),
            ),
    );
  }
}

class _LowStockRow extends StatelessWidget {
  const _LowStockRow({
    required this.product,
    required this.colorScheme,
    required this.textTheme,
  });

  final Product product;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stock <= 0;
    final stockColor = isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor;
    final stockLabel = isOutOfStock ? 'Sin stock' : 'Bajo';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: stockColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.inventory_2_outlined, color: stockColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.categoryName,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: stockColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stockLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: stockColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${product.stock.toStringAsFixed(0)} / ${product.minStock.toStringAsFixed(0)} ${product.unit.abbreviation}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pending orders
// ---------------------------------------------------------------------------

class _PendingOrdersPanel extends StatelessWidget {
  const _PendingOrdersPanel({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  // Stub pending orders
  static const _orders = [
    ('PO-2024-089', 'Grupo Bimbo S.A.', 'Panadería', 1420.0),
    ('PO-2024-090', 'Lala S.A. de C.V.', 'Lácteos', 3800.0),
    ('PO-2024-091', 'The Coca-Cola Co.', 'Bebidas', 5600.0),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Pedidos Pendientes',
      icon: Icons.local_shipping_outlined,
      iconColor: AppTheme.infoColor,
      actionLabel: 'Ver pedidos',
      onAction: () => context.go(AppConstants.routePurchases),
      child: Column(
        children: _orders.map((o) {
          final (id, supplier, category, total) = o;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shopping_cart_outlined,
                      color: AppTheme.infoColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$id  •  $category',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(total),
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared section card container
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final IconData icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final effectiveIconColor = iconColor ?? colorScheme.primary;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                Icon(icon, color: effectiveIconColor, size: 20),
                const SizedBox(width: 8),
                Text(title, style: textTheme.titleSmall),
                const Spacer(),
                if (actionLabel != null && onAction != null)
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(actionLabel!,
                        style:
                            const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state helper
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: color, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// User avatar chip
// ---------------------------------------------------------------------------

class _UserAvatar extends StatelessWidget {
  const _UserAvatar(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: name,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          initials(name),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
