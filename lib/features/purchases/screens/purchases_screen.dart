import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mercados/features/purchases/providers/purchases_provider.dart';
import 'package:mercados/features/purchases/models/purchase_order.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  /// null means "Todas"
  PurchaseOrderStatus? _statusFilter;

  static final _currencyFmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  static final _dateFmt = DateFormat('dd/MM/yyyy', 'es_MX');

  List<PurchaseOrder> _filtered(List<PurchaseOrder> all) {
    if (_statusFilter == null) return all;
    return all.where((o) => o.status == _statusFilter).toList();
  }

  void _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchasesProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final orders = _filtered(state.orders);

    // Counts per status for filter chips
    int countFor(PurchaseOrderStatus s) =>
        state.orders.where((o) => o.status == s).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Compra'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            tooltip: 'Filtrar',
            onPressed: () => _showFilterBottomSheet(context),
          ),
          const SizedBox(width: 4),
          FilledButton.tonalIcon(
            onPressed: () => _showNewOrderDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nueva orden'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Status filter chips ───────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Todas',
                        count: state.orders.length,
                        selected: _statusFilter == null,
                        color: cs.primary,
                        onSelected: () =>
                            setState(() => _statusFilter = null),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pendiente',
                        count: countFor(PurchaseOrderStatus.pending),
                        selected:
                            _statusFilter == PurchaseOrderStatus.pending,
                        color: Colors.amber.shade700,
                        onSelected: () => setState(
                            () => _statusFilter = PurchaseOrderStatus.pending),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Recibida',
                        count: countFor(PurchaseOrderStatus.received),
                        selected:
                            _statusFilter == PurchaseOrderStatus.received,
                        color: Colors.green.shade600,
                        onSelected: () => setState(() =>
                            _statusFilter = PurchaseOrderStatus.received),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Parcial',
                        count: countFor(PurchaseOrderStatus.partial),
                        selected:
                            _statusFilter == PurchaseOrderStatus.partial,
                        color: Colors.orange.shade600,
                        onSelected: () => setState(() =>
                            _statusFilter = PurchaseOrderStatus.partial),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Cancelada',
                        count: countFor(PurchaseOrderStatus.cancelled),
                        selected:
                            _statusFilter == PurchaseOrderStatus.cancelled,
                        color: Colors.red.shade600,
                        onSelected: () => setState(() =>
                            _statusFilter = PurchaseOrderStatus.cancelled),
                      ),
                    ],
                  ),
                ),

                // ── Result count ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    '${orders.length} orden${orders.length == 1 ? '' : 'es'}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),

                // ── Orders list ───────────────────────────────────────
                Expanded(
                  child: orders.isEmpty
                      ? _EmptyOrdersState(
                          hasFilter: _statusFilter != null,
                          onClear: () =>
                              setState(() => _statusFilter = null),
                          onCreate: () => _showNewOrderDialog(context),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, i) => _OrderCard(
                            order: orders[i],
                            currencyFmt: _currencyFmt,
                            dateFmt: _dateFmt,
                            onViewDetails: () =>
                                _showOrderDetails(ctx, orders[i]),
                            onMarkReceived: orders[i].isPending ||
                                    orders[i].isPartial
                                ? () => _confirmAction(
                                      context: ctx,
                                      title: 'Marcar como recibida',
                                      message:
                                          '¿Confirmar la recepción completa de la orden #${orders[i].id}?',
                                      confirmLabel: 'Confirmar',
                                      confirmColor: Colors.green,
                                      onConfirm: () => ref
                                          .read(purchasesProvider.notifier)
                                          .receiveOrder(orders[i].id),
                                    )
                                : null,
                            onCancel: orders[i].isPending
                                ? () => _confirmAction(
                                      context: ctx,
                                      title: 'Cancelar orden',
                                      message:
                                          '¿Seguro que deseas cancelar la orden #${orders[i].id}? Esta acción no se puede deshacer.',
                                      confirmLabel: 'Cancelar orden',
                                      confirmColor: Colors.red,
                                      onConfirm: () => ref
                                          .read(purchasesProvider.notifier)
                                          .cancelOrder(orders[i].id),
                                    )
                                : null,
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filter bottom sheet
  // ---------------------------------------------------------------------------

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final state = ref.read(purchasesProvider);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Filtrar por estado',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 16),
              ..._filterOption(ctx, null, 'Todas', Icons.list_alt_outlined,
                  state.orders.length),
              ..._filterOption(
                  ctx,
                  PurchaseOrderStatus.pending,
                  'Pendiente',
                  Icons.pending_outlined,
                  state.orders.where((o) => o.isPending).length),
              ..._filterOption(
                  ctx,
                  PurchaseOrderStatus.received,
                  'Recibida',
                  Icons.check_circle_outline,
                  state.orders.where((o) => o.isReceived).length),
              ..._filterOption(
                  ctx,
                  PurchaseOrderStatus.partial,
                  'Parcial',
                  Icons.incomplete_circle_outlined,
                  state.orders.where((o) => o.isPartial).length),
              ..._filterOption(
                  ctx,
                  PurchaseOrderStatus.cancelled,
                  'Cancelada',
                  Icons.cancel_outlined,
                  state.orders.where((o) => o.isCancelled).length),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _filterOption(
    BuildContext ctx,
    PurchaseOrderStatus? status,
    String label,
    IconData icon,
    int count,
  ) {
    final selected = _statusFilter == status;
    final cs = Theme.of(ctx).colorScheme;
    return [
      ListTile(
        leading: Icon(icon,
            color: selected ? cs.primary : cs.onSurfaceVariant),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$count',
                    style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant)),
              ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, color: cs.primary, size: 20),
            ],
          ],
        ),
        selected: selected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          setState(() => _statusFilter = status);
          Navigator.of(ctx).pop();
        },
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Order details bottom sheet
  // ---------------------------------------------------------------------------

  void _showOrderDetails(BuildContext context, PurchaseOrder order) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orden #${order.id}',
                          style:
                              Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.supplierName,
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 16),

              // Dates
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Ordenado',
                value: _dateFmt.format(order.orderedAt),
              ),
              if (order.receivedAt != null)
                _DetailRow(
                  icon: Icons.check_circle_outline,
                  label: 'Recibido',
                  value: _dateFmt.format(order.receivedAt!),
                ),
              if (order.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.notes_outlined,
                  label: 'Notas',
                  value: order.notes,
                ),
              ],
              const Divider(height: 24),

              // Items
              Text(
                'Artículos (${order.lineCount})',
                style: Theme.of(ctx)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName,
                                  style:
                                      Theme.of(ctx).textTheme.bodyMedium),
                              Text(
                                '${item.quantity.toStringAsFixed(0)} u × ${_currencyFmt.format(item.purchasePrice)}',
                                style: Theme.of(ctx)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _currencyFmt.format(item.total),
                          style: Theme.of(ctx)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 24),

              // Totals
              _TotalRow(
                  label: 'Subtotal',
                  value: _currencyFmt.format(order.subtotal)),
              _TotalRow(
                  label: 'IVA',
                  value: _currencyFmt.format(order.tax)),
              const SizedBox(height: 4),
              _TotalRow(
                label: 'TOTAL',
                value: _currencyFmt.format(order.total),
                bold: true,
              ),
              const SizedBox(height: 24),

              // Actions
              if (order.isPending || order.isPartial)
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ref
                        .read(purchasesProvider.notifier)
                        .receiveOrder(order.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Orden marcada como recibida'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Marcar como recibida'),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade600),
                ),
              if (order.isPending) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ref
                        .read(purchasesProvider.notifier)
                        .cancelOrder(order.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Orden cancelada'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar orden'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // New order dialog
  // ---------------------------------------------------------------------------

  void _showNewOrderDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _NewOrderDialog(
        suppliers: ref.read(purchasesProvider).suppliers,
        onCreate: ({
          required supplierId,
          required supplierName,
          required items,
          required notes,
        }) {
          ref.read(purchasesProvider.notifier).createOrder(
                supplierId: supplierId,
                supplierName: supplierName,
                items: items,
                taxRate: 16,
                notes: notes,
                employeeId: 'emp-current',
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Orden de compra creada'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip widget
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.onSelected,
  });

  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color.withOpacity(.15),
      checkmarkColor: color,
      side: BorderSide(
        color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
      ),
      labelStyle: TextStyle(
        color: selected ? color : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order card
// ---------------------------------------------------------------------------

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.currencyFmt,
    required this.dateFmt,
    required this.onViewDetails,
    required this.onMarkReceived,
    required this.onCancel,
  });

  final PurchaseOrder order;
  final NumberFormat currencyFmt;
  final DateFormat dateFmt;
  final VoidCallback onViewDetails;
  final VoidCallback? onMarkReceived;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onViewDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status bar ────────────────────────────────────────────
            Container(
              height: 4,
              color: _statusColor(order.status),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '#${order.id}',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _OrderStatusBadge(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order.supplierName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFmt.format(order.total),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          Text(
                            dateFmt.format(order.orderedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Item count ─────────────────────────────────────
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        '${order.lineCount} artículo${order.lineCount == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      if (order.tax > 0) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.receipt_outlined,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'IVA: ${currencyFmt.format(order.tax)}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),

                  if (order.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.notes_outlined,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.notes,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── Actions ────────────────────────────────────────
                  if (onMarkReceived != null || onCancel != null) ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: onViewDetails,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Ver detalles'),
                        ),
                        if (onMarkReceived != null) ...[
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            onPressed: onMarkReceived,
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  Colors.green.withOpacity(.15),
                              foregroundColor: Colors.green.shade700,
                            ),
                            icon: const Icon(Icons.check_circle_outline,
                                size: 18),
                            label: const Text('Recibir'),
                          ),
                        ],
                        if (onCancel != null) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side:
                                  const BorderSide(color: Colors.red),
                            ),
                            icon: const Icon(Icons.cancel_outlined,
                                size: 18),
                            label: const Text('Cancelar'),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: onViewDetails,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Ver detalles'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(PurchaseOrderStatus status) {
    switch (status) {
      case PurchaseOrderStatus.pending:
        return Colors.amber.shade600;
      case PurchaseOrderStatus.received:
        return Colors.green.shade600;
      case PurchaseOrderStatus.partial:
        return Colors.orange.shade600;
      case PurchaseOrderStatus.cancelled:
        return Colors.red.shade600;
    }
  }
}

