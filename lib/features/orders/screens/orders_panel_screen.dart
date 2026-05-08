import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:mercados/core/theme/app_theme.dart';
import 'package:mercados/features/employees/providers/employees_provider.dart';
import 'package:mercados/features/orders/providers/orders_provider.dart';

// ---------------------------------------------------------------------------
// Colour helpers
// ---------------------------------------------------------------------------

extension OrderStatusUi on OrderStatus {
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFF57F17);
      case OrderStatus.preparing:
        return const Color(0xFF0277BD);
      case OrderStatus.onTheWay:
        return const Color(0xFF6750A4);
      case OrderStatus.delivered:
        return AppTheme.successColor;
      case OrderStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.preparing:
        return Icons.restaurant_menu_rounded;
      case OrderStatus.onTheWay:
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OrdersPanelScreen extends ConsumerStatefulWidget {
  const OrdersPanelScreen({super.key});

  @override
  ConsumerState<OrdersPanelScreen> createState() => _OrdersPanelScreenState();
}

class _OrdersPanelScreenState extends ConsumerState<OrdersPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    _TabInfo('Pendientes', OrderStatus.pending),
    _TabInfo('En Preparación', OrderStatus.preparing),
    _TabInfo('En Camino', OrderStatus.onTheWay),
    _TabInfo('Entregados', OrderStatus.delivered),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final lastRefreshStr =
        DateFormat('HH:mm:ss').format(ordersState.lastRefresh);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Pedidos'),
        actions: [
          // Refresh indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sync, size: 16, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  lastRefreshStr,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.primary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.read(ordersProvider.notifier).loadOrders(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) {
            final count = _countForStatus(ordersState.orders, t.status);
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.label),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    _CountBadge(count: count, color: t.status.color),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: ordersState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _tabs
                  .map((t) => _OrdersColumn(
                        orders: ordersState.orders
                            .where((o) => o.status == t.status)
                            .toList(),
                        status: t.status,
                      ))
                  .toList(),
            ),
    );
  }

  int _countForStatus(List<Order> orders, OrderStatus status) =>
      orders.where((o) => o.status == status).length;
}

class _TabInfo {
  final String label;
  final OrderStatus status;
  const _TabInfo(this.label, this.status);
}

// ---------------------------------------------------------------------------
// Column of order cards for one status
// ---------------------------------------------------------------------------

class _OrdersColumn extends ConsumerWidget {
  const _OrdersColumn({required this.orders, required this.status});

  final List<Order> orders;
  final OrderStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, size: 64, color: cs.onSurface.withAlpha(60)),
            const SizedBox(height: 12),
            Text(
              'Sin pedidos ${status.displayName.toLowerCase()}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: cs.onSurface.withAlpha(100)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Order card
// ---------------------------------------------------------------------------

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currency = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);
    final elapsed = _formatElapsed(order.elapsed);
    final statusColor = order.status.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withAlpha(80)),
                  ),
                  child: Text(
                    order.orderNumber,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: statusColor),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  order.type == OrderType.delivery
                      ? Icons.delivery_dining
                      : Icons.store,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  order.type.displayName,
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 3),
                Text(elapsed,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: order.elapsed.inMinutes > 30
                          ? AppTheme.warningColor
                          : null,
                    )),
              ],
            ),
            const SizedBox(height: 10),
            // ── Customer ───────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 4),
                Text(order.customerName,
                    style: theme.textTheme.titleSmall),
                const SizedBox(width: 8),
                Text(order.customerPhone,
                    style: theme.textTheme.bodySmall),
              ],
            ),
            if (order.deliveryAddress != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress!,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            // ── Items summary ──────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...order.items.take(3).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              currency.format(item.subtotal),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )),
                  if (order.items.length > 3)
                    Text(
                      '+ ${order.items.length - 3} producto(s) más',
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── Total + delivery person ────────────────────────
            Row(
              children: [
                if (order.deliveryPersonName != null)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.delivery_dining,
                            size: 15, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          order.deliveryPersonName!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (order.deliveryFee > 0)
                      Text(
                        'Envío: ${currency.format(order.deliveryFee)}',
                        style: theme.textTheme.labelSmall,
                      ),
                    Text(
                      'Total: ${currency.format(order.total)}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: cs.primary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // ── Action buttons ─────────────────────────────────
            _ActionButtons(order: order),
          ],
        ),
      ),
    );
  }

  String _formatElapsed(Duration d) {
    if (d.inMinutes < 1) return 'Ahora';
    if (d.inHours < 1) return '${d.inMinutes} min';
    return '${d.inHours}h ${d.inMinutes.remainder(60)}min';
  }
}

