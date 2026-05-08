import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/core/utils/formatters.dart';
import 'package:mercados/features/inventory/models/product.dart';
import 'package:mercados/features/inventory/providers/inventory_provider.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const List<String> _kCategories = [
  'Lácteos',
  'Panadería',
  'Abarrotes',
  'Bebidas',
  'Limpieza',
  'Carnes',
  'Frutas y Verduras',
  'Otros',
];

// ═══════════════════════════════════════════════════════════════════════════════
// ProductFormScreen
// ═══════════════════════════════════════════════════════════════════════════════

/// Add/Edit product form screen.
///
/// - Pass [productId] to enter **edit mode** (the existing product is loaded
///   from [inventoryProvider] and all fields are pre-filled).
/// - Pass `null` (or omit) for **create mode**.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  /// When non-null this screen operates in edit mode.
  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  // ── Form infrastructure ───────────────────────────────────────────────────

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isEditMode = false;
  Product? _originalProduct;

  // ── Controllers ───────────────────────────────────────────────────────────

  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _purchasePriceCtrl;
  late final TextEditingController _salePriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _minStockCtrl;
  late final TextEditingController _maxStockCtrl;

  // ── Field state ───────────────────────────────────────────────────────────

  String? _selectedCategory;
  ProductUnit _selectedUnit = ProductUnit.unit;
  DateTime? _expiryDate;
  bool _isActive = true;

  // ── 30 % auto-suggest flag ────────────────────────────────────────────────

  bool _salePriceManuallyEdited = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _barcodeCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _purchasePriceCtrl = TextEditingController();
    _salePriceCtrl = TextEditingController();
    _stockCtrl = TextEditingController();
    _minStockCtrl = TextEditingController();
    _maxStockCtrl = TextEditingController();

    _purchasePriceCtrl.addListener(_onPurchasePriceChanged);

    _isEditMode = widget.productId != null;

    if (_isEditMode) {
      // Pre-fill fields on the first frame once the provider tree is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduct());
    }
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _purchasePriceCtrl
      ..removeListener(_onPurchasePriceChanged)
      ..dispose();
    _salePriceCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    _maxStockCtrl.dispose();
    super.dispose();
  }

  // ── Load product for edit mode ────────────────────────────────────────────

  void _loadProduct() {
    final inventoryState = ref.read(inventoryProvider);
    final product = inventoryState.products.where(
      (p) => p.id == widget.productId,
    ).firstOrNull;

    if (product == null) return;
    _originalProduct = product;

    setState(() {
      _barcodeCtrl.text = product.code;
      _nameCtrl.text = product.name;
      _descriptionCtrl.text = product.description;
      _purchasePriceCtrl.text = product.purchasePrice.toStringAsFixed(2);
      _salePriceCtrl.text = product.salePrice.toStringAsFixed(2);
      _stockCtrl.text = product.stock.toInt().toString();
      _minStockCtrl.text = product.minStock.toInt().toString();
      _maxStockCtrl.text = product.maxStock.toInt().toString();
      _selectedCategory = _kCategories.contains(product.categoryName)
          ? product.categoryName
          : null;
      _selectedUnit = product.unit;
      _expiryDate = product.expiryDate;
      _isActive = product.isActive;
      _salePriceManuallyEdited = true; // Don't override on load.
    });
  }

  // ── Auto-suggest sale price at 30 % margin ────────────────────────────────

  void _onPurchasePriceChanged() {
    if (_salePriceManuallyEdited) return;
    final cost = double.tryParse(_purchasePriceCtrl.text);
    if (cost != null && cost > 0) {
      final suggested = (cost * 1.30);
      _salePriceCtrl.text = suggested.toStringAsFixed(2);
    }
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'Selecciona la fecha de vencimiento',
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final categoryName = _selectedCategory ?? 'Otros';

      final product = Product(
        id: _originalProduct?.id ?? _generateId(),
        code: _barcodeCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        categoryId: _categoryId(categoryName),
        categoryName: categoryName,
        purchasePrice:
            double.tryParse(_purchasePriceCtrl.text) ?? 0.0,
        salePrice: double.tryParse(_salePriceCtrl.text) ?? 0.0,
        stock: double.tryParse(_stockCtrl.text) ?? 0,
        minStock: double.tryParse(_minStockCtrl.text) ?? 0,
        maxStock: double.tryParse(_maxStockCtrl.text) ?? 0,
        unit: _selectedUnit,
        isActive: _isActive,
        expiryDate: _expiryDate,
        createdAt: _originalProduct?.createdAt ?? now,
        updatedAt: now,
      );

      final notifier = ref.read(inventoryProvider.notifier);
      if (_isEditMode) {
        await notifier.updateProduct(product);
      } else {
        await notifier.addProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Producto actualizado correctamente.'
                  : 'Producto creado correctamente.',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _generateId() =>
      'prod-${DateTime.now().millisecondsSinceEpoch}';

  String _categoryId(String categoryName) {
    final index = _kCategories.indexOf(categoryName);
    return index >= 0 ? 'cat-${index + 1}' : 'cat-8';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Editar Producto' : 'Nuevo Producto',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
              height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: Column(
        children: [
          // ── Scrollable form ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section: Identificación ──────────────────────────
                    const _SectionHeader(label: 'Identificación'),
                    const SizedBox(height: 12),

                    // Barcode field (full width)
                    _BarcodeField(controller: _barcodeCtrl),
                    const SizedBox(height: 14),

                    // Name (full width)
                    _FormField(
                      controller: _nameCtrl,
                      label: 'Nombre del producto *',
                      hint: 'Ej. Leche Entera 1L',
                      prefixIcon: Icons.label_outline,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'El nombre es obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Description (full width, multiline)
                    _FormField(
                      controller: _descriptionCtrl,
                      label: 'Descripción',
                      hint: 'Descripción corta del producto...',
                      prefixIcon: Icons.notes,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),

                    // Category + Unit (side by side on wide)
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _CategoryDropdown(
                              value: _selectedCategory,
                              onChanged: (v) =>
                                  setState(() => _selectedCategory = v),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _UnitSelector(
                              value: _selectedUnit,
                              onChanged: (v) =>
                                  setState(() => _selectedUnit = v),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _CategoryDropdown(
                        value: _selectedCategory,
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v),
                      ),
                      const SizedBox(height: 14),
                      _UnitSelector(
                        value: _selectedUnit,
                        onChanged: (v) =>
                            setState(() => _selectedUnit = v),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ── Section: Precios ─────────────────────────────────
                    const _SectionHeader(label: 'Precios'),
                    const SizedBox(height: 12),

                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _PriceField(
                              controller: _purchasePriceCtrl,
                              label: 'Precio de compra *',
                              hint: '0.00',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _SalePriceField(
                              controller: _salePriceCtrl,
                              purchaseCtrl: _purchasePriceCtrl,
                              onManualEdit: () => setState(
                                () => _salePriceManuallyEdited = true,
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _PriceField(
                        controller: _purchasePriceCtrl,
                        label: 'Precio de compra *',
                        hint: '0.00',
                      ),
                      const SizedBox(height: 14),
                      _SalePriceField(
                        controller: _salePriceCtrl,
                        purchaseCtrl: _purchasePriceCtrl,
                        onManualEdit: () => setState(
                          () => _salePriceManuallyEdited = true,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ── Section: Inventario ──────────────────────────────
                    const _SectionHeader(label: 'Inventario'),
                    const SizedBox(height: 12),

                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _IntField(
                              controller: _stockCtrl,
                              label: 'Stock actual *',
                              hint: '0',
                              icon: Icons.inventory_2_outlined,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _IntField(
                              controller: _minStockCtrl,
                              label: 'Stock mínimo *',
                              hint: '0',
                              icon: Icons.arrow_downward,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _IntField(
                              controller: _maxStockCtrl,
                              label: 'Stock máximo',
                              hint: '0',
                              icon: Icons.arrow_upward,
                              required: false,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _IntField(
                        controller: _stockCtrl,
                        label: 'Stock actual *',
                        hint: '0',
                        icon: Icons.inventory_2_outlined,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _IntField(
                              controller: _minStockCtrl,
                              label: 'Stock mínimo *',
                              hint: '0',
                              icon: Icons.arrow_downward,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _IntField(
                              controller: _maxStockCtrl,
                              label: 'Stock máximo',
                              hint: '0',
                              icon: Icons.arrow_upward,
                              required: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ── Section: Adicionales ─────────────────────────────
                    const _SectionHeader(label: 'Adicionales'),
                    const SizedBox(height: 12),

                    // Expiry date picker
                    _ExpiryDatePicker(
                      value: _expiryDate,
                      onPick: _pickExpiryDate,
                      onClear: () =>
                          setState(() => _expiryDate = null),
                    ),
                    const SizedBox(height: 12),

                    // Active toggle
                    _ActiveToggle(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(height: 80), // breathing room above FAB
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom action bar ────────────────────────────────────────────
          _BottomBar(
            isSaving: _isSaving,
            isEditMode: _isEditMode,
            onCancel: () => Navigator.of(context).pop(),
            onSave: _save,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Field widgets
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Divider(height: 1, color: colorScheme.outlineVariant),
      ],
    );
  }
}

// ─── Barcode field ────────────────────────────────────────────────────────────

class _BarcodeField extends StatelessWidget {
  const _BarcodeField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        LengthLimitingTextInputFormatter(20),
      ],
      decoration: InputDecoration(
        labelText: 'Código de barras / SKU',
        hintText: 'Ej. 7501055300427',
        prefixIcon: const Icon(Icons.qr_code),
        suffixIcon: IconButton(
          icon: const Icon(Icons.camera_alt_outlined),
          tooltip: 'Escanear con cámara',
          onPressed: () {
            // TODO: integrate barcode scanner plugin
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Escáner de cámara no configurado en este entorno.'),
              ),
            );
          },
        ),
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.inputBorderRadius)),
      ),
    );
  }
}

// ─── Generic text field ───────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.inputBorderRadius)),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

// ─── Category dropdown ────────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: const Text('Selecciona una categoría'),
      decoration: InputDecoration(
        labelText: 'Categoría *',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.inputBorderRadius)),
      ),
      items: _kCategories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: onChanged,
      validator: (v) =>
          v == null ? 'Selecciona una categoría' : null,
    );
  }
}

// ─── Unit selector ────────────────────────────────────────────────────────────

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({required this.value, required this.onChanged});
  final ProductUnit value;
  final ValueChanged<ProductUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ProductUnit>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Unidad de medida',
        prefixIcon: const Icon(Icons.straighten_outlined),
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.inputBorderRadius)),
      ),
      items: ProductUnit.values
          .map(
            (u) => DropdownMenuItem(
              value: u,
              child: Text(u.displayName),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

// ─── Price field ──────────────────────────────────────────────────────────────

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.attach_money),
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.inputBorderRadius)),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Campo requerido';
        if ((double.tryParse(v) ?? -1) < 0) return 'Precio no válido';
        return null;
      },
    );
  }
}