// ---------------------------------------------------------------------------
// Order status badge
// ---------------------------------------------------------------------------

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.status});

  final PurchaseOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      PurchaseOrderStatus.pending => (
          'Pendiente',
          Colors.amber.shade100,
          Colors.amber.shade800
        ),
      PurchaseOrderStatus.received => (
          'Recibida',
          Colors.green.shade100,
          Colors.green.shade800
        ),
      PurchaseOrderStatus.partial => (
          'Parcial',
          Colors.orange.shade100,
          Colors.orange.shade800
        ),
      PurchaseOrderStatus.cancelled => (
          'Cancelada',
          Colors.red.shade100,
          Colors.red.shade800
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail row helper
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Total row helper
// ---------------------------------------------------------------------------

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState({
    required this.hasFilter,
    required this.onClear,
    required this.onCreate,
  });

  final bool hasFilter;
  final VoidCallback onClear;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilter ? Icons.filter_alt_off_outlined : Icons.receipt_long_outlined,
            size: 72,
            color: cs.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter
                ? 'No hay órdenes con este estado'
                : 'No hay órdenes de compra',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (hasFilter)
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              label: const Text('Quitar filtro'),
            )
          else
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear primera orden'),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// New Order dialog
// ---------------------------------------------------------------------------

