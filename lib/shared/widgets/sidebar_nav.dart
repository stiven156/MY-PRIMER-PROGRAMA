import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/features/auth/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// Navigation destination model
// ---------------------------------------------------------------------------

class _NavItem {
  final String label;
  final IconData icon;
  final IconData iconSelected;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.iconSelected,
    required this.route,
  });
}

/// Full ordered list of nav destinations shown in the sidebar.
const List<_NavItem> _navItems = [
  _NavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    iconSelected: Icons.dashboard_rounded,
    route: AppConstants.routeDashboard,
  ),
  _NavItem(
    label: 'Punto de Venta',
    icon: Icons.point_of_sale_outlined,
    iconSelected: Icons.point_of_sale_rounded,
    route: AppConstants.routePOS,
  ),
  _NavItem(
    label: 'Inventario',
    icon: Icons.inventory_2_outlined,
    iconSelected: Icons.inventory_2_rounded,
    route: AppConstants.routeInventory,
  ),
  _NavItem(
    label: 'Compras',
    icon: Icons.shopping_cart_outlined,
    iconSelected: Icons.shopping_cart_rounded,
    route: AppConstants.routePurchases,
  ),
  _NavItem(
    label: 'Proveedores',
    icon: Icons.local_shipping_outlined,
    iconSelected: Icons.local_shipping_rounded,
    route: AppConstants.routeSuppliers,
  ),
  _NavItem(
    label: 'Clientes',
    icon: Icons.people_outline_rounded,
    iconSelected: Icons.people_rounded,
    route: AppConstants.routeCustomers,
  ),
  _NavItem(
    label: 'Empleados',
    icon: Icons.badge_outlined,
    iconSelected: Icons.badge_rounded,
    route: AppConstants.routeEmployees,
  ),
  _NavItem(
    label: 'Pedidos',
    icon: Icons.receipt_long_outlined,
    iconSelected: Icons.receipt_long_rounded,
    route: AppConstants.routeOrders,
  ),
  _NavItem(
    label: 'Reportes',
    icon: Icons.bar_chart_outlined,
    iconSelected: Icons.bar_chart_rounded,
    route: AppConstants.routeReports,
  ),
  _NavItem(
    label: 'Configuración',
    icon: Icons.settings_outlined,
    iconSelected: Icons.settings_rounded,
    route: AppConstants.routeSettings,
  ),
];

// ---------------------------------------------------------------------------
// SidebarNav – adaptive widget consumed by AppShell in app_router.dart
// ---------------------------------------------------------------------------

/// Adaptive sidebar navigation.
///
/// * `isDrawer: false` → renders a collapsible [NavigationRail] for wide
///   (desktop / tablet) layouts. Intended to be placed in a [Row] next to the
///   page body by [AppShell].
///
/// * `isDrawer: true` → renders a full-height drawer body (header + list +
///   sign-out). The parent [Scaffold]'s [Drawer] widget provides the surface.
///
/// [currentLocation] is compared against each item's route prefix to
/// determine which item is highlighted.
class SidebarNav extends ConsumerStatefulWidget {
  const SidebarNav({
    super.key,
    required this.currentLocation,
    required this.isDrawer,
  });

  /// The currently matched route location, e.g. `/inventory/product`.
  final String currentLocation;

  /// When `true` the widget renders as drawer body content (mobile).
  /// When `false` it renders as an inline NavigationRail (desktop).
  final bool isDrawer;

  @override
  ConsumerState<SidebarNav> createState() => _SidebarNavState();
}

class _SidebarNavState extends ConsumerState<SidebarNav> {
  bool _extended = true;

  int get _selectedIndex {
    // Match the longest prefix to handle nested routes correctly.
    int best = 0;
    int bestLen = 0;
    for (int i = 0; i < _navItems.length; i++) {
      final route = _navItems[i].route;
      if (widget.currentLocation.startsWith(route) && route.length > bestLen) {
        best = i;
        bestLen = route.length;
      }
    }
    return best;
  }

  void _navigate(String route) {
    if (widget.isDrawer) Navigator.of(context).pop();
    context.go(route);
  }