// ---------------------------------------------------------------------------
// Action buttons row
// ---------------------------------------------------------------------------

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ordersProvider.notifier);

    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: BorderSide(color: AppTheme.errorColor.withAlpha(120)),
                ),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Rechazar'),
                onPressed: () => _confirmCancel(context, ref),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Aceptar'),
                onPressed: () =>
                    notifier.updateStatus(order.id, OrderStatus.preparing),
              ),
            ),
          ],
        );

      case OrderStatus.preparing:
        return Row(
          children: [
            if (order.type == OrderType.delivery &&
                order.deliveryPersonId == null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_pin_circle_outlined, size: 16),
                  label: const Text('Asignar'),
                  onPressed: () => _assignDelivery(context, ref),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.delivery_dining, size: 16),
                label: const Text('En camino'),
                onPressed: order.type == OrderType.delivery &&
                        order.deliveryPersonId == null
                    ? null
                    : () => notifier.updateStatus(
                        order.id, OrderStatus.onTheWay),
              ),
            ),
            if (order.type == OrderType.pickup) ...[
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Entregado'),
                  onPressed: () =>
                      notifier.updateStatus(order.id, OrderStatus.delivered),
                ),
              ),
            ],
          ],
        );

      case OrderStatus.onTheWay:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Marcar como Entregado'),
            onPressed: () =>
                notifier.updateStatus(order.id, OrderStatus.delivered),
          ),
        );

      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return Row(
          children: [
            Icon(
              order.status == OrderStatus.delivered
                  ? Icons.check_circle
                  : Icons.cancel,
              size: 16,
              color: order.status.color,
            ),
            const SizedBox(width: 6),
            Text(
              order.status.displayName,
              style: TextStyle(
                color: order.status.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        );
    }
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rechazar pedido'),
        content: Text(
            '¿Rechazar el pedido ${order.orderNumber} de ${order.customerName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(ordersProvider.notifier).cancelOrder(order.id);
    }
  }

  Future<void> _assignDelivery(BuildContext context, WidgetRef ref) async {
    final deliveryStaff =
        ref.read(employeesProvider).employees.where((e) {
      return e.role == EmployeeRole.deliveryPerson && e.isActive;
    }).toList();

    if (!context.mounted) return;

    if (deliveryStaff.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay repartidores activos disponibles')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => _AssignDeliveryDialog(
        order: order,
        deliveryStaff: deliveryStaff,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Assign delivery dialog
// ---------------------------------------------------------------------------

class _AssignDeliveryDialog extends ConsumerStatefulWidget {
  const _AssignDeliveryDialog({
    required this.order,
    required this.deliveryStaff,
  });

  final Order order;
  final List<Employee> deliveryStaff;

  @override
  ConsumerState<_AssignDeliveryDialog> createState() =>
      _AssignDeliveryDialogState();
}

class _AssignDeliveryDialogState
    extends ConsumerState<_AssignDeliveryDialog> {
  Employee? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.deliveryStaff.isNotEmpty) {
      _selected = widget.deliveryStaff.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar Repartidor'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.deliveryStaff
              .map((emp) => RadioListTile<Employee>(
                    title: Text(emp.fullName),
                    subtitle: Text(emp.phone),
                    value: emp,
                    groupValue: _selected,
                    onChanged: (v) => setState(() => _selected = v),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () {
                  ref.read(ordersProvider.notifier).assignDelivery(
                        widget.order.id,
                        _selected!.id,
                        _selected!.fullName,
                      );
                  Navigator.pop(context);
                },
          child: const Text('Asignar'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Small count badge
// ---------------------------------------------------------------------------

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