typedef _CreateOrderCallback = void Function({
  required String supplierId,
  required String supplierName,
  required List<PurchaseOrderItem> items,
  required String notes,
});

class _NewOrderDialog extends StatefulWidget {
  const _NewOrderDialog({
    required this.suppliers,
    required this.onCreate,
  });

  final List<dynamic> suppliers; // List<Supplier>
  final _CreateOrderCallback onCreate;

  @override
  State<_NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends State<_NewOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  // Selected supplier
  int _supplierIndex = 0;

  // Items being added
  final List<_TempItem> _items = [];

  // New item controllers
  final _itemNameCtrl = TextEditingController();
  final _itemQtyCtrl = TextEditingController();
  final _itemPriceCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    _itemNameCtrl.dispose();
    _itemQtyCtrl.dispose();
    _itemPriceCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    final name = _itemNameCtrl.text.trim();
    final qty = double.tryParse(_itemQtyCtrl.text.trim());
    final price = double.tryParse(_itemPriceCtrl.text.trim());

    if (name.isEmpty || qty == null || qty <= 0 || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos del artículo correctamente'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _items.add(_TempItem(name: name, quantity: qty, price: price));
      _itemNameCtrl.clear();
      _itemQtyCtrl.clear();
      _itemPriceCtrl.clear();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un artículo'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final supplier = widget.suppliers[_supplierIndex];
    final orderItems = _items
        .map((t) => PurchaseOrderItem.create(
              productId: 'prod-new-${DateTime.now().millisecondsSinceEpoch}',
              productName: t.name,
              quantity: t.quantity,
              purchasePrice: t.price,
            ))
        .toList();

    widget.onCreate(
      supplierId: supplier.id as String,
      supplierName: supplier.name as String,
      items: orderItems,
      notes: _notesCtrl.text.trim(),
    );

    Navigator.of(context).pop();
  }

