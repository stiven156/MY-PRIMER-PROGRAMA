import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Period enum
// ---------------------------------------------------------------------------

enum ReportPeriod { today, week, month, year }

extension ReportPeriodExtension on ReportPeriod {
  String get displayName {
    switch (this) {
      case ReportPeriod.today:
        return 'Hoy';
      case ReportPeriod.week:
        return 'Semana';
      case ReportPeriod.month:
        return 'Mes';
      case ReportPeriod.year:
        return 'Año';
    }
  }

  DateRange get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case ReportPeriod.today:
        return DateRange(start: today, end: now);
      case ReportPeriod.week:
        return DateRange(
          start: today.subtract(const Duration(days: 6)),
          end: now,
        );
      case ReportPeriod.month:
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case ReportPeriod.year:
        return DateRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// DateRange helper
// ---------------------------------------------------------------------------

class DateRange {
  final DateTime start;
  final DateTime end;
  const DateRange({required this.start, required this.end});

  int get daysSpan => end.difference(start).inDays + 1;
}

// ---------------------------------------------------------------------------
// Report data models
// ---------------------------------------------------------------------------

class SalesSummary {
  final double totalSales;
  final double avgTicket;
  final int transactionCount;
  final double previousPeriodSales;

  const SalesSummary({
    required this.totalSales,
    required this.avgTicket,
    required this.transactionCount,
    required this.previousPeriodSales,
  });

  double get growthPercent {
    if (previousPeriodSales == 0) return 0;
    return ((totalSales - previousPeriodSales) / previousPeriodSales) * 100;
  }
}

class TopProduct {
  final String productId;
  final String productName;
  final String categoryName;
  final int quantitySold;
  final double revenue;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.quantitySold,
    required this.revenue,
  });
}

class DailySales {
  final DateTime date;
  final double amount;
  final int transactions;

