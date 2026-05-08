import 'package:mercados/features/inventory/models/product.dart';

class CartItem {
  final Product product;
  final double quantity;

  /// Unit price captured at the moment the item was added to the cart.
  /// Stored separately from [product.salePrice] so price changes do not
  /// retroactively affect open or historical carts.
  final double unitPrice;

  /// Discount percentage applied to this line item (0–100).
  final double discount;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  }) : assert(
          discount >= 0 && discount <= 100,
          'discount must be between 0 and 100',
        );

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// Gross line total before discount: quantity × unitPrice.
  double get subtotal => quantity * unitPrice;

  /// Monetary amount saved by the discount on this line item.
  double get discountAmount => subtotal * (discount / 100);

  /// Net amount the customer pays for this line item after the discount.
  double get total => subtotal - discountAmount;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  CartItem copyWith({
    Product? product,
    double? quantity,
    double? unitPrice,
    double? discount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discount: (json['discount'] as num? ?? 0).toDouble(),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.product == product &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice &&
        other.discount == discount;
  }

  @override
  int get hashCode => Object.hash(product, quantity, unitPrice, discount);

  @override
  String toString() {
    return 'CartItem(product: ${product.name}, quantity: $quantity, '
        'unitPrice: $unitPrice, discount: $discount%, total: $total)';
  }
}
