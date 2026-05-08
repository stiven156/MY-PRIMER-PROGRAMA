import 'package:flutter/material.dart';

import 'package:mercados/features/inventory/models/product.dart';
import 'package:mercados/core/utils/formatters.dart';

/// A compact grid card that represents a single product in the POS search
/// results.
///
/// - Top section: colour-coded icon area derived from the product category.
///   A stock badge is overlaid in the top-right corner when stock is low or
///   exhausted.
/// - Bottom section: product name (max 2 lines) and sale price in green.
///
/// When [product.stock] is zero the tile is dimmed and [onTap] is disabled.
class ProductSearchTile extends StatelessWidget {
  const ProductSearchTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  // ── Category style mapping ───────────────────────────────────────────────────

  static const Map<String, _CategoryStyle> _categoryStyles = {
    'Lácteos': _CategoryStyle(
      color: Color(0xFFFFF9C4),
      icon: Icons.egg_alt,
    ),
    'Panadería': _CategoryStyle(
      color: Color(0xFFFFE0B2),
      icon: Icons.bakery_dining,
    ),
    'Abarrotes': _CategoryStyle(
      color: Color(0xFFE8F5E9),
      icon: Icons.shopping_basket,
    ),
    'Bebidas': _CategoryStyle(
      color: Color(0xFFE3F2FD),
      icon: Icons.local_drink,
    ),
    'Limpieza': _CategoryStyle(
      color: Color(0xFFF3E5F5),
      icon: Icons.cleaning_services,
    ),
    'Carnes': _CategoryStyle(
      color: Color(0xFFFFCDD2),
      icon: Icons.set_meal,
    ),
    'Frutas y Verduras': _CategoryStyle(
      color: Color(0xFFC8E6C9),
      icon: Icons.eco,
    ),
    'Higiene Personal': _CategoryStyle(
      color: Color(0xFFE0F7FA),
      icon: Icons.soap,
    ),
    'Otros': _CategoryStyle(
      color: Color(0xFFEEEEEE),
      icon: Icons.category,
    ),
  };

  static const _CategoryStyle _fallbackStyle = _CategoryStyle(
    color: Color(0xFFEEEEEE),
    icon: Icons.inventory_2,
  );

  _CategoryStyle _styleFor(String categoryName) {
    for (final entry in _categoryStyles.entries) {
      if (categoryName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return _fallbackStyle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = _styleFor(product.categoryName);

    final bool outOfStock = product.stock <= 0;
    final bool lowStock = product.stock > 0 && product.stock < 5;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: outOfStock
              ? colorScheme.errorContainer
              : colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: outOfStock ? null : onTap,
        splashColor: style.color.withAlpha(160),
        highlightColor: style.color.withAlpha(80),
        child: Opacity(
          opacity: outOfStock ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Coloured icon band ────────────────────────────────────────
              Expanded(
                flex: 5,
                child: Container(
                  color: style.color,
                  child: Stack(
                    children: [
                      // Category icon centred
                      Center(
                        child: Icon(
                          style.icon,
                          size: 36,
                          color: Color.lerp(style.color, Colors.black87, 0.6),
                        ),
                      ),
                      // Stock badge overlay
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _StockBadge(
                          stock: product.stock,
                          lowStock: lowStock,
                          outOfStock: outOfStock,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Name + price section ──────────────────────────────────────
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product name (2-line max)
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      // Sale price
                      Text(
                        formatCurrency(product.salePrice),
                        style: theme.textTheme.labelMedium!.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ────────────────────────────────────────────────────────────

/// Immutable style data carried per product category.
class _CategoryStyle {
  const _CategoryStyle({required this.color, required this.icon});
  final Color color;
  final IconData icon;
}

/// Overlay badge shown only when stock is low (< 5) or exhausted.
class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.stock,
    required this.lowStock,
    required this.outOfStock,
  });

  final double stock;
  final bool lowStock;
  final bool outOfStock;

  @override
  Widget build(BuildContext context) {
    if (!lowStock && !outOfStock) return const SizedBox.shrink();

    final Color bg = outOfStock
        ? Theme.of(context).colorScheme.error
        : const Color(0xFFE65100); // deep orange

    final String label =
        outOfStock ? 'Sin stock' : 'Stock: ${stock.toInt()}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
