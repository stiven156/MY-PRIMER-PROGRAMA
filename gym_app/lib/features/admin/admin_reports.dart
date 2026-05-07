import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/members_provider.dart';
import 'package:gym_app/core/models/member_model.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _period = '6M';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersState = ref.watch(membersProvider);
    final active = membersState.members.where((m) => m.status == MemberStatus.active).length;
    final expired = membersState.members.where((m) => m.status == MemberStatus.expired).length;
    final trial = membersState.members.where((m) => m.status == MemberStatus.trial).length;
    final total = membersState.members.length;
    final retention = total > 0 ? (active / total * 100).toStringAsFixed(1) : '0';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: const Text('Reportes', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
            actions: [
              IconButton(icon: const Icon(Icons.download, color: AppColors.textSecondary), onPressed: () {}),
              PopupMenuButton<String>(
                color: AppColors.card,
                icon: const Icon(Icons.tune, color: AppColors.textSecondary),
                onSelected: (v) => setState(() => _period = v),
                itemBuilder: (_) => ['1M', '3M', '6M', '1A', 'Todo'].map((p) => PopupMenuItem(
                  value: p, child: Text(p, style: TextStyle(color: _period == p ? AppColors.primary : AppColors.textPrimary)))).toList(),
              ),
            ],
            bottom: TabBar(
              controller: _tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              tabs: const [Tab(text: 'Ingresos'), Tab(text: 'Miembros'), Tab(text: 'Asistencia'), Tab(text: 'Clases')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _RevenueTab(period: _period),
            _MembersTab(active: active, expired: expired, trial: trial, total: total, retention: retention),
            _AttendanceTab(),
            _ClassesTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Revenue Tab
// ---------------------------------------------------------------------------
class _RevenueTab extends StatelessWidget {
  final String period;
  const _RevenueTab({required this.period});

  static const _monthLabels = ['Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  static const _revenueData = [4200.0, 5100.0, 4800.0, 6200.0, 7100.0, 8420.0];
  static const _expenses = [2100.0, 2300.0, 2200.0, 2500.0, 2600.0, 2800.0];

  @override
  Widget build(BuildContext context) {
    final totalRevenue = _revenueData.reduce((a, b) => a + b);
    final totalExpenses = _expenses.reduce((a, b) => a + b);
    final totalProfit = totalRevenue - totalExpenses;

    return ListView(padding: const EdgeInsets.all(16), children: [
      // KPI row
      Row(children: [
        _KpiTile('Ingresos', '\$${(totalRevenue / 1000).toStringAsFixed(1)}k', AppColors.success, Icons.trending_up),
        const Gap(8),
        _KpiTile('Gastos', '\$${(totalExpenses / 1000).toStringAsFixed(1)}k', AppColors.error, Icons.trending_down),
        const Gap(8),
        _KpiTile('Utilidad', '\$${(totalProfit / 1000).toStringAsFixed(1)}k', AppColors.primary, Icons.account_balance),
      ]),
      const Gap(20),

      // Revenue vs Expenses bar chart
      _ChartCard(
        title: 'Ingresos vs Gastos',
        subtitle: 'Últimos 6 meses',
        child: SizedBox(height: 220, child: BarChart(BarChartData(
          barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barsSpace: 4, barRods: [
            BarChartRodData(toY: _revenueData[i], width: 12, color: AppColors.success, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
            BarChartRodData(toY: _expenses[i], width: 12, color: AppColors.error.withOpacity(0.7), borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          ])),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                getTitlesWidget: (v, _) => Text(_monthLabels[v.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 11)))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 48,
                getTitlesWidget: (v, _) => Text('\$${(v / 1000).toStringAsFixed(0)}k', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1)),
        ))),
      ),
      const Gap(16),

      // Profit line
      _ChartCard(
        title: 'Utilidad Neta',
        subtitle: 'Tendencia mensual',
        child: SizedBox(height: 160, child: LineChart(LineChartData(
          lineBarsData: [LineChartBarData(
            spots: List.generate(6, (i) => FlSpot(i.toDouble(), _revenueData[i] - _expenses[i])),
            isCurved: true, color: AppColors.primary, barWidth: 3,
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
            dotData: const FlDotData(show: false),
          )],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) =>
                Text(_monthLabels[v.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 11)))),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ))),
      ),
      const Gap(16),

      // Revenue breakdown
      _ChartCard(
        title: 'Por Fuente de Ingreso',
        subtitle: 'Mes actual',
        child: SizedBox(height: 200, child: Row(children: [
          Expanded(child: PieChart(PieChartData(
            sections: [
              PieChartSectionData(value: 65, color: AppColors.primary, title: '65%', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              PieChartSectionData(value: 20, color: AppColors.success, title: '20%', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              PieChartSectionData(value: 10, color: AppColors.accent, title: '10%', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              PieChartSectionData(value: 5, color: AppColors.warning, title: '5%', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
            sectionsSpace: 2, centerSpaceRadius: 30,
          ))),
          const Gap(16),
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Legend(AppColors.primary, 'Membresías (65%)'),
            const Gap(8),
            _Legend(AppColors.success, 'Clases extra (20%)'),
            const Gap(8),
            _Legend(AppColors.accent, 'PT Sessions (10%)'),
            const Gap(8),
            _Legend(AppColors.warning, 'Otros (5%)'),
          ]),
        ])),
      ),
      const Gap(80),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Members Tab
// ---------------------------------------------------------------------------
class _MembersTab extends StatelessWidget {
  final int active, expired, trial, total;
  final String retention;
  const _MembersTab({required this.active, required this.expired, required this.trial, required this.total, required this.retention});

  static const _newMembersData = [8.0, 12.0, 10.0, 15.0, 18.0, 22.0];
  static const _churnData = [3.0, 4.0, 5.0, 3.0, 2.0, 3.0];
  static const _monthLabels = ['Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        _KpiTile('Total', '$total', AppColors.primary, Icons.people),
        const Gap(8),
        _KpiTile('Activos', '$active', AppColors.success, Icons.check_circle),
        const Gap(8),
        _KpiTile('Retención', '$retention%', AppColors.accent, Icons.trending_up),
      ]),
      const Gap(20),

      _ChartCard(
        title: 'Nuevos vs Bajas',
        subtitle: 'Últimos 6 meses',
        child: SizedBox(height: 200, child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(spots: List.generate(6, (i) => FlSpot(i.toDouble(), _newMembersData[i])),
                isCurved: true, color: AppColors.success, barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: AppColors.success.withOpacity(0.08))),
            LineChartBarData(spots: List.generate(6, (i) => FlSpot(i.toDouble(), _churnData[i])),
                isCurved: true, color: AppColors.error, barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: AppColors.error.withOpacity(0.08))),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) =>
                Text(_monthLabels[v.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 11)))),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1)),
        ))),
      ),
      const Gap(16),

      if (total > 0) _ChartCard(
        title: 'Distribución por Estado',
        subtitle: 'Actualizado hoy',
        child: SizedBox(height: 200, child: Row(children: [
          Expanded(child: PieChart(PieChartData(
            sections: [
              if (active > 0) PieChartSectionData(value: active.toDouble(), color: AppColors.success, title: '$active', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              if (expired > 0) PieChartSectionData(value: expired.toDouble(), color: AppColors.error, title: '$expired', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              if (trial > 0) PieChartSectionData(value: trial.toDouble(), color: AppColors.warning, title: '$trial', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
            sectionsSpace: 2, centerSpaceRadius: 30,
          ))),
          const Gap(16),
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Legend(AppColors.success, 'Activos ($active)'),
            const Gap(8),
            _Legend(AppColors.error, 'Vencidos ($expired)'),
            const Gap(8),
            _Legend(AppColors.warning, 'Trial ($trial)'),
          ]),
        ])),
      ),
      const Gap(16),

      // Plans distribution
      _ChartCard(
        title: 'Por Plan de Membresía',
        subtitle: 'Distribución actual',
        child: Column(children: [
          _PlanBar('Elite', 0.35, AppColors.primary),
          const Gap(8),
          _PlanBar('Pro', 0.40, AppColors.success),
          const Gap(8),
          _PlanBar('Estándar', 0.18, AppColors.accent),
          const Gap(8),
          _PlanBar('Básico', 0.07, AppColors.warning),
        ]),
      ),
      const Gap(80),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Attendance Tab
// ---------------------------------------------------------------------------
class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  static const _weekData = [45.0, 72.0, 68.0, 80.0, 75.0, 55.0, 30.0];
  static const _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _hourData = [5.0, 8.0, 15.0, 30.0, 45.0, 65.0, 70.0, 55.0, 40.0, 35.0, 50.0, 30.0];

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        _KpiTile('Hoy', '67', AppColors.primary, Icons.today),
        const Gap(8),
        _KpiTile('Esta semana', '420', AppColors.success, Icons.date_range),
        const Gap(8),
        _KpiTile('Promedio/día', '60', AppColors.accent, Icons.bar_chart),
      ]),
      const Gap(20),

      _ChartCard(
        title: 'Asistencia por Día',
        subtitle: 'Esta semana',
        child: SizedBox(height: 200, child: BarChart(BarChartData(
          barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [
            BarChartRodData(toY: _weekData[i], width: 28,
                gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF1060)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
          ])),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                getTitlesWidget: (v, _) => Text(_dayLabels[v.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 12)))),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ))),
      ),
      const Gap(16),

      _ChartCard(
        title: 'Horas Pico',
        subtitle: 'Distribución por hora del día',
        child: SizedBox(height: 160, child: LineChart(LineChartData(
          lineBarsData: [LineChartBarData(
            spots: List.generate(12, (i) => FlSpot(i.toDouble(), _hourData[i])),
            isCurved: true, color: AppColors.accent, barWidth: 3,
            belowBarData: BarAreaData(show: true, color: AppColors.accent.withOpacity(0.1)),
            dotData: const FlDotData(show: false),
          )],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 2, getTitlesWidget: (v, _) =>
                Text('${v.toInt() + 6}h', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ))),
      ),
      const Gap(80),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Classes Tab
// ---------------------------------------------------------------------------
class _ClassesTab extends StatelessWidget {
  const _ClassesTab();

  @override
  Widget build(BuildContext context) {
    final classes = [
      ('Spinning', 24, 92.0, AppColors.primary),
      ('CrossFit', 18, 87.0, AppColors.error),
      ('Yoga', 16, 78.0, AppColors.success),
      ('Pilates', 12, 95.0, AppColors.accent),
      ('Functional', 20, 83.0, AppColors.warning),
      ('Boxeo', 10, 70.0, const Color(0xFFFF6B35)),
    ];

    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        _KpiTile('Clases/semana', '28', AppColors.primary, Icons.event),
        const Gap(8),
        _KpiTile('Ocupación', '85%', AppColors.success, Icons.people),
        const Gap(8),
        _KpiTile('Populares', '6', AppColors.accent, Icons.star),
      ]),
      const Gap(20),

      _ChartCard(
        title: 'Clases más Populares',
        subtitle: 'Por ocupación promedio',
        child: Column(children: classes.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(c.$1, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
              Text('${c.$2} clases  ·  ${c.$3.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ]),
            const Gap(6),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: c.$3 / 100, minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(c.$4),
            )),
          ]),
        )).toList()),
      ),
      const Gap(16),

      _ChartCard(
        title: 'Asistencia a Clases',
        subtitle: 'Últimas 4 semanas',
        child: SizedBox(height: 180, child: LineChart(LineChartData(
          lineBarsData: [LineChartBarData(
            spots: const [FlSpot(0, 180), FlSpot(1, 210), FlSpot(2, 195), FlSpot(3, 240)],
            isCurved: true, color: AppColors.primary, barWidth: 3,
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
            dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: AppColors.primary, strokeColor: Colors.transparent)),
          )],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) =>
                Text('S${v.toInt() + 1}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1)),
        ))),
      ),
      const Gap(80),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _KpiTile extends StatelessWidget {
  final String label, value; final Color color; final IconData icon;
  const _KpiTile(this.label, this.value, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 18),
      const Gap(6),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10), maxLines: 1),
    ]),
  ));
}

class _ChartCard extends StatelessWidget {
  final String title, subtitle; final Widget child;
  const _ChartCard({required this.title, required this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
      const Gap(2),
      Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      const Gap(16),
      child,
    ]),
  );
}

class _Legend extends StatelessWidget {
  final Color color; final String label;
  const _Legend(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const Gap(6),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
  ]);
}

class _PlanBar extends StatelessWidget {
  final String label; final double value; final Color color;
  const _PlanBar(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      Text('${(value * 100).toStringAsFixed(0)}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
    const Gap(4),
    ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
      value: value, minHeight: 8, backgroundColor: AppColors.border,
      valueColor: AlwaysStoppedAnimation(color),
    )),
  ]);
}
