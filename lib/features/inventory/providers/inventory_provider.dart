import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mercados/features/inventory/models/category.dart';
import 'package:mercados/features/inventory/models/product.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class InventoryState {
  final List<Product> products;
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? selectedCategoryId;
  final bool filterLowStock;

  const InventoryState({
    this.products = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.filterLowStock = false,
  });

  InventoryState copyWith({
    List<Product>? products,
    List<Category>? categories,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
    String? selectedCategoryId,
    bool clearCategory = false,
    bool? filterLowStock,
  }) {
    return InventoryState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      filterLowStock: filterLowStock ?? this.filterLowStock,
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

final _now = DateTime.now();

final List<Category> _sampleCategories = [
  Category(
    id: 'cat-1',
    name: 'Bebidas',
    description: 'Refrescos, jugos y aguas',
    color: '#2196F3',
    iconName: 'local_drink',
    isActive: true,
  ),
  Category(
    id: 'cat-2',
    name: 'Lácteos',
    description: 'Leche, quesos y yogurt',
    color: '#FFF9C4',
    iconName: 'egg_alt',
    isActive: true,
  ),
  Category(
    id: 'cat-3',
    name: 'Panadería',
    description: 'Pan, pasteles y galletas',
    color: '#FFCCBC',
    iconName: 'bakery_dining',
    isActive: true,
  ),
  Category(
    id: 'cat-4',
    name: 'Carnes',
    description: 'Res, cerdo y pollo',
    color: '#FFCDD2',
    iconName: 'set_meal',
    isActive: true,
  ),
  Category(
    id: 'cat-5',
    name: 'Frutas y Verduras',
    description: 'Productos frescos',
    color: '#C8E6C9',
    iconName: 'eco',
    isActive: true,
  ),
  Category(
    id: 'cat-6',
    name: 'Limpieza',
    description: 'Productos de limpieza del hogar',
    color: '#E1BEE7',
    iconName: 'cleaning_services',
    isActive: true,
  ),
  Category(
    id: 'cat-7',
    name: 'Higiene Personal',
    description: 'Cuidado personal',
    color: '#B2EBF2',
    iconName: 'soap',
    isActive: true,
  ),
];

List<Product> _buildSampleProducts() {
  return [
    Product(
      id: 'prod-001',
      code: '7501055300158',
      name: 'Coca-Cola 600ml',
      description: 'Refresco de cola 600 ml',
      categoryId: 'cat-1',
      categoryName: 'Bebidas',
      purchasePrice: 8.50,
      salePrice: 14.00,
      stock: 240,
      minStock: 30,
      maxStock: 500,
      unit: ProductUnit.unit,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 180)),
      updatedAt: _now.subtract(const Duration(days: 2)),
    ),
    Product(
      id: 'prod-002',
      code: '7501055304989',
      name: 'Agua Natural 1.5L',
      description: 'Agua purificada 1.5 litros',
      categoryId: 'cat-1',
      categoryName: 'Bebidas',
      purchasePrice: 5.00,
      salePrice: 9.50,
      stock: 8,
      minStock: 20,
      maxStock: 200,
      unit: ProductUnit.unit,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 120)),
      updatedAt: _now.subtract(const Duration(hours: 5)),
    ),
    Product(
      id: 'prod-003',
      code: '7501003126059',
      name: 'Leche Entera 1L',
      description: 'Leche entera ultrapasteurizada 1 litro',
      categoryId: 'cat-2',
      categoryName: 'Lácteos',
      purchasePrice: 18.00,
      salePrice: 24.00,
      stock: 45,
      minStock: 15,
      maxStock: 120,
      unit: ProductUnit.liter,
      isActive: true,
      expiryDate: _now.add(const Duration(days: 21)),
      createdAt: _now.subtract(const Duration(days: 90)),
      updatedAt: _now.subtract(const Duration(days: 1)),
    ),
    Product(
      id: 'prod-004',
      code: '7503003020162',
      name: 'Yogurt Natural 1kg',
      description: 'Yogurt natural sin azúcar 1 kg',
      categoryId: 'cat-2',
      categoryName: 'Lácteos',
      purchasePrice: 35.00,
      salePrice: 49.00,
      stock: 5,
      minStock: 10,
      maxStock: 60,
      unit: ProductUnit.kg,
      isActive: true,
      expiryDate: _now.add(const Duration(days: 14)),
      createdAt: _now.subtract(const Duration(days: 60)),
      updatedAt: _now.subtract(const Duration(hours: 12)),
    ),
    Product(
      id: 'prod-005',
      code: '7501031300012',
      name: 'Pan Blanco 680g',
      description: 'Pan de caja blanco grande',
      categoryId: 'cat-3',
      categoryName: 'Panadería',
      purchasePrice: 22.00,
      salePrice: 32.00,
      stock: 18,
      minStock: 10,
      maxStock: 80,
      unit: ProductUnit.unit,
      isActive: true,
      expiryDate: _now.add(const Duration(days: 7)),
      createdAt: _now.subtract(const Duration(days: 45)),
      updatedAt: _now.subtract(const Duration(hours: 8)),
    ),
    Product(
      id: 'prod-006',
      code: '7500435008011',
      name: 'Pechuga de Pollo 1kg',
      description: 'Pechuga de pollo fresca por kilogramo',
      categoryId: 'cat-4',
      categoryName: 'Carnes',
      purchasePrice: 65.00,
      salePrice: 95.00,
      stock: 3,
      minStock: 5,
      maxStock: 30,
      unit: ProductUnit.kg,
      isActive: true,
      expiryDate: _now.add(const Duration(days: 4)),
      createdAt: _now.subtract(const Duration(days: 30)),
      updatedAt: _now.subtract(const Duration(hours: 2)),
    ),
    Product(
      id: 'prod-007',
      code: '7501527401055',
      name: 'Manzana Roja 1kg',
      description: 'Manzana roja importada por kilogramo',
      categoryId: 'cat-5',
      categoryName: 'Frutas y Verduras',
      purchasePrice: 28.00,
      salePrice: 39.00,
      stock: 22,
      minStock: 5,
      maxStock: 50,
      unit: ProductUnit.kg,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 15)),
      updatedAt: _now.subtract(const Duration(days: 1)),
    ),
    Product(
      id: 'prod-008',
      code: '7501527400003',
      name: 'Plátano Tabasco 1kg',
      description: 'Plátano tabasco maduro por kilogramo',
      categoryId: 'cat-5',
      categoryName: 'Frutas y Verduras',
      purchasePrice: 12.00,
      salePrice: 18.00,
      stock: 35,
      minStock: 8,
      maxStock: 60,
      unit: ProductUnit.kg,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 10)),
      updatedAt: _now.subtract(const Duration(hours: 6)),
    ),
    Product(
      id: 'prod-009',
      code: '7501035003022',
      name: 'Detergente Líquido 1L',
      description: 'Detergente líquido multiusos 1 litro',
      categoryId: 'cat-6',
      categoryName: 'Limpieza',
      purchasePrice: 32.00,
      salePrice: 48.00,
      stock: 30,
      minStock: 10,
      maxStock: 100,
      unit: ProductUnit.liter,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 200)),
      updatedAt: _now.subtract(const Duration(days: 5)),
    ),
    Product(
      id: 'prod-010',
      code: '7501035005019',
      name: 'Cloro 1L',
      description: 'Cloro concentrado 1 litro',
      categoryId: 'cat-6',
      categoryName: 'Limpieza',
      purchasePrice: 14.00,
      salePrice: 22.00,
      stock: 50,
      minStock: 15,
      maxStock: 120,
      unit: ProductUnit.liter,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 150)),
      updatedAt: _now.subtract(const Duration(days: 3)),
    ),
    Product(
      id: 'prod-011',
      code: '7501001609014',
      name: 'Shampoo 400ml',
      description: 'Shampoo para cabello normal 400 ml',
      categoryId: 'cat-7',
      categoryName: 'Higiene Personal',
      purchasePrice: 38.00,
      salePrice: 55.00,
      stock: 20,
      minStock: 8,
      maxStock: 60,
      unit: ProductUnit.unit,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 80)),
      updatedAt: _now.subtract(const Duration(days: 7)),
    ),
    Product(
      id: 'prod-012',
      code: '7501001600103',
      name: 'Jabón de Barra x3',
      description: 'Jabón de tocador pack de 3 piezas',
      categoryId: 'cat-7',
      categoryName: 'Higiene Personal',
      purchasePrice: 20.00,
      salePrice: 32.00,
      stock: 2,
      minStock: 10,
      maxStock: 80,
      unit: ProductUnit.box,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 60)),
      updatedAt: _now.subtract(const Duration(hours: 1)),
    ),
    Product(
      id: 'prod-013',
      code: '7506305009013',
      name: 'Arroz Blanco 1kg',
      description: 'Arroz de grano largo 1 kilogramo',
      categoryId: 'cat-5',
      categoryName: 'Frutas y Verduras',
      purchasePrice: 18.00,
      salePrice: 26.00,
      stock: 75,
      minStock: 20,
      maxStock: 200,
      unit: ProductUnit.kg,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 100)),
      updatedAt: _now.subtract(const Duration(days: 4)),
    ),
    Product(
      id: 'prod-014',
      code: '7501055305016',
      name: 'Jugo de Naranja 1L',
      description: 'Jugo de naranja 100% natural 1 litro',
      categoryId: 'cat-1',
      categoryName: 'Bebidas',
      purchasePrice: 22.00,
      salePrice: 34.00,
      stock: 12,
      minStock: 15,
      maxStock: 80,
      unit: ProductUnit.liter,
      isActive: true,
      expiryDate: _now.add(const Duration(days: 30)),
      createdAt: _now.subtract(const Duration(days: 50)),
      updatedAt: _now.subtract(const Duration(hours: 10)),
    ),
    Product(
      id: 'prod-015',
      code: '7502003008018',
      name: 'Queso Manchego 400g',
      description: 'Queso manchego rebanado 400 gramos',
      categoryId: 'cat-2',
      categoryName: 'Lácteos',
      purchasePrice: 55.00,
      salePrice: 78.00,
      stock: 9,
      minStock: 5,
      maxStock: 40,
      unit: ProductUnit.unit,
      isActive: true,
      expiryDate: _now.add(const Duration(days: 45)),
      createdAt: _now.subtract(const Duration(days: 40)),
      updatedAt: _now.subtract(const Duration(days: 2)),
    ),
    Product(
      id: 'prod-016',
      code: '7501031100231',
      name: 'Galletas de Avena 420g',
      description: 'Galletas integrales de avena 420 gramos',
      categoryId: 'cat-3',
      categoryName: 'Panadería',
      purchasePrice: 28.00,
      salePrice: 42.00,
      stock: 38,
      minStock: 10,
      maxStock: 100,
      unit: ProductUnit.unit,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 70)),
      updatedAt: _now.subtract(const Duration(days: 6)),
    ),
    Product(
      id: 'prod-017',
      code: '7500435010014',
      name: 'Carne Molida 500g',
      description: 'Carne molida de res 500 gramos',
      categoryId: 'cat-4',
      categoryName: 'Carnes',
      purchasePrice: 55.00,
      salePrice: 82.00,
      stock: 4,
      minStock: 5,
      maxStock: 25,
      unit: ProductUnit.unit,
      isActive: true,
      expiryDate: _now.add(const Duration(days: 3)),
      createdAt: _now.subtract(const Duration(days: 20)),
      updatedAt: _now.subtract(const Duration(hours: 3)),
    ),
    Product(
      id: 'prod-018',
      code: '7501035010011',
      name: 'Suavizante de Ropa 1L',
      description: 'Suavizante de telas aroma lavanda 1 litro',
      categoryId: 'cat-6',
      categoryName: 'Limpieza',
      purchasePrice: 28.00,
      salePrice: 42.00,
      stock: 25,
      minStock: 8,
      maxStock: 80,
      unit: ProductUnit.liter,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 110)),
      updatedAt: _now.subtract(const Duration(days: 9)),
    ),
    Product(
      id: 'prod-019',
      code: '7501001617003',
      name: 'Pasta de Dientes 75ml',
      description: 'Pasta dental blanqueadora 75 ml',
      categoryId: 'cat-7',
      categoryName: 'Higiene Personal',
      purchasePrice: 22.00,
      salePrice: 34.00,
      stock: 30,
      minStock: 10,
      maxStock: 80,
      unit: ProductUnit.unit,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 55)),
      updatedAt: _now.subtract(const Duration(days: 8)),
    ),
    Product(
      id: 'prod-020',
      code: '7502001107038',
      name: 'Café Molido 500g',
      description: 'Café molido de tueste oscuro 500 gramos',
      categoryId: 'cat-1',
      categoryName: 'Bebidas',
      purchasePrice: 68.00,
      salePrice: 98.00,
      stock: 16,
      minStock: 5,
      maxStock: 60,
      unit: ProductUnit.unit,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 130)),
      updatedAt: _now.subtract(const Duration(days: 11)),
    ),
  ];
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier() : super(const InventoryState()) {
    loadProducts();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // TODO(supabase): replace with
    //   final data = await supabase.from('products').select().order('name');
    //   final products = data.map(Product.fromJson).toList();
    //   final catData = await supabase.from('categories').select();
    //   final categories = catData.map(Category.fromJson).toList();
    state = state.copyWith(
      products: _buildSampleProducts(),
      categories: _sampleCategories,
      isLoading: false,
    );
  }

  // ── Search & Filter ───────────────────────────────────────────────────────

  void searchProducts(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void filterByCategory(String? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    );
  }

  void setLowStockFilter({required bool enabled}) {
    state = state.copyWith(filterLowStock: enabled);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addProduct(Product product) async {
    // TODO(supabase): await supabase.from('products').insert(product.toJson());
    final updated = [...state.products, product];
    state = state.copyWith(products: updated);
  }

  Future<void> updateProduct(Product product) async {
    // TODO(supabase): await supabase.from('products').update(product.toJson()).eq('id', product.id);
    final updated = state.products
        .map((p) => p.id == product.id ? product : p)
        .toList();
    state = state.copyWith(products: updated);
  }

  Future<void> deleteProduct(String id) async {
    // TODO(supabase): await supabase.from('products').delete().eq('id', id);
    final updated = state.products.where((p) => p.id != id).toList();
    state = state.copyWith(products: updated);
  }

  // ── Stock Adjustment ──────────────────────────────────────────────────────

  /// Adjusts the stock of [productId] by [delta] (positive = add, negative = remove).
  /// [reason] is a free-text note (e.g. "Conteo físico", "Merma").
  Future<void> adjustStock(
    String productId,
    int delta,
    String reason,
  ) async {
    final index = state.products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final product = state.products[index];
    final newStock = (product.stock + delta).clamp(0.0, 999999.0);

    // TODO(supabase): log adjustment to stock_movements table
    //   await supabase.from('stock_movements').insert({
    //     'product_id': productId,
    //     'delta': delta,
    //     'reason': reason,
    //     'created_at': DateTime.now().toIso8601String(),
    //   });
    //   await supabase.from('products').update({'stock': newStock}).eq('id', productId);

    final updated = [...state.products];
    updated[index] = product.copyWith(
      stock: newStock,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(products: updated);
  }

  // ── Computed Getters ──────────────────────────────────────────────────────

  List<Product> get lowStockProducts =>
      state.products.where((p) => p.isLowStock).toList();

  List<Product> get filteredProducts {
    var list = state.products;

    if (state.filterLowStock) {
      list = list.where((p) => p.isLowStock).toList();
    }

    if (state.selectedCategoryId != null) {
      list = list
          .where((p) => p.categoryId == state.selectedCategoryId)
          .toList();
    }

    final q = state.searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.code.toLowerCase().contains(q) ||
              p.categoryName.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>(
  (ref) => InventoryNotifier(),
);

/// Convenience provider exposing only the filtered product list.
final filteredProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(inventoryProvider.notifier).filteredProducts;
});

/// Convenience provider exposing only the low-stock list.
final lowStockProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(inventoryProvider.notifier).lowStockProducts;
});

/// Exposes the categories list from inventory state.
final categoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(inventoryProvider).categories;
});
