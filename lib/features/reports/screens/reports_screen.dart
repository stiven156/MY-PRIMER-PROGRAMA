import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/core/theme/app_theme.dart';
import 'package:mercados/features/reports/providers/reports_provider.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsProvider);
    final notifier = ref.read(reportsProvider.notifier);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currency = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          if (!state.isLoading)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Exportar PDF',
              onPressed: () => _exportPdf(context, state),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => notifier.loadReport(state.selectedPeriod),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppConstants.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Period selector ─────────────────────────
                  _PeriodSelector(
                    selected: state.selectedPeriod,
                    onSelected: notifier.setPeriod,
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // ── Summary cards ───────────────────────────
                  if (state.summary != null) ...[
                    _SummaryCards(summary: state.summary!, currency: currency),
                    const SizedBox(height: AppConstants.spacingL),
                  ],

                  // ── Sales line chart ────────────────────────
                  if (state.salesByDay.isNotEmpty) ...[
                    Text('Ventas por Día',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppConstants.spacingM),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 24, 12),
                        child: SizedBox(
                          height: 220,
                          child: _SalesLineChart(
                            data: state.salesByDay,
                            period: state.selectedPeriod,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                  ],

                  // ── Top products bar chart ──────────────────
                  if (state.topProducts.isNotEmpty) ...[
                    Text('Top 5 Productos',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppConstants.spacingM),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 24, 12),
                        child: SizedBox(
                          height: 220,
                          child: _TopProductsBarChart(
                            products: state.topProducts,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                  ],

                  // ── Inventory & margin stats ─────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Valor de Inventario',
                          value: currency.format(state.inventoryValue),
                          icon: Icons.inventory_2_outlined,
                          color: cs.tertiary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: _StatCard(
                          label: 'Margen de Ganancia',
                          value:
                              '${state.profitMargin.toStringAsFixed(1)} %',
                          icon: Icons.trending_up_rounded,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // ── Top products table ──────────────────────
                  _TopProductsTable(
                    products: state.topProducts,
                    currency: currency,
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _exportPdf(BuildContext context, ReportsState state) async {
    final currency = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pdfCtx) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Reporte de Ventas – ${state.selectedPeriod.displayName}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            if (state.summary != null) ...[
              pw.Text('Resumen',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Table.fromTextArray(
                data: [
                  ['Métrica', 'Valor'],
                  [
                    'Total Ventas',
                    currency.format(state.summary!.totalSales)
                  ],
                  [
                    'Transacciones',
                    '${state.summary!.transactionCount}'
                  ],
                  [
                    'Ticket Promedio',
                    currency.format(state.summary!.avgTicket)
                  ],
                  [
                    'Margen de Ganancia',
                    '${state.profitMargin.toStringAsFixed(1)} %'
                  ],
                  [
                    'Valor Inventario',
                    currency.format(state.inventoryValue)
                  ],
                ],
              ),
              pw.SizedBox(height: 16),
            ],
            pw.Text('Top 5 Productos',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Table.fromTextArray(
              data: [
                ['Producto', 'Categoría', 'Unidades', 'Ingresos'],
                ...state.topProducts.map(
                  (p) => [
                    p.productName,
                    p.categoryName,
                    '${p.quantitySold}',
                    currency.format(p.revenue),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name:
          'reporte_${state.selectedPeriod.value}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}

// ---------------------------------------------------------------------------
// Period selector
// ---------------------------------------------------------------------------

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelected});

  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      children: ReportPeriod.values.map((p) {
        final isSelected = p == selected;
        return FilterChip(
          label: Text(p.displayName),
          selected: isSelected,
          onSelected: (_) => onSelected(p),
          selectedColor: cs.primaryContainer,
          checkmarkColor: cs.onPrimaryContainer,
          labelStyle: TextStyle(
            color: isSelected ? cs.onPrimaryContainer : null,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary cards
// ---------------------------------------------------------------------------

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary, required this.currency});

  final SalesSummary summary;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final growthPositive = summary.growthPercent >= 0;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final crossCount = constraints.maxWidth > 700 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _SummaryCard(
              label: 'Total Ventas',
              value: currency.format(summary.totalSales),
              icon: Icons.attach_money_rounded,
              color: cs.primary,
              subtitle: '${growthPositive ? '+' : ''}${summary.growthPercent.toStringAsFixed(1)}% vs anterior',
              subtitleColor:
                  growthPositive ? AppTheme.successColor : AppTheme.errorColor,
            ),
            _SummaryCard(
              label: 'Transacciones',
              value: '${summary.transactionCount}',
              icon: Icons.receipt_long_outlined,
              color: cs.secondary,
            ),
            _SummaryCard(
              label: 'Ticket Promedio',
              value: currency.format(summary.avgTicket),
              icon: Icons.shopping_basket_outlined,
              color: cs.tertiary,
            ),
            _SummaryCard(
              label: 'Ganancia Estimada',
              value: currency.format(summary.totalSales * 0.35),
              icon: Icons.trending_up_rounded,
              color: AppTheme.successColor,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.subtitleColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(label, style: theme.textTheme.labelSmall),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: subtitleColor),
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
// Sales line chart
// ---------------------------------------------------------------------------

class _SalesLineChart extends StatelessWidget {
  const _SalesLineChart({required this.data, required this.period});

  final List<DailySales> data;
  final ReportPeriod period;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Downsample to max 30 points to keep the chart readable.
    final List<DailySales> points;
    if (data.length <= 30) {
      points = data;
    } else {
      final step = (data.length / 30).ceil();
      points = [
        for (int i = 0; i < data.length; i += step) data[i],
      ];
    }

    final maxY = points.fold<double>(
          0,
          (m, d) => d.amount > m ? d.amount : m,
        ) *
        1.15;

    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
        .toList();

    final dateFormat = period == ReportPeriod.year
        ? DateFormat('MMM', 'es')
        : DateFormat('dd/MM', 'es');

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cs.outlineVariant.withAlpha(80),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox();
                final k = (value / 1000).toStringAsFixed(0);
                return Text('S/$k k',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (points.length / 6).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= points.length) return const SizedBox();
                return Transform.rotate(
                  angle: -0.4,
                  child: Text(
                    dateFormat.format(points[idx].date),
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: cs.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: points.length <= 10,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: cs.primary.withAlpha(30),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => cs.surfaceContainerHigh,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((s) {
                final idx = s.x.toInt();
                final day = idx < points.length ? points[idx] : null;
                return LineTooltipItem(
                  day == null
                      ? ''
                      : 'S/ ${s.y.toStringAsFixed(0)}\n${dateFormat.format(day.date)}',
                  TextStyle(color: cs.onSurface, fontSize: 11),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top products bar chart
// ---------------------------------------------------------------------------

class _TopProductsBarChart extends StatelessWidget {
  const _TopProductsBarChart({required this.products});

  final List<TopProduct> products;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxRevenue =
        products.fold<double>(0, (m, p) => p.revenue > m ? p.revenue : m) *
            1.15;

    final barColors = [
      cs.primary,
      cs.secondary,
      cs.tertiary,
      AppTheme.warningColor,
      AppTheme.infoColor,
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxRevenue,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cs.outlineVariant.withAlpha(80),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox();
                final k = (value / 1000).toStringAsFixed(0);
                return Text('S/$k k',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= products.length) return const SizedBox();
                final words = products[idx].productName.split(' ');
                final label = words.length > 1
                    ? '${words[0]}\n${words[1]}'
                    : words[0];
                return Text(label,
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center);
              },
            ),
          ),
        ),
        barGroups: products.asMap().entries.map((entry) {
          final idx = entry.key;
          final product = entry.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: product.revenue,
                color: barColors[idx % barColors.length],
                width: 28,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => cs.surfaceContainerHigh,
            getTooltipItem: (group, _, rod, __) {
              final idx = group.x;
              if (idx >= products.length) return null;
              final p = products[idx];
              return BarTooltipItem(
                '${p.productName}\nS/ ${rod.toY.toStringAsFixed(0)}\n${p.quantitySold} uds',
                TextStyle(color: cs.onSurface, fontSize: 11),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card (inventory & margin)
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: AppConstants.cardPadding,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top products table
// ---------------------------------------------------------------------------

class _TopProductsTable extends StatelessWidget {
  const _TopProductsTable({
    required this.products,
    required this.currency,
  });

  final List<TopProduct> products;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: AppConstants.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalle Top Productos',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            ...products.asMap().entries.map((entry) {
              final idx = entry.key;
              final p = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          theme.colorScheme.primaryContainer,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.productName,
                              style: theme.textTheme.labelLarge),
                          Text(p.categoryName,
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(currency.format(p.revenue),
                            style: theme.textTheme.titleSmall),
                        Text('${p.quantitySold} uds',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Extension for pdf export helper
// ---------------------------------------------------------------------------

extension _PeriodValue on ReportPeriod {
  String get value {
    switch (this) {
      case ReportPeriod.today:
        return 'hoy';
      case ReportPeriod.week:
        return 'semana';
      case ReportPeriod.month:
        return 'mes';
      case ReportPeriod.year:
        return 'anio';
    }
  }
}