// ─── Sale price field (with 30 % margin hint) ─────────────────────────────────

class _SalePriceField extends StatelessWidget {
  const _SalePriceField({
    required this.controller,
    required this.purchaseCtrl,
    required this.onManualEdit,
  });

  final TextEditingController controller;
  final TextEditingController purchaseCtrl;
  final VoidCallback onManualEdit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: (_) => onManualEdit(),
      decoration: InputDecoration(
        labelText: 'Precio de venta *',
        hintText: '0.00',
        prefixIcon: const Icon(Icons.sell_outlined),
        helperText: 'Sugerencia automática con margen del 30 %',
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.inputBorderRadius)),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Campo requerido';
        final sale = double.tryParse(v) ?? -1;
        if (sale < 0) return 'Precio no válido';
        final cost = double.tryParse(purchaseCtrl.text) ?? 0;
        if (cost > 0 && sale < cost) {
          return 'El precio de venta es menor al costo';
        }
        return null;
      },
    );
  }
}

// ─── Integer stock field ──────────────────────────────────────────────────────

class _IntField extends StatelessWidget {
  const _IntField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.required = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.inputBorderRadius)),
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Campo requerido';
              }
              if ((int.tryParse(v) ?? -1) < 0) {
                return 'Valor no válido';
              }
              return null;
            }
          : null,
    );
  }
}

