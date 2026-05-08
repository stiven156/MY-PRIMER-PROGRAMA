import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/features/client_app/widgets/product_card.dart';

// ---------------------------------------------------------------------------
// Data models (local, no provider needed)
// ---------------------------------------------------------------------------

class _ClientProduct {
  const _ClientProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
  });
  final int id;
  final String name;
  final double price;
  final ClientCategory category;
  final int stock;
}

class _CartEntry {
  _CartEntry({required this.product});
  final _ClientProduct product;
  int quantity = 1;
}

class _PastOrder {
  const _PastOrder({
    required this.number,
    required this.date,
    required this.itemsSummary,
    required this.total,
    required this.status,
  });
  final String number;
  final String date;
  final String itemsSummary;
  final double total;
  final _OrderStatus status;
}

enum _OrderStatus { entregado, enCamino, preparando, cancelado }

extension _OrderStatusExt on _OrderStatus {
  String get label {
    switch (this) {
      case _OrderStatus.entregado:
        return 'Entregado';
      case _OrderStatus.enCamino:
        return 'En camino';
      case _OrderStatus.preparando:
        return 'Preparando';
      case _OrderStatus.cancelado:
        return 'Cancelado';
    }
  }

  Color get color {
    switch (this) {
      case _OrderStatus.entregado:
        return const Color(0xFF2E7D32);
      case _OrderStatus.enCamino:
        return const Color(0xFF0277BD);
      case _OrderStatus.preparando:
        return const Color(0xFFF57F17);
      case _OrderStatus.cancelado:
        return const Color(0xFFC62828);
    }
  }

