enum ProductUnit { unit, kg, liter, box }

extension ProductUnitExtension on ProductUnit {
  String get displayName {
    switch (this) {
      case ProductUnit.unit:
        return 'Unidad';
      case ProductUnit.kg:
        return 'Kilogramo';
      case ProductUnit.liter:
        return 'Litro';
      case ProductUnit.box:
        return 'Caja';
    }
  }

  String get abbreviation {
    switch (this) {
      case ProductUnit.unit:
        return 'u';
      case ProductUnit.kg:
        return 'kg';
      case ProductUnit.liter:
        return 'L';
      case ProductUnit.box:
        return 'cja';
    }
  }

  String get value {
    switch (this) {
      case ProductUnit.unit:
        return 'unit';
      case ProductUnit.kg:
        return 'kg';
      case ProductUnit.liter:
        return 'liter';
      case ProductUnit.box:
        return 'box';
    }
  }

  static ProductUnit fromString(String value) {
    switch (value) {
      case 'unit':
        return ProductUnit.unit;
      case 'kg':
        return ProductUnit.kg;
      case 'liter':
        return ProductUnit.liter;
      case 'box':
        return ProductUnit.box;
      default:
        throw ArgumentError('Unknown ProductUnit: "$value"');
    }
  }
}

class Product {
  final String id;

  /// Barcode / SKU used to identify the product at point of sale.
  final String code;

  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final double purchasePrice;
  final double salePrice;
  final double stock;
  final double minStock;
  final double maxStock;
  final ProductUnit unit;

  /// Optional URL pointing to the product image.
  final String? imageUrl;

  final bool isActive;

  /// Nullable — not all products have an expiry date.
  final DateTime? expiryDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
    required this.minStock,
    required this.maxStock,
    required this.unit,
    this.imageUrl,
    required this.isActive,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// Profit margin as a percentage:
  ///   ((salePrice - purchasePrice) / purchasePrice) × 100
  /// Returns 0.0 when [purchasePrice] is 0 to avoid division by zero.
  double get margin {
    if (purchasePrice == 0) return 0;
    return ((salePrice - purchasePrice) / purchasePrice) * 100;
  }

  /// True when current stock is at or below the minimum stock threshold.
  bool get isLowStock => stock <= minStock;

  /// True when the product has an expiry date set in the past.
  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy with the given fields replaced.
  /// Pass [clearImageUrl] = true to explicitly null out [imageUrl].
  /// Pass [clearExpiryDate] = true to explicitly null out [expiryDate].
  Product copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    double? purchasePrice,
    double? salePrice,
    double? stock,
    double? minStock,
    double? maxStock,
    ProductUnit? unit,
    String? imageUrl,
    bool? isActive,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearImageUrl = false,
    bool clearExpiryDate = false,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      unit: unit ?? this.unit,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      isActive: isActive ?? this.isActive,
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'stock': stock,
      'minStock': minStock,
      'maxStock': maxStock,
      'unit': unit.value,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'expiryDate': expiryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      stock: (json['stock'] as num).toDouble(),
      minStock: (json['minStock'] as num).toDouble(),
      maxStock: (json['maxStock'] as num).toDouble(),
      unit: ProductUnitExtension.fromString(json['unit'] as String),
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.code == code &&
        other.name == name &&
        other.description == description &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.purchasePrice == purchasePrice &&
        other.salePrice == salePrice &&
        other.stock == stock &&
        other.minStock == minStock &&
        other.maxStock == maxStock &&
        other.unit == unit &&
        other.imageUrl == imageUrl &&
        other.isActive == isActive &&
        other.expiryDate == expiryDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      code,
      name,
      description,
      categoryId,
      categoryName,
      purchasePrice,
      salePrice,
      stock,
      minStock,
      maxStock,
      unit,
      imageUrl,
      isActive,
      expiryDate,
      createdAt,
      updatedAt,
    ]);
  }

  @override
  String toString() {
    return 'Product(id: $id, code: $code, name: $name, '
        'salePrice: $salePrice, stock: $stock, '
        'unit: ${unit.value}, isActive: $isActive)';
  }
}
