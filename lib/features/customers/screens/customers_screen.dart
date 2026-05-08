import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:mercados/features/customers/providers/customers_provider.dart';
import 'package:mercados/features/customers/models/customer.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();

  static final _currencyFmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _CustomerDialog(
        onSave: (customer) {
          ref.read(customersProvider.notifier).addCustomer(customer);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente agregado correctamente'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _openEditDialog(Customer customer) {
    showDialog<void>(
      context: context,
      builder: (_) => _CustomerDialog(
        existing: customer,
        onSave: (updated) {
          ref.read(customersProvider.notifier).updateCustomer(updated);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente actualizado'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _openDetailSheet(Customer customer) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CustomerDetailSheet(
        customer: customer,
        currencyFmt: _currencyFmt,
        onEdit: () {
          Navigator.of(ctx).pop();
          _openEditDialog(customer);
        },
        onRegisterPayment: () =>
            _showPaymentDialog(ctx, customer),
        onAddPoints: () =>
            _showAddPointsDialog(ctx, customer),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Customer customer) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deuda actual: ${_currencyFmt.format(customer.currentDebt)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Monto del pago',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(ctrl.text.trim());
              if (amount == null || amount <= 0) return;
              ref
                  .read(customersProvider.notifier)
                  .payDebt(customer.id, amount);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Pago de ${_currencyFmt.format(amount)} registrado',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _showAddPointsDialog(BuildContext context, Customer customer) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar puntos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Puntos actuales: ${customer.points}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Puntos a agregar',
                prefixIcon: Icon(Icons.stars_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final pts = int.tryParse(ctrl.text.trim());
              if (pts == null || pts <= 0) return;
              ref
                  .read(customersProvider.notifier)
                  .addPoints(customer.id, pts);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$pts puntos agregados'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersProvider);
    final filtered = ref.watch(filteredCustomersProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final totalCustomers = state.customers.length;
    final withDebt = state.customers.where((c) => c.isInDebt).length;
    final withPoints = state.customers.where((c) => c.points > 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () {
              showSearch<Customer?>(
                context: context,
                delegate: _CustomerSearchDelegate(
                  customers: state.customers,
                  currencyFmt: _currencyFmt,
                  onTap: _openDetailSheet,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Agregar cliente'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Search bar ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Buscar por nombre, teléfono, email…',
                    leading: const Icon(Icons.search),
                    trailing: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(customersProvider.notifier)
                                .searchCustomers('');
                            setState(() {});
                          },
                        ),
                    ],
                    onChanged: (v) {
                      ref
                          .read(customersProvider.notifier)
                          .searchCustomers(v);
                      setState(() {});
                    },
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),

                // ── Stats row ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people_outline,
                          label: 'Total',
                          value: '$totalCustomers',
                          color: cs.primaryContainer,
                          onColor: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.money_off_outlined,
                          label: 'Con deuda',
                          value: '$withDebt',
                          color: Colors.red.shade100,
                          onColor: Colors.red.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.stars_outlined,
                          label: 'Con puntos',
                          value: '$withPoints',
                          color: Colors.amber.shade100,
                          onColor: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── List ──────────────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyState(
                          hasQuery: state.searchQuery.isNotEmpty,
                          onAdd: _openAddDialog,
                          onClear: () {
                            _searchController.clear();
                            ref
                                .read(customersProvider.notifier)
                                .searchCustomers('');
                          },
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) => _CustomerCard(
                            customer: filtered[i],
                            currencyFmt: _currencyFmt,
                            onTap: () => _openDetailSheet(filtered[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: onColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onColor,
                ),
              ),
              Text(
                label,
                style:
                    TextStyle(fontSize: 11, color: onColor.withOpacity(.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Customer card
// ---------------------------------------------------------------------------

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.currencyFmt,
    required this.onTap,
  });

  final Customer customer;
  final NumberFormat currencyFmt;
  final VoidCallback onTap;

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: customer.isInDebt
              ? Colors.red.shade200
              : cs.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ──────────────────────────────────────────
              CircleAvatar(
                radius: 26,
                backgroundColor: customer.isActive
                    ? cs.primaryContainer
                    : cs.surfaceContainerHighest,
                child: Text(
                  _initials(customer.name),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: customer.isActive
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Info ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!customer.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Inactivo',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone.isEmpty ? 'Sin teléfono' : customer.phone,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Points badge
                        if (customer.points > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars_rounded,
                                    size: 14,
                                    color: Colors.amber.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  '${customer.points} pts',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Debt badge
                        if (customer.isInDebt)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.money_off_outlined,
                                    size: 14, color: Colors.red.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  currencyFmt
                                      .format(customer.currentDebt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Credit info ──────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Crédito',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  Text(
                    currencyFmt.format(customer.creditLimit),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.chevron_right,
                      color: cs.onSurfaceVariant, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Customer detail bottom sheet
// ---------------------------------------------------------------------------

class _CustomerDetailSheet extends StatelessWidget {
  const _CustomerDetailSheet({
    required this.customer,
    required this.currencyFmt,
    required this.onEdit,
    required this.onRegisterPayment,
    required this.onAddPoints,
  });

  final Customer customer;
  final NumberFormat currencyFmt;
  final VoidCallback onEdit;
  final VoidCallback onRegisterPayment;
  final VoidCallback onAddPoints;

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateFmt = DateFormat('dd/MM/yyyy', 'es_MX');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
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

              // ── Header ────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      _initials(customer.name),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (customer.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            customer.email,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: customer.isActive
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                customer.isActive ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: customer.isActive
                                      ? Colors.green.shade700
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar',
                    onPressed: onEdit,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Financial summary ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _FinancialCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Deuda',
                      value: currencyFmt.format(customer.currentDebt),
                      color: customer.isInDebt
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      valueColor: customer.isInDebt
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FinancialCard(
                      icon: Icons.credit_card_outlined,
                      label: 'Límite crédito',
                      value: currencyFmt.format(customer.creditLimit),
                      color: cs.surfaceContainerHighest,
                      valueColor: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FinancialCard(
                      icon: Icons.stars_outlined,
                      label: 'Puntos',
                      value: '${customer.points}',
                      color: Colors.amber.shade100,
                      valueColor: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Contact details ────────────────────────────────────
              Text('Datos de contacto',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: customer.phone.isEmpty ? '—' : customer.phone),
              _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: customer.email.isEmpty ? '—' : customer.email),
              _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Dirección',
                  value: customer.address.isEmpty ? '—' : customer.address),
              if (customer.taxId != null && customer.taxId!.isNotEmpty)
                _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'RFC',
                    value: customer.taxId!),
              _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Cliente desde',
                  value: dateFmt.format(customer.createdAt)),
              const SizedBox(height: 20),

              // ── Credit bar ─────────────────────────────────────────
              Text('Uso de crédito',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _CreditBar(customer: customer, currencyFmt: currencyFmt),
              const SizedBox(height: 20),

              // ── Purchase history placeholder ───────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history_outlined,
                            size: 18, color: cs.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Historial de compras',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'El historial de compras estará disponible\ncuando se conecte a la base de datos.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Action buttons ────────────────────────────────────
              if (customer.isInDebt)
                FilledButton.icon(
                  onPressed: onRegisterPayment,
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Registrar pago'),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade600),
                ),
              if (customer.isInDebt) const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onAddPoints,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Agregar puntos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Financial summary card
// ---------------------------------------------------------------------------

class _FinancialCard extends StatelessWidget {
  const _FinancialCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: valueColor.withOpacity(.8)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                color: valueColor.withOpacity(.7)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
      padding: const EdgeInsets.symmetric(vertical: 5),
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
// Credit bar
// ---------------------------------------------------------------------------

class _CreditBar extends StatelessWidget {
  const _CreditBar({
    required this.customer,
    required this.currencyFmt,
  });

  final Customer customer;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ratio = customer.creditLimit > 0
        ? (customer.currentDebt / customer.creditLimit).clamp(0.0, 1.0)
        : 0.0;

    final barColor = ratio > 0.8
        ? Colors.red.shade600
        : ratio > 0.5
            ? Colors.orange.shade600
            : Colors.green.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usado: ${currencyFmt.format(customer.currentDebt)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              'Disponible: ${currencyFmt.format(customer.availableCredit)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasQuery,
    required this.onAdd,
    required this.onClear,
  });

  final bool hasQuery;
  final VoidCallback onAdd;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.people_outline,
            size: 72,
            color: cs.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery
                ? 'No se encontraron clientes'
                : 'Aún no hay clientes registrados',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (hasQuery)
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              label: const Text('Limpiar búsqueda'),
            )
          else
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Agregar primer cliente'),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search delegate
// ---------------------------------------------------------------------------

class _CustomerSearchDelegate extends SearchDelegate<Customer?> {
  _CustomerSearchDelegate({
    required this.customers,
    required this.currencyFmt,
    required this.onTap,
  });

  final List<Customer> customers;
  final NumberFormat currencyFmt;
  final ValueChanged<Customer> onTap;

  @override
  String get searchFieldLabel => 'Buscar cliente…';

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _list(context);

  @override
  Widget buildSuggestions(BuildContext context) => _list(context);

  Widget _list(BuildContext context) {
    final q = query.trim().toLowerCase();
    final results = q.isEmpty
        ? customers
        : customers
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.phone.contains(q) ||
                c.email.toLowerCase().contains(q))
            .toList();

    if (results.isEmpty) {
      return const Center(child: Text('Sin resultados'));
    }

    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final c = results[i];
        final initials = c.name.trim().split(' ').length >= 2
            ? '${c.name.trim().split(' ')[0][0]}${c.name.trim().split(' ')[1][0]}'
                .toUpperCase()
            : c.name.isNotEmpty
                ? c.name[0].toUpperCase()
                : '?';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: cs.primaryContainer,
            child: Text(initials,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer)),
          ),
          title: Text(c.name),
          subtitle: Text(c.phone),
          trailing: c.isInDebt
              ? Text(
                  currencyFmt.format(c.currentDebt),
                  style: TextStyle(
                      color: Colors.red.shade700, fontWeight: FontWeight.w600),
                )
              : null,
          onTap: () {
            close(ctx, c);
            onTap(c);
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit customer dialog
// ---------------------------------------------------------------------------

class _CustomerDialog extends StatefulWidget {
  const _CustomerDialog({
    this.existing,
    required this.onSave,
  });

  final Customer? existing;
  final ValueChanged<Customer> onSave;

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _taxId;
  late final TextEditingController _creditLimit;
  late bool _isActive;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _taxId = TextEditingController(text: c?.taxId ?? '');
    _creditLimit = TextEditingController(
      text: c != null ? c.creditLimit.toStringAsFixed(2) : '500.00',
    );
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _taxId.dispose();
    _creditLimit.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: widget.existing?.id ?? _uuid.v4(),
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      taxId: _taxId.text.trim().isEmpty ? null : _taxId.text.trim(),
      creditLimit:
          double.tryParse(_creditLimit.text.trim()) ?? 500.0,
      currentDebt: widget.existing?.currentDebt ?? 0.0,
      points: widget.existing?.points ?? 0,
      isActive: _isActive,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    widget.onSave(customer);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      _isEditing
                          ? Icons.edit_outlined
                          : Icons.person_add_alt_1_outlined,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isEditing ? 'Editar Cliente' : 'Agregar Cliente',
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // ── Fields ────────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _field(
                          controller: _name,
                          label: 'Nombre completo *',
                          icon: Icons.person_outline,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Campo requerido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                controller: _phone,
                                label: 'Teléfono',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _field(
                                controller: _email,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _field(
                          controller: _address,
                          label: 'Dirección',
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                controller: _taxId,
                                label: 'RFC / Tax ID',
                                icon: Icons.badge_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _field(
                                controller: _creditLimit,
                                label: 'Límite de crédito *',
                                icon: Icons.credit_card_outlined,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Campo requerido';
                                  }
                                  final d = double.tryParse(v.trim());
                                  if (d == null || d < 0) {
                                    return 'Valor inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Active toggle
                        Card(
                          elevation: 0,
                          color: cs.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: cs.outlineVariant),
                          ),
                          child: SwitchListTile(
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                            title: const Text('Cliente activo'),
                            subtitle: Text(
                              _isActive
                                  ? 'Puede realizar compras y usar crédito'
                                  : 'Cuenta desactivada',
                            ),
                            secondary: Icon(
                              _isActive
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: _isActive ? Colors.green : cs.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // ── Actions ───────────────────────────────────────
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
                      icon: Icon(
                          _isEditing ? Icons.save_outlined : Icons.add),
                      label:
                          Text(_isEditing ? 'Guardar cambios' : 'Agregar'),
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
