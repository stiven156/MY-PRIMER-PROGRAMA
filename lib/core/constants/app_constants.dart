import 'package:flutter/material.dart';

/// App-wide constants: colors, strings, sizes, route names.
class AppConstants {
  AppConstants._();

  // ──────────────────────────────────────────
  // App identity
  // ──────────────────────────────────────────
  static const String appName = 'Mercados';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Gestión inteligente para tu supermercado';

  // ──────────────────────────────────────────
  // Supabase
  // ──────────────────────────────────────────
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // ──────────────────────────────────────────
  // Named routes
  // ──────────────────────────────────────────
  static const String routeLogin = '/login';
  static const String routeDashboard = '/dashboard';
  static const String routePOS = '/pos';
  static const String routeInventory = '/inventory';
  static const String routeProductForm = '/inventory/product';
  static const String routePurchases = '/purchases';
  static const String routeSuppliers = '/suppliers';
  static const String routeCustomers = '/customers';
  static const String routeEmployees = '/employees';
  static const String routeOrders = '/orders';
  static const String routeReports = '/reports';
  static const String routeSettings = '/settings';
  static const String routeClientApp = '/client';
  static const String routeRegister = '/register';

  // ──────────────────────────────────────────
  // Layout / sizing
  // ──────────────────────────────────────────

  /// Width breakpoint above which the desktop sidebar is shown inline.
  static const double sidebarBreakpoint = 720.0;

  /// Collapsed NavigationRail width.
  static const double railWidthCollapsed = 72.0;

  /// Expanded NavigationRail / Drawer width.
  static const double railWidthExpanded = 220.0;

  static const double cardBorderRadius = 16.0;
  static const double dialogBorderRadius = 20.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  // ──────────────────────────────────────────
  // Durations
  // ──────────────────────────────────────────
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration toastDuration = Duration(seconds: 2);

  // ──────────────────────────────────────────
  // Locale / formatting
  // ──────────────────────────────────────────
  static const String currencySymbol = '\$';
  static const String currencyLocale = 'es_MX';
  static const String dateLocale = 'es_MX';

  // ──────────────────────────────────────────
  // Business logic defaults
  // ──────────────────────────────────────────
  static const double defaultTaxRate = 0.16; // 16 % IVA
  static const int lowStockThreshold = 10;
  static const int maxCartItems = 999;
  static const int paginationPageSize = 25;

  // ──────────────────────────────────────────
  // Shared-preferences keys
  // ──────────────────────────────────────────
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefLocale = 'pref_locale';
  static const String prefTaxRate = 'pref_tax_rate';
  static const String prefCurrencySymbol = 'pref_currency_symbol';
  static const String prefStoreName = 'pref_store_name';
  static const String prefStoreAddress = 'pref_store_address';
  static const String prefStorePhone = 'pref_store_phone';
  static const String prefReceiptFooter = 'pref_receipt_footer';
  static const String prefPrinterEnabled = 'pref_printer_enabled';

  // ──────────────────────────────────────────
  // Supabase table names
  // ──────────────────────────────────────────
  static const String tableProducts = 'products';
  static const String tableCategories = 'categories';
  static const String tableSales = 'sales';
  static const String tableSaleItems = 'sale_items';
  static const String tablePurchases = 'purchases';
  static const String tablePurchaseItems = 'purchase_items';
  static const String tableSuppliers = 'suppliers';
  static const String tableCustomers = 'customers';
  static const String tableEmployees = 'employees';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';

  // ──────────────────────────────────────────
  // Asset paths
  // ──────────────────────────────────────────
  static const String assetLogo = 'assets/images/logo.png';
  static const String assetLogoWhite = 'assets/images/logo_white.png';
  static const String assetPlaceholderProduct =
      'assets/images/placeholder_product.png';
  static const String assetIconBarcode = 'assets/icons/barcode.svg';
}