  double get _subtotal =>
      _items.fold(0.0, (s, t) => s + t.quantity * t.price);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final suppliers = widget.suppliers;
    final currFmt =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title ──────────────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.add_shopping_cart_outlined,
                        color: cs.primary),
                    const SizedBox(width: 12),
                    Text('Nueva Orden de Compra',
                        style: theme.textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Supplier selector ──────────────────────
                        DropdownButtonFormField<int>(
                          value: _supplierIndex,
                          decoration: const InputDecoration(
                            labelText: 'Proveedor *',
                            prefixIcon: Icon(Icons.storefront_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (int i = 0; i < suppliers.length; i++)
                              DropdownMenuItem(
                                value: i,
                                child: Text(suppliers[i].name as String),
                              ),
                          ],
                          onChanged: (v) =>
                              setState(() => _supplierIndex = v ?? 0),
                        ),
                        const SizedBox(height: 16),

                        // ── Notes ─────────────────────────────────
                        TextFormField(
                          controller: _notesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Notas',
                            prefixIcon: Icon(Icons.notes_outlined),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),

                        // ── Add item ──────────────────────────────
                        Text(
                          'Artículos',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: _itemNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Producto',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _itemQtyCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Cantidad',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _itemPriceCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Precio',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: _addItem,
                              style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.all(14)),
                              child: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Items list ─────────────────────────────
                        if (_items.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: cs.outlineVariant),
                            ),
                            child: Text(
                              'Agrega artículos usando el formulario de arriba',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          Column(
                            children: [
                              ..._items.asMap().entries.map((entry) {
                                final i = entry.key;
                                final t = entry.value;
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(t.name),
                                  subtitle: Text(
                                    '${t.quantity.toStringAsFixed(0)} u × ${currFmt.format(t.price)}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currFmt
                                            .format(t.quantity * t.price),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w600),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.red),
                                        onPressed: () => setState(
                                            () => _items.removeAt(i)),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal',
                                      style: theme.textTheme.titleSmall),
                                  Text(
                                    currFmt.format(_subtotal),
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // ── Actions ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Crear orden'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Temp item model (local to dialog)
// ---------------------------------------------------------------------------

class _TempItem {
  const _TempItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final double quantity;
  final double price;
}
