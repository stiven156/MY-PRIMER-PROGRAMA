import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState, AuthChangeEvent;

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/shared/widgets/sidebar_nav.dart';
import 'package:mercados/features/auth/providers/auth_provider.dart';
import 'package:mercados/features/auth/models/user_model.dart';

import 'package:mercados/features/auth/screens/login_screen.dart';
import 'package:mercados/features/auth/screens/register_screen.dart';
import 'package:mercados/features/dashboard/screens/dashboard_screen.dart';
import 'package:mercados/features/pos/screens/pos_screen.dart';
import 'package:mercados/features/inventory/screens/inventory_screen.dart';
import 'package:mercados/features/inventory/screens/product_form_screen.dart';
import 'package:mercados/features/purchases/screens/purchases_screen.dart';
import 'package:mercados/features/purchases/screens/suppliers_screen.dart';
import 'package:mercados/features/customers/screens/customers_screen.dart';
import 'package:mercados/features/employees/screens/employees_screen.dart';
import 'package:mercados/features/orders/screens/orders_panel_screen.dart';
import 'package:mercados/features/reports/screens/reports_screen.dart';
import 'package:mercados/features/settings/screens/settings_screen.dart';
import 'package:mercados/features/client_app/screens/client_app_screen.dart';

// ---------------------------------------------------------------------------
// Router notifier — fires on Riverpod auth changes AND Supabase changes
// ---------------------------------------------------------------------------

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    // Rebuild router whenever auth state changes (demo mode + Supabase)
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());

    // Also listen to Supabase if available
    try {
      Supabase.instance.client.auth.onAuthStateChange
          .listen((_) => notifyListeners());
    } catch (_) {}
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final isAuth = authState.isAuthenticated;
    final loc = state.matchedLocation;

    // Always allow public routes
    if (loc == AppConstants.routeRegister) return null;
    if (loc == AppConstants.routeClientApp) return null;

    final isPublic =
        loc == AppConstants.routeLogin || loc == AppConstants.routeRegister;

    if (!isAuth && !isPublic) return AppConstants.routeLogin;

    if (isAuth && isPublic) {
      final user = authState.currentUser;
      if (user != null && user.role.isCustomer) {
        return AppConstants.routeClientApp;
      }
      return AppConstants.routeDashboard;
    }

    return null;
  }
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    debugLogDiagnostics: false,
    initialLocation: AppConstants.routeLogin,
    refreshListenable: notifier,
    redirect: notifier.redirect,

    routes: [
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        name: 'register',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const RegisterScreen()),
      ),
      GoRoute(
        path: AppConstants.routeClientApp,
        name: 'client',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const ClientAppScreen()),
      ),

      // ── Shell con sidebar para staff ──────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentLocation: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppConstants.routeDashboard,
            name: 'dashboard',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const DashboardScreen()),
          ),
          GoRoute(
            path: AppConstants.routePOS,
            name: 'pos',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const PosScreen()),
          ),
          GoRoute(
            path: AppConstants.routeInventory,
            name: 'inventory',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const InventoryScreen()),
            routes: [
              GoRoute(
                path: 'product',
                name: 'product-form',
                pageBuilder: (context, state) {
                  final id = state.uri.queryParameters['id'];
                  return _slidePage(
                      state: state, child: ProductFormScreen(productId: id));
                },
              ),
            ],
          ),
          GoRoute(
            path: AppConstants.routePurchases,
            name: 'purchases',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const PurchasesScreen()),
          ),
          GoRoute(
            path: AppConstants.routeSuppliers,
            name: 'suppliers',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const SuppliersScreen()),
          ),
          GoRoute(
            path: AppConstants.routeCustomers,
            name: 'customers',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const CustomersScreen()),
          ),
          GoRoute(
            path: AppConstants.routeEmployees,
            name: 'employees',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const EmployeesScreen()),
          ),
          GoRoute(
            path: AppConstants.routeOrders,
            name: 'orders',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const OrdersPanelScreen()),
          ),
          GoRoute(
            path: AppConstants.routeReports,
            name: 'reports',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const ReportsScreen()),
          ),
          GoRoute(
            path: AppConstants.routeSettings,
            name: 'settings',
            pageBuilder: (context, state) =>
                _slidePage(state: state, child: const SettingsScreen()),
          ),
        ],
      ),
    ],

    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: _RouterErrorScreen(error: state.error),
    ),
  );
});

// ---------------------------------------------------------------------------
// Page transitions
// ---------------------------------------------------------------------------

CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppConstants.animationNormal,
    reverseTransitionDuration: AppConstants.animationFast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage<void> _slidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppConstants.animationNormal,
    reverseTransitionDuration: AppConstants.animationFast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Shell scaffold
// ---------------------------------------------------------------------------

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentLocation,
    required this.child,
  });

  final String currentLocation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.sizeOf(context).width >= AppConstants.sidebarBreakpoint;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            SidebarNav(currentLocation: currentLocation, isDrawer: false),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: Drawer(
        child: SidebarNav(currentLocation: currentLocation, isDrawer: true),
      ),
      body: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Error screen
// ---------------------------------------------------------------------------

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 72, color: theme.colorScheme.error),
              const SizedBox(height: AppConstants.spacingM),
              Text('Página no encontrada',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                error?.toString() ?? 'La ruta solicitada no existe.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingL),
              FilledButton.icon(
                onPressed: () => context.go(AppConstants.routeDashboard),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