// ─── Expiry date picker ───────────────────────────────────────────────────────

class _ExpiryDatePicker extends StatelessWidget {
  const _ExpiryDatePicker({
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onPick,
      borderRadius:
          BorderRadius.circular(AppConstants.inputBorderRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de vencimiento (opcional)',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Quitar fecha',
                  onPressed: onClear,
                )
              : const Icon(Icons.chevron_right),
          border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.inputBorderRadius)),
        ),
        child: Text(
          value != null
              ? formatDate(value!)
              : 'Sin fecha de vencimiento',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: value != null
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─── Active toggle ────────────────────────────────────────────────────────────

class _ActiveToggle extends StatelessWidget {
  const _ActiveToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius:
            BorderRadius.circular(AppConstants.inputBorderRadius),
      ),
      child: Row(
        children: [
          Icon(
            value
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: value
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Producto activo',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  value
                      ? 'Visible y disponible para venta'
                      : 'Oculto y no disponible para venta',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isSaving,
    required this.isEditMode,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final bool isEditMode;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
            top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
            onPressed: isSaving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.buttonBorderRadius)),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(isSaving
                ? 'Guardando...'
                : isEditMode
                    ? 'Guardar Cambios'
                    : 'Crear Producto'),
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.buttonBorderRadius)),
            ),
          ),
        ],
      ),
    );
  }
}
