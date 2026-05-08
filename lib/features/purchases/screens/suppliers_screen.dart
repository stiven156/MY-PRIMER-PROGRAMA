import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mercados/features/purchases/providers/purchases_provider.dart';
import 'package:mercados/features/purchases/models/supplier.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Supplier> _filtered(List<Supplier> all) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.contactName.toLowerCase().contains(q) ||
            s.phone.contains(q) ||
            s.email.toLowerCase().contains(q))
        .toList();
  }

  void _openDialog({Supplier? existing}) {
    showDialog<void>(
      context: context,
      builder: (_) => _SupplierDialog(
        existing: existing,
        onSave: (supplier) {
          final notifier = ref.read(purchasesProvider.notifier);
          if (existing == null) {
            notifier.addSupplier(supplier);
          } else {
            notifier.updateSupplier(supplier);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(existing == null
                  ? 'Proveedor agregado correctamente'
                  : 'Proveedor actualizado correctamente'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchasesProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final suppliers = _filtered(state.suppliers);
    final totalActive = state.suppliers.where((s) => s.isActive).length;
    final totalInactive = state.suppliers.where((s) => !s.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () {
              showSearch<Supplier?>(
                context: context,
                delegate: _SupplierSearchDelegate(
                  suppliers: state.suppliers,
                  onEdit: (s) => _openDialog(existing: s),
                  onToggle: (s) => ref
                      .read(purchasesProvider.notifier)
                      .updateSupplier(s.copyWith(isActive: !s.isActive)),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar proveedor'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Search bar ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Buscar por nombre, contacto, teléfono…',
                    leading: const Icon(Icons.search),
                    trailing: [
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                    ],
                    onChanged: (v) => setState(() => _searchQuery = v),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),

                // ── Stats row ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _StatChip(
                        label: 'Total',
                        count: state.suppliers.length,
                        color: cs.primary,
                        onPrimary: cs.onPrimary,
                      ),
                      _StatChip(
                        label: 'Activos',
                        count: totalActive,
                        color: Colors.green.shade600,
                        onPrimary: Colors.white,
                      ),
                      _StatChip(
                        label: 'Inactivos',
                        count: totalInactive,
                        color: Colors.grey.shade500,
                        onPrimary: Colors.white,
                      ),
                    ],
                  ),
                ),

                // ── Result count ──────────────────────────────────────────
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Text(
                      '${suppliers.length} resultado${suppliers.length == 1 ? '' : 's'} para "$_searchQuery"',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),

                // ── Table / empty state ───────────────────────────────────
                Expanded(
                  child: suppliers.isEmpty
                      ? _EmptyState(
                          hasQuery: _searchQuery.isNotEmpty,
                          onAdd: () => _openDialog(),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            child: _SuppliersTable(
                              suppliers: suppliers,
                              onEdit: (s) => _openDialog(existing: s),
                              onToggle: (s) => ref
                                  .read(purchasesProvider.notifier)
                                  .updateSupplier(
                                      s.copyWith(isActive: !s.isActive)),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat chip
// ---------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.onPrimary,
  });

  final String label;
  final int count;
  final Color color;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '$count',
          style: TextStyle(
            color: onPrimary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(label),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery, required this.onAdd});

  final bool hasQuery;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.store_mall_directory_outlined,
            size: 72,
            color: cs.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery
                ? 'No se encontraron proveedores'
                : 'Aún no hay proveedores registrados',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (!hasQuery) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Agregar primer proveedor'),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DataTable
// ---------------------------------------------------------------------------

class _SuppliersTable extends StatelessWidget {
  const _SuppliersTable({
    required this.suppliers,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Supplier> suppliers;
  final ValueChanged<Supplier> onEdit;
  final ValueChanged<Supplier> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DataTable(
      columnSpacing: 20,
      headingRowColor: WidgetStateProperty.all(
        cs.surfaceContainerHighest.withValues(alpha: 0.55),
      ),
      border: TableBorder(
        horizontalInside: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      columns: const [
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Contacto')),
        DataColumn(label: Text('Teléfono')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Acciones')),
      ],
      rows: suppliers.map((s) => _buildRow(context, s, theme, cs)).toList(),
    );
  }

  DataRow _buildRow(
    BuildContext context,
    Supplier s,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return DataRow(
      cells: [
        // Nombre
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: s.isActive
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                  child: Text(
                    s.name.characters.first.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: s.isActive
                          ? cs.onPrimaryContainer
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (s.taxId.isNotEmpty)
                        Text(
                          s.taxId,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contacto
        DataCell(Text(s.contactName.isEmpty ? '—' : s.contactName)),

        // Teléfono
        DataCell(Text(s.phone.isEmpty ? '—' : s.phone)),

        // Email
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              s.email.isEmpty ? '—' : s.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Estado
        DataCell(
          _StatusBadge(isActive: s.isActive),
        ),

        // Acciones
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Editar',
                visualDensity: VisualDensity.compact,
                onPressed: () => onEdit(s),
              ),
              IconButton(
                icon: Icon(
                  s.isActive
                      ? Icons.toggle_on_rounded
                      : Icons.toggle_off_rounded,
                  size: 28,
                  color: s.isActive ? Colors.green : Colors.grey,
                ),
                tooltip: s.isActive ? 'Desactivar' : 'Activar',
                visualDensity: VisualDensity.compact,
                onPressed: () => onToggle(s),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: isActive ? Colors.green.shade800 : Colors.grey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search delegate
// ---------------------------------------------------------------------------

class _SupplierSearchDelegate extends SearchDelegate<Supplier?> {
  _SupplierSearchDelegate({
    required this.suppliers,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Supplier> suppliers;
  final ValueChanged<Supplier> onEdit;
  final ValueChanged<Supplier> onToggle;

  @override
  String get searchFieldLabel => 'Buscar proveedor…';

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
        ? suppliers
        : suppliers
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.contactName.toLowerCase().contains(q) ||
                s.phone.contains(q) ||
                s.email.toLowerCase().contains(q))
            .toList();

    if (results.isEmpty) {
      return const Center(child: Text('Sin resultados'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final s = results[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: s.isActive
                ? Theme.of(ctx).colorScheme.primaryContainer
                : Theme.of(ctx).colorScheme.surfaceContainerHighest,
            child: Text(
              s.name.characters.first.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: s.isActive
                    ? Theme.of(ctx).colorScheme.onPrimaryContainer
                    : Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          title: Text(s.name),
          subtitle: Text('${s.contactName}  •  ${s.phone}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusBadge(isActive: s.isActive),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {
                  close(ctx, null);
                  onEdit(s);
                },
              ),
            ],
          ),
          onTap: () => close(ctx, s),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit dialog
// ---------------------------------------------------------------------------

class _SupplierDialog extends StatefulWidget {
  const _SupplierDialog({
    this.existing,
    required this.onSave,
  });

  final Supplier? existing;
  final ValueChanged<Supplier> onSave;

  @override
  State<_SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends State<_SupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  late final TextEditingController _name;
  late final TextEditingController _contactName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _taxId;
  late final TextEditingController _notes;
  late bool _isActive;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _name = TextEditingController(text: s?.name ?? '');
    _contactName = TextEditingController(text: s?.contactName ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _email = TextEditingController(text: s?.email ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _taxId = TextEditingController(text: s?.taxId ?? '');
    _notes = TextEditingController(text: s?.notes ?? '');
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _contactName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _taxId.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final supplier = Supplier(
      id: widget.existing?.id ?? _uuid.v4(),
      name: _name.text.trim(),
      contactName: _contactName.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      taxId: _taxId.text.trim(),
      notes: _notes.text.trim(),
      isActive: _isActive,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    widget.onSave(supplier);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      _isEditing
                          ? Icons.edit_outlined
                          : Icons.store_mall_directory_outlined,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isEditing ? 'Editar Proveedor' : 'Agregar Proveedor',
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

                // ── Fields ────────────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _field(
                          controller: _name,
                          label: 'Nombre del proveedor *',
                          icon: Icons.business_outlined,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Campo requerido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _field(
                          controller: _contactName,
                          label: 'Nombre de contacto',
                          icon: Icons.person_outline,
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
                        _field(
                          controller: _taxId,
                          label: 'RFC / Tax ID',
                          icon: Icons.receipt_long_outlined,
                        ),
                        const SizedBox(height: 16),
                        _field(
                          controller: _notes,
                          label: 'Notas',
                          icon: Icons.notes_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        // isActive toggle
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
                            title: const Text('Proveedor activo'),
                            subtitle: Text(
                              _isActive
                                  ? 'Disponible para órdenes de compra'
                                  : 'No aparecerá en nuevas órdenes',
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
                // ── Actions ───────────────────────────────────────────
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
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