  Future<void> _confirmSignOut() async {
    if (widget.isDrawer) Navigator.of(context).pop();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content:
            const Text('¿Estás seguro de que deseas cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  // ── Rail (desktop) ───────────────────────────────────────────────────────

  Widget _buildRail(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final railBg =
        Theme.of(context).navigationRailTheme.backgroundColor ??
            cs.surface;

    return AnimatedContainer(
      duration: AppConstants.animationNormal,
      width: _extended
          ? AppConstants.railWidthExpanded
          : AppConstants.railWidthCollapsed,
      color: railBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Brand header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
            child: Row(
              children: [
                _BrandIcon(color: cs.primary),
                if (_extended) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppConstants.appName.toUpperCase(),
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Nav items ────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final selected = i == _selectedIndex;
                return _RailTile(
                  item: item,
                  isSelected: selected,
                  extended: _extended,
                  onTap: () => _navigate(item.route),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ── Bottom actions ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
            child: Column(
              children: [
                _RailActionTile(
                  icon: _extended
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  label: 'Colapsar',
                  extended: _extended,
                  onTap: () => setState(() => _extended = !_extended),
                ),
                const SizedBox(height: 4),
                _RailActionTile(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar sesión',
                  extended: _extended,
                  color: cs.error,
                  onTap: _confirmSignOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Drawer body (mobile) ─────────────────────────────────────────────────

  Widget _buildDrawerBody(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Coloured header ──────────────────────────────────────────────
          Container(
            color: cs.primary,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BrandIcon(color: cs.onPrimary, size: 44, iconSize: 26),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appName.toUpperCase(),
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    color: cs.onPrimary.withAlpha(179),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // ── Destinations ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final selected = i == _selectedIndex;
                return _DrawerTile(
                  item: item,
                  isSelected: selected,
                  onTap: () => _navigate(item.route),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ── Sign out ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading:
                  Icon(Icons.logout_rounded, color: cs.error, size: 22),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: cs.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: _confirmSignOut,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      widget.isDrawer ? _buildDrawerBody(context) : _buildRail(context);
}

// ---------------------------------------------------------------------------
// _BrandIcon
// ---------------------------------------------------------------------------

class _BrandIcon extends StatelessWidget {
  const _BrandIcon({
    required this.color,
    this.size = 36,
    this.iconSize = 20,
  });

  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: color.withAlpha(77), width: 1.5),
      ),
      child: Center(
        child: Icon(Icons.store_rounded, size: iconSize, color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RailTile
// ---------------------------------------------------------------------------

class _RailTile extends StatelessWidget {
  const _RailTile({
    required this.item,
    required this.isSelected,
    required this.extended,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: AppConstants.animationFast,
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: isSelected ? cs.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: cs.primary.withAlpha(13),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 12 : 0,
            vertical: 10,
          ),
          child: extended
              ? Row(
                  children: [
                    Icon(
                      isSelected ? item.iconSelected : item.icon,
                      size: 22,
                      color: isSelected
                          ? cs.onPrimaryContainer
                          : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? cs.onPrimaryContainer
                              : cs.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    isSelected ? item.iconSelected : item.icon,
                    size: 22,
                    color: isSelected
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RailActionTile (collapse / sign-out)
// ---------------------------------------------------------------------------

class _RailActionTile extends StatelessWidget {
  const _RailActionTile({
    required this.icon,
    required this.label,
    required this.extended,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final bool extended;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: extended ? 12 : 0,
          vertical: 8,
        ),
        child: extended
            ? Row(
                children: [
                  Icon(icon, size: 20, color: effectiveColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: effectiveColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Center(child: Icon(icon, size: 20, color: effectiveColor)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DrawerTile
// ---------------------------------------------------------------------------

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? cs.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(
          isSelected ? item.iconSelected : item.icon,
          size: 22,
          color:
              isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
            fontSize: 14,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppDrawer convenience wrapper (kept for backward compatibility)
// ---------------------------------------------------------------------------

/// Wraps [SidebarNav] in a plain [Column] for use as a [Scaffold.drawer] body.
///
/// Prefer using [SidebarNav] directly with `isDrawer: true` inside a [Drawer]
/// widget.
@Deprecated('Use SidebarNav(isDrawer: true) directly inside a Drawer widget.')
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) =>
      SidebarNav(currentLocation: currentRoute, isDrawer: true);
}