  IconData get icon {
    switch (this) {
      case _OrderStatus.entregado:
        return Icons.check_circle_rounded;
      case _OrderStatus.enCamino:
        return Icons.delivery_dining_rounded;
      case _OrderStatus.preparando:
        return Icons.restaurant_rounded;
      case _OrderStatus.cancelado:
        return Icons.cancel_rounded;
    }
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

const List<_ClientProduct> _kProducts = [
  _ClientProduct(id: 1,  name: 'Leche Entera 1L',         price: 1.25,  category: ClientCategory.lacteos,   stock: 40),
  _ClientProduct(id: 2,  name: 'Yogur Natural 500g',       price: 1.80,  category: ClientCategory.lacteos,   stock: 25),
  _ClientProduct(id: 3,  name: 'Queso Fresco 250g',        price: 2.50,  category: ClientCategory.lacteos,   stock: 18),
  _ClientProduct(id: 4,  name: 'Pan de Molde 600g',        price: 1.50,  category: ClientCategory.panaderia, stock: 30),
  _ClientProduct(id: 5,  name: 'Croissant x6',             price: 2.20,  category: ClientCategory.panaderia, stock: 15),
  _ClientProduct(id: 6,  name: 'Pan Integral 500g',        price: 1.75,  category: ClientCategory.panaderia, stock: 22),
  _ClientProduct(id: 7,  name: 'Arroz Extra 2kg',          price: 2.80,  category: ClientCategory.abarrotes, stock: 60),
  _ClientProduct(id: 8,  name: 'Aceite Vegetal 1L',        price: 3.20,  category: ClientCategory.abarrotes, stock: 35),
  _ClientProduct(id: 9,  name: 'Azúcar Blanca 1kg',        price: 1.10,  category: ClientCategory.abarrotes, stock: 50),
  _ClientProduct(id: 10, name: 'Frijoles Negros 500g',     price: 1.40,  category: ClientCategory.abarrotes, stock: 0),
  _ClientProduct(id: 11, name: 'Coca-Cola 600ml',          price: 0.90,  category: ClientCategory.bebidas,   stock: 80),
  _ClientProduct(id: 12, name: 'Agua Mineral 1.5L',        price: 0.75,  category: ClientCategory.bebidas,   stock: 100),
  _ClientProduct(id: 13, name: 'Jugo de Naranja 1L',       price: 1.60,  category: ClientCategory.bebidas,   stock: 20),
  _ClientProduct(id: 14, name: 'Café Molido 250g',         price: 3.50,  category: ClientCategory.abarrotes, stock: 28),
  _ClientProduct(id: 15, name: 'Detergente 1kg',           price: 2.90,  category: ClientCategory.limpieza,  stock: 40),
  _ClientProduct(id: 16, name: 'Jabón Líquido 500ml',      price: 1.95,  category: ClientCategory.limpieza,  stock: 33),
  _ClientProduct(id: 17, name: 'Pollo Entero 1.5kg',       price: 6.50,  category: ClientCategory.carnes,    stock: 12),
  _ClientProduct(id: 18, name: 'Carne Molida 500g',        price: 4.20,  category: ClientCategory.carnes,    stock: 0),
  _ClientProduct(id: 19, name: 'Manzanas Rojas x6',        price: 2.10,  category: ClientCategory.frutas,    stock: 45),
  _ClientProduct(id: 20, name: 'Bananos x6',               price: 0.80,  category: ClientCategory.frutas,    stock: 55),
];

const List<_PastOrder> _kPastOrders = [
  _PastOrder(
    number: '#001234',
    date: '05/05/2026',
    itemsSummary: 'Leche Entera, Pan de Molde, Arroz Extra (+2 más)',
    total: 7.80,
    status: _OrderStatus.entregado,
  ),
  _PastOrder(
    number: '#001198',
    date: '01/05/2026',
    itemsSummary: 'Coca-Cola x2, Pollo Entero, Detergente',
    total: 11.20,
    status: _OrderStatus.enCamino,
  ),
  _PastOrder(
    number: '#001150',
    date: '25/04/2026',
    itemsSummary: 'Manzanas Rojas, Yogur Natural, Pan Integral',
    total: 5.65,
    status: _OrderStatus.cancelado,
  ),
];

// ---------------------------------------------------------------------------
// ClientAppScreen
// ---------------------------------------------------------------------------

class ClientAppScreen extends StatefulWidget {
  const ClientAppScreen({super.key});

  @override
  State<ClientAppScreen> createState() => _ClientAppScreenState();
}

class _ClientAppScreenState extends State<ClientAppScreen> {
  int _selectedTab = 0;
  final _searchCtrl = TextEditingController();
  ClientCategory _selectedCategory = ClientCategory.todos;
  String _searchQuery = '';

  // Cart state
  final List<_CartEntry> _cart = [];
  bool _isDelivery = true;
  final _addressCtrl = TextEditingController();

  // Profile
  static const String _userName = 'María García';
  static const String _userEmail = 'maria.garcia@email.com';
  static const int _userPoints = 320;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ── Cart helpers ────────────────────────────────────────────────────────────

  int get _cartCount =>
      _cart.fold(0, (sum, e) => sum + e.quantity);

  double get _cartSubtotal =>
      _cart.fold(0, (sum, e) => sum + e.product.price * e.quantity);

  double get _deliveryFee => _isDelivery ? 2.50 : 0.0;

  double get _cartTotal => _cartSubtotal + _deliveryFee;

  void _addToCart(_ClientProduct product) {
    setState(() {
      final existing = _cart.where((e) => e.product.id == product.id);
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        _cart.add(_CartEntry(product: product));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        duration: AppConstants.toastDuration,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ver carrito',
          onPressed: () => setState(() => _selectedTab = 1),
        ),
      ),
    );
  }

  void _incrementCart(_CartEntry entry) =>
      setState(() => entry.quantity++);

  void _decrementCart(_CartEntry entry) {
    setState(() {
      if (entry.quantity <= 1) {
        _cart.remove(entry);
      } else {
        entry.quantity--;
      }
    });
  }

  void _removeFromCart(_CartEntry entry) =>
      setState(() => _cart.remove(entry));

  void _placeOrder() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_cart.length} producto${_cart.length == 1 ? '' : 's'} · '
              '${_isDelivery ? 'Entrega a domicilio' : 'Recoger en tienda'}',
            ),
            const SizedBox(height: 8),
            if (_isDelivery && _addressCtrl.text.isNotEmpty)
              Text(
                'Dirección: ${_addressCtrl.text}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('\$${_cartSubtotal.toStringAsFixed(2)}'),
              ],
            ),
            if (_isDelivery) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Envío'),
                  Text('\$${_deliveryFee.toStringAsFixed(2)}'),
                ],
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '\$${_cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00695C),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _cart.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Pedido realizado con éxito!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Confirmar pedido'),
          ),
        ],
      ),
    );
  }

  // ── Filtered products ───────────────────────────────────────────────────────

  List<_ClientProduct> get _filteredProducts {
    return _kProducts.where((p) {
      final matchesCategory = _selectedCategory == ClientCategory.todos ||
          p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildShopTab(),
          _buildCartTab(),
          _buildOrdersTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) => setState(() => _selectedTab = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Mi Carrito',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Mis Pedidos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Mi Perfil',
          ),
        ],
      ),
    );
  }

  // ── TAB 1: Shop ─────────────────────────────────────────────────────────────

  Widget _buildShopTab() {
    final filtered = _filteredProducts;

    return SafeArea(
      child: Column(
        children: [
          // Green gradient header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00695C), Color(0xFF004D40)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.store_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'MERCADOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hola, María! ¿Qué necesitas hoy?',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.grey),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),

          // Categories horizontal scroll
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: ClientCategory.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = ClientCategory.values[i];
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: AppConstants.animationFast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? cat.color : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? cat.color
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat.icon,
                          size: 14,
                          color: selected ? Colors.white : cat.color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : cat.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Products count
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} producto${filtered.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Product grid
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No se encontraron productos',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      return ProductCard(
                        name: p.name,
                        price: p.price,
                        category: p.category,
                        stock: p.stock,
                        onAddToCart: () => _addToCart(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── TAB 2: Cart ─────────────────────────────────────────────────────────────

  Widget _buildCartTab() {
    return SafeArea(
      child: Column(
        children: [
          // App bar
          _ClientAppBar(
            title: 'Mi Carrito',
            subtitle: '$_cartCount artículo${_cartCount == 1 ? '' : 's'}',
            icon: Icons.shopping_cart_rounded,
          ),

          if (_cart.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Tu carrito está vacío',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Agrega productos desde la tienda',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Cart items
                  ..._cart.map((entry) => _CartItemTile(
                        entry: entry,
                        onIncrement: () => _incrementCart(entry),
                        onDecrement: () => _decrementCart(entry),
                        onRemove: () => _removeFromCart(entry),
                      )),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Delivery / Pickup selector
                  const Text(
                    'Tipo de entrega',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DeliverySelector(
                    isDelivery: _isDelivery,
                    onChanged: (v) => setState(() => _isDelivery = v),
                  ),

                  if (_isDelivery) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dirección de entrega',
                        hintText: 'Calle, número, referencia...',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Order summary
                  _OrderSummary(
                    subtotal: _cartSubtotal,
                    deliveryFee: _deliveryFee,
                    isDelivery: _isDelivery,
                    total: _cartTotal,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Place order button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: (_isDelivery && _addressCtrl.text.trim().isEmpty)
                      ? null
                      : _placeOrder,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                  ),
                  icon: const Icon(Icons.shopping_bag_rounded, size: 20),
                  label: Text(
                    'Realizar pedido  •  \$${_cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── TAB 3: Orders ──────────────────────────────────────────────────────────

  Widget _buildOrdersTab() {
    return SafeArea(
      child: Column(
        children: [
          const _ClientAppBar(
            title: 'Mis Pedidos',
            subtitle: 'Historial de compras',
            icon: Icons.receipt_long_rounded,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _kPastOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _PastOrderCard(order: _kPastOrders[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 4: Profile ─────────────────────────────────────────────────────────

  Widget _buildProfileTab() {
    final cs = Theme.of(context).colorScheme;
    final initials = _userName
        .split(' ')
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        children: [
          const SizedBox(height: 20),

          // Avatar + name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF00695C),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  _userName,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: TextStyle(
                      fontSize: 13, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),

                // Points display
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                          color: Color(0xFFF9A825), size: 20),
                      SizedBox(width: 6),
                      Text(
                        '$_userPoints puntos acumulados',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF57F17),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Profile options
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _ProfileOption(
                  icon: Icons.person_outline_rounded,
                  label: 'Editar perfil',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _ProfileOption(
                  icon: Icons.location_on_outlined,
                  label: 'Mis direcciones',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _ProfileOption(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _ProfileOption(
                  icon: Icons.help_outline_rounded,
                  label: 'Ayuda y soporte',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sign out
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                        '¿Estás seguro de que deseas cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go(AppConstants.routeLogin);
                        },
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error.withAlpha(128)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Cerrar sesión'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared internal widgets
// ---------------------------------------------------------------------------

class _ClientAppBar extends StatelessWidget {
  const _ClientAppBar({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withAlpha(128)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00695C), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cart item tile
// ---------------------------------------------------------------------------

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final _CartEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final catColor = entry.product.category.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withAlpha(128)),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: catColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(entry.product.category.icon,
                color: catColor, size: 22),
          ),
          const SizedBox(width: 12),

          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${(entry.product.price * entry.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00695C),
                  ),
                ),
              ],
            ),
          ),

          // Qty controls
          Row(
            children: [
              _QtyButton(
                icon: Icons.remove_rounded,
                onPressed: onDecrement,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${entry.quantity}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              _QtyButton(
                icon: Icons.add_rounded,
                onPressed: onIncrement,
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline_rounded,
                    size: 18, color: cs.error),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(
              color:
                  Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delivery selector
// ---------------------------------------------------------------------------

class _DeliverySelector extends StatelessWidget {
  const _DeliverySelector({
    required this.isDelivery,
    required this.onChanged,
  });

  final bool isDelivery;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DeliveryOption(
            icon: Icons.delivery_dining_rounded,
            label: 'Entrega a domicilio',
            sublabel: '+\$2.50',
            selected: isDelivery,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DeliveryOption(
            icon: Icons.storefront_rounded,
            label: 'Recoger en tienda',
            sublabel: 'Gratis',
            selected: !isDelivery,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  const _DeliveryOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF00695C).withAlpha(20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF00695C)
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 22,
                color: selected
                    ? const Color(0xFF00695C)
                    : Colors.grey),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? const Color(0xFF00695C)
                    : Colors.grey.shade700,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: selected
                    ? const Color(0xFF00695C)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order summary
// ---------------------------------------------------------------------------

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.isDelivery,
    required this.total,
  });

  final double subtotal;
  final double deliveryFee;
  final bool isDelivery;
  final double total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${subtotal.toStringAsFixed(2)}',
          ),
          if (isDelivery) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Envío a domicilio',
              value: '\$${deliveryFee.toStringAsFixed(2)}',
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00695C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14, color: cs.onSurfaceVariant)),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Past order card
// ---------------------------------------------------------------------------

class _PastOrderCard extends StatelessWidget {
  const _PastOrderCard({required this.order});
  final _PastOrder order;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order.number,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.status.color.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(order.status.icon,
                          size: 13, color: order.status.color),
                      const SizedBox(width: 4),
                      Text(
                        order.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: order.status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  order.date,
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.itemsSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Ver detalle'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00695C),
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
// Profile option row
// ---------------------------------------------------------------------------

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00695C), size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: cs.onSurfaceVariant, size: 20),
      onTap: onTap,
    );
  }
}
