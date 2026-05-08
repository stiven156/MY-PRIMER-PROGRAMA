import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// ProductCard – consumer-facing shopping card
// ---------------------------------------------------------------------------

/// Data model for the 8 product categories used in the client app.
enum ClientCategory {
  todos,
  lacteos,
  panaderia,
  abarrotes,
  bebidas,
  limpieza,
  carnes,
  frutas,
}

extension ClientCategoryExtension on ClientCategory {
  String get label {
    switch (this) {
      case ClientCategory.todos:
        return 'Todos';
      case ClientCategory.lacteos:
        return 'Lácteos';
      case ClientCategory.panaderia:
        return 'Panadería';
      case ClientCategory.abarrotes:
        return 'Abarrotes';
      case ClientCategory.bebidas:
        return 'Bebidas';
      case ClientCategory.limpieza:
        return 'Limpieza';
      case ClientCategory.carnes:
        return 'Carnes';
      case ClientCategory.frutas:
        return 'Frutas';
    }
  }

  IconData get icon {
    switch (this) {
      case ClientCategory.todos:
        return Icons.grid_view_rounded;
      case ClientCategory.lacteos:
        return Icons.water_drop_rounded;
      case ClientCategory.panaderia:
        return Icons.breakfast_dining_rounded;
      case ClientCategory.abarrotes:
        return Icons.shopping_basket_rounded;
      case ClientCategory.bebidas:
        return Icons.local_drink_rounded;
      case ClientCategory.limpieza:
        return Icons.clean_hands_rounded;
      case ClientCategory.carnes:
        return Icons.set_meal_rounded;
      case ClientCategory.frutas:
        return Icons.eco_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ClientCategory.todos:
        return const Color(0xFF00695C);
      case ClientCategory.lacteos:
        return const Color(0xFF0288D1);
      case ClientCategory.panaderia:
        return const Color(0xFFE65100);
      case ClientCategory.abarrotes:
        return const Color(0xFF5E35B1);
      case ClientCategory.bebidas:
        return const Color(0xFF00838F);
      case ClientCategory.limpieza:
        return const Color(0xFF00897B);
      case ClientCategory.carnes:
        return const Color(0xFFC62828);
      case ClientCategory.frutas:
        return const Color(0xFF558B2F);
    }
  }
}

// ---------------------------------------------------------------------------
// ProductCard widget
// ---------------------------------------------------------------------------

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.onAddToCart,
  });

  final String name;
  final double price;
  final ClientCategory category;

  /// Quantity in stock; 0 means out of stock.
  final int stock;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final catColor = category.color;
    final isAvailable = stock > 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.outlineVariant.withAlpha(128),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image placeholder ──────────────────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Colored background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        catColor.withAlpha(30),
                        catColor.withAlpha(60),
                      ],
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    size: 48,
                    color: catColor.withAlpha(178),
                  ),
                ),

                // Category chip – top-left
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: catColor.withAlpha(230),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                // Out-of-stock overlay
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha(90),
                      child: const Center(
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation(-0.08),
                          child: Text(
                            'AGOTADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Details ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Price + availability row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00695C),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Stock badge
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAvailable ? 'Disponible' : 'Agotado',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isAvailable
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Add to cart button
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: FilledButton(
                        onPressed: isAvailable ? onAddToCart : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: isAvailable
                              ? const Color(0xFF00695C)
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Icon(Icons.add_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