  const DailySales({
    required this.date,
    required this.amount,
    required this.transactions,
  });
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ReportsState {
  final ReportPeriod selectedPeriod;
  final bool isLoading;
  final String? error;
  final SalesSummary? summary;
  final List<TopProduct> topProducts;
  final List<DailySales> salesByDay;
  final double inventoryValue;
  final double profitMargin;

  const ReportsState({
    this.selectedPeriod = ReportPeriod.month,
    this.isLoading = false,
    this.error,
    this.summary,
    this.topProducts = const [],
    this.salesByDay = const [],
    this.inventoryValue = 0,
    this.profitMargin = 0,
  });

  ReportsState copyWith({
    ReportPeriod? selectedPeriod,
    bool? isLoading,
    String? error,
    bool clearError = false,
    SalesSummary? summary,
    List<TopProduct>? topProducts,
    List<DailySales>? salesByDay,
    double? inventoryValue,
    double? profitMargin,
  }) {
    return ReportsState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      summary: summary ?? this.summary,
      topProducts: topProducts ?? this.topProducts,
      salesByDay: salesByDay ?? this.salesByDay,
      inventoryValue: inventoryValue ?? this.inventoryValue,
      profitMargin: profitMargin ?? this.profitMargin,
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data generators
// ---------------------------------------------------------------------------

SalesSummary _buildSummary(ReportPeriod period) {
  switch (period) {
    case ReportPeriod.today:
      return const SalesSummary(
        totalSales: 4280.50,
        avgTicket: 152.87,
        transactionCount: 28,
        previousPeriodSales: 3950.00,
      );
    case ReportPeriod.week:
      return const SalesSummary(
        totalSales: 32650.00,
        avgTicket: 163.25,
        transactionCount: 200,
        previousPeriodSales: 28900.00,
      );
    case ReportPeriod.month:
      return const SalesSummary(
        totalSales: 138420.00,
        avgTicket: 158.50,
        transactionCount: 874,
        previousPeriodSales: 125000.00,
      );
    case ReportPeriod.year:
      return const SalesSummary(
        totalSales: 1542800.00,
        avgTicket: 162.30,
        transactionCount: 9505,
        previousPeriodSales: 1380000.00,
      );
  }
}

List<TopProduct> _buildTopProducts(ReportPeriod period) {
  final multiplier = <ReportPeriod, double>{
    ReportPeriod.today: 1,
    ReportPeriod.week: 7,
    ReportPeriod.month: 30,
    ReportPeriod.year: 365,
  }[period]!;

  return [
    TopProduct(
      productId: 'prod-001',
      productName: 'Coca-Cola 600ml',
      categoryName: 'Bebidas',
      quantitySold: (120 * multiplier).round(),
      revenue: 14.00 * 120 * multiplier,
    ),
    TopProduct(
      productId: 'prod-003',
      productName: 'Leche Entera 1L',
      categoryName: 'Lácteos',
      quantitySold: (85 * multiplier).round(),
      revenue: 24.00 * 85 * multiplier,
    ),
    TopProduct(
      productId: 'prod-020',
      productName: 'Café Molido 500g',
      categoryName: 'Bebidas',
      quantitySold: (42 * multiplier).round(),
      revenue: 98.00 * 42 * multiplier,
    ),
    TopProduct(
      productId: 'prod-005',
      productName: 'Pan Blanco 680g',
      categoryName: 'Panadería',
      quantitySold: (70 * multiplier).round(),
      revenue: 32.00 * 70 * multiplier,
    ),
    TopProduct(
      productId: 'prod-006',
      productName: 'Pechuga de Pollo 1kg',
      categoryName: 'Carnes',
      quantitySold: (38 * multiplier).round(),
      revenue: 95.00 * 38 * multiplier,
    ),
  ];
}

List<DailySales> _buildSalesByDay(ReportPeriod period) {
  final range = period.dateRange;
  final days = range.daysSpan.clamp(1, 365);
  final now = DateTime.now();
  final baseSales = <ReportPeriod, double>{
    ReportPeriod.today: 4280.50,
    ReportPeriod.week: 4664.28,
    ReportPeriod.month: 4614.00,
    ReportPeriod.year: 4228.00,
  }[period]!;

  final result = <DailySales>[];
  for (int i = days - 1; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: i));
    // Vary the sales sinusoidally for a realistic chart shape.
    final dayOfWeek = date.weekday; // 1=Mon…7=Sun
    final factor = dayOfWeek == 7 || dayOfWeek == 6 ? 1.3 : 1.0;
    final variance = (i % 5 - 2) * 200.0;
    final amount = (baseSales * factor + variance).clamp(500.0, 15000.0);
    result.add(DailySales(
      date: date,
      amount: amount,
      transactions: (amount / 158).round(),
    ));
  }
  return result;
}

double _buildInventoryValue() => 284650.00;

double _buildProfitMargin(ReportPeriod period) {
  switch (period) {
    case ReportPeriod.today:
      return 34.2;
    case ReportPeriod.week:
      return 33.8;
    case ReportPeriod.month:
      return 35.1;
    case ReportPeriod.year:
      return 34.7;
  }
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier() : super(const ReportsState()) {
    loadReport(ReportPeriod.month);
  }

  Future<void> loadReport(ReportPeriod period) async {
    state = state.copyWith(isLoading: true, selectedPeriod: period);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // TODO(supabase): replace with real queries / RPC calls.
    state = state.copyWith(
      isLoading: false,
      selectedPeriod: period,
      summary: _buildSummary(period),
      topProducts: _buildTopProducts(period),
      salesByDay: _buildSalesByDay(period),
      inventoryValue: _buildInventoryValue(),
      profitMargin: _buildProfitMargin(period),
    );
  }

  void setPeriod(ReportPeriod period) {
    if (period == state.selectedPeriod) return;
    loadReport(period);
  }

  // Convenience wrappers so callers can pass a custom DateRange.
  SalesSummary salesSummary(DateRange range) => _buildSummary(state.selectedPeriod);
  List<TopProduct> topProductsList(int limit) =>
      state.topProducts.take(limit).toList();
  List<DailySales> salesByDayList(DateRange range) => state.salesByDay;
  double inventoryValue() => state.inventoryValue;
  double profitMarginValue(DateRange range) => state.profitMargin;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>(
  (ref) => ReportsNotifier(),
);
