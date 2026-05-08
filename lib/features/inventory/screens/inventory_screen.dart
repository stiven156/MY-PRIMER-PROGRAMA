import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/core/utils/formatters.dart';
import 'package:mercados/features/inventory/models/category.dart';
import 'package:mercados/features/inventory/models/product.dart';
import 'package:mercados/features/inventory/providers/inventory_provider.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryProvider);
    final products = ref.watch(filteredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= AppConstants.sidebarBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Exportar',
            onPressed: () => _showExportDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: () => ref.read(inventoryProvider.notifier).loadProducts(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppConstants.routeProductForm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo producto'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Search bar ───────────────────────────────────────────────
                _SearchBar(
                  controller: _searchController,
                  onChanged: (q) =>
                      ref.read(inventoryProvider.notifier).searchProducts(q),
                ),

                // ── Filter chips ─────────────────────────────────────────────
                _FilterChips(
                  categories: categories,
                  selectedCategoryId: state.selectedCategoryId,
                  filterLowStock: state.filterLowStock,
                  onCategorySelected: (id) => ref
                      .read(inventoryProvider.notifier)
                      .filterByCategory(id),
                  onLowStockToggled: (v) => ref
                      .read(inventoryProvider.notifier)
                      .setLowStockFilter(enabled: v),
                ),

                // ── Summary row ──────────────────────────────────────────────
                _SummaryBar(
                  total: state.products.length,
                  shown: products.length,
                  lowStock: ref
                      .read(inventoryProvider.notifier)
                      .lowStockProducts
                      .length,
                ),

                // ── Products table / list ────────────────────────────────────
                Expanded(
                  child: products.isEmpty
                      ? _EmptyState(
                          message: state.searchQuery.isNotEmpty
                              ? 'Sin resultados para "${state.searchQuery}"'
                              : 'No hay productos en esta categoría',
                        )
                      : isWide
                          ? _ProductsTable(products: products)
                          : _ProductsList(products: products),
                ),
              ],
            ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const _ExportDialog(),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, código o categoría…',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips
// ---------------------------------------------------------------------------

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.categories,
    required this.selectedCategoryId,
    required this.filterLowStock,
    required this.onCategorySelected,
    required this.onLowStockToggled,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final bool filterLowStock;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<bool> onLowStockToggled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final warningColor = const Color(0xFFF57F17);

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // All chip
          _buildChip(
            context: context,
            label: 'Todos',
            isSelected: selectedCategoryId == null && !filterLowStock,
            color: cs.primary,
            onTap: () {
              onCategorySelected(null);
              onLowStockToggled(false);
            },
          ),
          const SizedBox(width: 8),
          // Low stock chip
          _buildChip(
            context: context,
            label: 'Stock bajo',
            icon: Icons.warning_amber_rounded,
            isSelected: filterLowStock,
            color: warningColor,
            onTap: () => onLowStockToggled(!filterLowStock),
          ),
          const SizedBox(width: 8),
          // Category chips
          ...categories.map((cat) {
            final isSelected = selectedCategoryId == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                context: context,
                label: cat.name,
                isSelected: isSelected,
                color: cs.secondary,
                onTap: () =>
                    onCategorySelected(isSelected ? null : cat.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: isSelected ? color : null),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color.withAlpha(30),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        fontSize: 13,
      ),
      side: isSelected ? BorderSide(color: color) : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Summary bar
// ---------------------------------------------------------------------------

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.total,
    required this.shown,
    required this.lowStock,
  });

  final int total;
  final int shown;
  final int lowStock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Row(
        children: [
          Text(
            'Mostrando $shown de $total productos',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const Spacer(),
          if (lowStock > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF57F17).withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF57F17).withAlpha(100),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 13, color: Color(0xFFF57F17)),
                  const SizedBox(width: 4),
                  Text(
                    '$lowStock con stock bajo',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFF57F17),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wide-screen DataTable
// ---------------------------------------------------------------------------

class _ProductsTable extends ConsumerWidget {
  const _ProductsTable({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      child: Card(
        margin: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('Código')),
              DataColumn(label: Text('Producto')),
              DataColumn(label: Text('Categoría')),
              DataColumn(label: Text('Compra'), numeric: true),
              DataColumn(label: Text('Venta'), numeric: true),
              DataColumn(label: Text('Margen'), numeric: true),
              DataColumn(label: Text('Stock'), numeric: true),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: products.map((p) => _buildRow(context, ref, p)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(
      BuildContext context, WidgetRef ref, Product product) {
    final isLow = product.isLowStock;
    final isExpired = product.isExpired;

    return DataRow(
      cells: [
        DataCell(
          Text(
            product.code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProductAvatar(product: product),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  product.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(product.categoryName)),
        DataCell(Text(formatCurrency(product.purchasePrice))),
        DataCell(Text(formatCurrency(product.salePrice))),
        DataCell(
          Text(
            formatPercentValue(product.margin),
            style: TextStyle(
              color: product.margin >= 20
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFF57F17),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DataCell(
          Text(
            '${product.stock.toStringAsFixed(product.unit == ProductUnit.unit ? 0 : 1)} ${product.unit.abbreviation}',
            style: TextStyle(
              color: isLow ? const Color(0xFFF57F17) : null,
              fontWeight: isLow ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        DataCell(_StatusBadge(product: product)),
        DataCell(
          _RowActions(
            product: product,
            onEdit: () => context.go(
              '${AppConstants.routeProductForm}?id=${product.id}',
            ),
            onAdjustStock: () =>
                _showStockAdjustDialog(context, ref, product),
            onDelete: () => _confirmDelete(context, ref, product),
          ),
        ),
      ],
    );
  }

  void _showStockAdjustDialog(
      BuildContext context, WidgetRef ref, Product product) {
    showDialog<void>(
      context: context,
      builder: (_) => _StockAdjustDialog(product: product),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Product product) {
    showDialog<void>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(product: product),
    );
  }
}

// ---------------------------------------------------------------------------
// Narrow-screen list
// ---------------------------------------------------------------------------

class _ProductsList extends ConsumerWidget {
  const _ProductsList({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: products.length,
      itemBuilder: (ctx, i) => _ProductCard(product: products[i]),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLow = product.isLowStock;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductAvatar(product: product, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: theme.textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusBadge(product: product),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.code,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _InfoChip(
                        label: formatCurrency(product.salePrice),
                        icon: Icons.attach_money_rounded,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        label:
                            '${product.stock.toStringAsFixed(0)} ${product.unit.abbreviation}',
                        icon: Icons.inventory_2_outlined,
                        color: isLow
                            ? const Color(0xFFF57F17)
                            : cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: cs.onSurfaceVariant, size: 20),
              onSelected: (v) {
                if (v == 'edit') {
                  context.go(
                      '${AppConstants.routeProductForm}?id=${product.id}');
                }
                if (v == 'stock') {
                  showDialog<void>(
                    context: context,
                    builder: (_) => _StockAdjustDialog(product: product),
                  );
                }
                if (v == 'delete') {
                  showDialog<void>(
                    context: context,
                    builder: (_) => _DeleteConfirmDialog(product: product),
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'stock',
                  child: ListTile(
                    leading: Icon(Icons.tune_rounded),
                    title: Text('Ajustar stock'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline,
                        color: Colors.red),
                    title: Text('Eliminar',
                        style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Row actions widget (for DataTable)
// ---------------------------------------------------------------------------

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.product,
    required this.onEdit,
    required this.onAdjustStock,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onAdjustStock;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Editar',
          child: IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 18, color: cs.primary),
            onPressed: onEdit,
          ),
        ),
        Tooltip(
          message: 'Ajustar stock',
          child: IconButton(
            icon: const Icon(Icons.tune_rounded,
                size: 18, color: Color(0xFF0277BD)),
            onPressed: onAdjustStock,
          ),
        ),
        Tooltip(
          message: 'Eliminar',
          child: IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: Colors.red),
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Product avatar
// ---------------------------------------------------------------------------

class _ProductAvatar extends StatelessWidget {
  const _ProductAvatar({required this.product, this.size = 36});

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (product.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(cs),
        ),
      );
    }
    return _fallback(cs);
  }

  Widget _fallback(ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: size * 0.5,
        color: cs.onPrimaryContainer,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color) _resolve() {
    if (!product.isActive) return ('Inactivo', Colors.grey);
    if (product.isExpired) return ('Vencido', Colors.red);
    if (product.isLowStock) return ('Stock bajo', const Color(0xFFF57F17));
    return ('En stock', const Color(0xFF2E7D32));
  }
}

// ---------------------------------------------------------------------------
// Info chip (used in mobile cards)
// ---------------------------------------------------------------------------

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 72, color: cs.onSurface.withAlpha(60)),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: cs.onSurface.withAlpha(120)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stock adjustment dialog
// ---------------------------------------------------------------------------

class _StockAdjustDialog extends ConsumerStatefulWidget {
  const _StockAdjustDialog({required this.product});

  final Product product;

  @override
  ConsumerState<_StockAdjustDialog> createState() =>
      _StockAdjustDialogState();
}

class _StockAdjustDialogState extends ConsumerState<_StockAdjustDialog> {
  final _deltaController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isAdd = true;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _deltaController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final delta = int.parse(_deltaController.text.trim());
    final reason = _reasonController.text.trim();

    await ref.read(inventoryProvider.notifier).adjustStock(
          widget.product.id,
          _isAdd ? delta : -delta,
          reason,
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock de ${widget.product.name} actualizado.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final product = widget.product;

    return AlertDialog(
      title: const Text('Ajustar Stock'),
      content: SizedBox(
        width: 340,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        color: cs.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name,
                              style: theme.textTheme.titleSmall),
                          Text(
                            'Stock actual: ${product.stock.toStringAsFixed(0)} ${product.unit.abbreviation}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Add / Remove toggle
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Agregar'),
                    icon: Icon(Icons.add_rounded),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Retirar'),
                    icon: Icon(Icons.remove_rounded),
                  ),
                ],
                selected: {_isAdd},
                onSelectionChanged: (s) =>
                    setState(() => _isAdd = s.first),
              ),
              const SizedBox(height: 14),

              // Delta field
              TextFormField(
                controller: _deltaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(
                    _isAdd
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                    color: _isAdd
                        ? const Color(0xFF2E7D32)
                        : cs.error,
                  ),
                  suffixText: product.unit.abbreviation,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Ingrese un número positivo';
                  if (!_isAdd && n > product.stock) {
                    return 'No puede retirar más del stock actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Reason field
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  hintText: 'Ej: Conteo físico, Merma, Recepción…',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Aplicar'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Delete confirm dialog
// ---------------------------------------------------------------------------

class _DeleteConfirmDialog extends ConsumerWidget {
  const _DeleteConfirmDialog({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Eliminar producto'),
      content: Text(
        '¿Estás seguro de que deseas eliminar "${product.name}"?\n\nEsta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: cs.error),
          onPressed: () async {
            Navigator.of(context).pop();
            await ref
                .read(inventoryProvider.notifier)
                .deleteProduct(product.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('"${product.name}" eliminado.')),
              );
            }
          },
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Export dialog
// ---------------------------------------------------------------------------

class _ExportDialog extends StatelessWidget {
  const _ExportDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exportar inventario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined,
                color: Colors.red),
            title: const Text('Exportar como PDF'),
            subtitle: const Text('Genera un reporte imprimible'),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Exportación PDF en desarrollo.')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined,
                color: Color(0xFF2E7D32)),
            title: const Text('Exportar como Excel'),
            subtitle: const Text('Archivo .xlsx editable'),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Exportación Excel en desarrollo.')),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
