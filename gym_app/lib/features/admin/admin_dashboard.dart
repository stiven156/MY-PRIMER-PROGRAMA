import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/members_provider.dart';
import 'package:gym_app/core/providers/gym_provider.dart';
import 'package:gym_app/core/providers/schedule_provider.dart';
import 'package:gym_app/core/models/member_model.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersState = ref.watch(membersProvider);
    final gym = ref.watch(currentGymProvider);
    final scheduleState = ref.watch(scheduleProvider);

    final active = membersState.members.where((m) => m.status == MemberStatus.active).length;
    final expired = membersState.members.where((m) => m.status == MemberStatus.expired).length;
    final trial = membersState.members.where((m) => m.status == MemberStatus.trial).length;
    final total = membersState.members.length;

    // Today's classes
    final todayClasses = scheduleState.classes.where((c) =>
        c.startTime.day == DateTime.now().day && c.startTime.month == DateTime.now().month).length;

    // Revenue mock data (last 6 months)
    final revenueData = [4200.0, 5100.0, 4800.0, 6200.0, 7100.0, 8420.0];
    final monthLabels = ['Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(gym?.name ?? 'Mi Gimnasio',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
              Text('Panel de Administración', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary), onPressed: () {}),
              IconButton(icon: const Icon(Icons.file_download_outlined, color: AppColors.textSecondary), onPressed: () {}),
            ],
          ),

          SliverToBoxAdapter(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Cards
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _KpiCard(label: 'Miembros Activos', value: '$active', trend: '+12', color: AppColors.success, icon: Icons.people).animate().fadeIn(delay: 50.ms),
                    _KpiCard(label: 'Ingresos Mes', value: '\$8,420', trend: '+8%', color: AppColors.primary, icon: Icons.attach_money).animate().fadeIn(delay: 100.ms),
                    _KpiCard(label: 'Nuevos este mes', value: '18', trend: '+3', color: AppColors.accent, icon: Icons.person_add).animate().fadeIn(delay: 150.ms),
                    _KpiCard(label: 'Retención', value: '87%', trend: '+2%', color: AppColors.warning, icon: Icons.trending_up).animate().fadeIn(delay: 200.ms),
                    _KpiCard(label: 'Clases hoy', value: '$todayClasses', trend: '', color: AppColors.secondary, icon: Icons.event).animate().fadeIn(delay: 250.ms),
                    _KpiCard(label: 'Asist. hoy', value: '67', trend: '', color: AppColors.success, icon: Icons.check_circle_outline).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),
              const Gap(20),

              // Revenue chart
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Ingresos Mensuales', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                const Gap(4),
                const Text('Últimos 6 meses', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const Gap(12),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: BarChart(BarChartData(
                    barGroups: List.generate(6, (i) => BarChartGroupData(
                      x: i,
                      barRods: [BarChartRodData(
                        toY: revenueData[i], width: 24,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF1060)],
                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      )],
                    )),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(monthLabels[v.toInt()],
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)))),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 48,
                          getTitlesWidget: (v, _) => Text('\$${(v / 1000).toStringAsFixed(0)}k',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true, drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
                    ),
                  )),
                ),
              ])),
              const Gap(20),

              // Members status pie
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Estado de Miembros', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  const Gap(12),
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: total == 0 ? const Center(child: Text('Sin datos', style: TextStyle(color: AppColors.textMuted)))
                        : PieChart(PieChartData(
                            sections: [
                              PieChartSectionData(value: active.toDouble(), color: AppColors.success, title: '$active', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), radius: 50),
                              PieChartSectionData(value: expired.toDouble(), color: AppColors.error, title: '$expired', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), radius: 50),
                              if (trial > 0) PieChartSectionData(value: trial.toDouble(), color: AppColors.warning, title: '$trial', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), radius: 50),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                          )),
                  ),
                  const Gap(8),
                  _PieLegend(color: AppColors.success, label: 'Activos ($active)'),
                  _PieLegend(color: AppColors.error, label: 'Vencidos ($expired)'),
                  _PieLegend(color: AppColors.warning, label: 'Trial ($trial)'),
                ])),
              ])),
              const Gap(20),

              // Alerts
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Alertas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                const Gap(12),
                ...membersState.members.where((m) => m.isExpiringSoon && m.status == MemberStatus.active).take(3).map((m) =>
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                        const Gap(10),
                        Expanded(child: Text('${m.name} vence en ${m.daysUntilExpiry} días',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                        TextButton(onPressed: () {}, child: const Text('Renovar', style: TextStyle(fontSize: 12))),
                      ]),
                    )),
                if (membersState.members.where((m) => m.isExpiringSoon).isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.05), borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withOpacity(0.3))),
                    child: const Row(children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      Gap(10),
                      Text('Sin alertas pendientes', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                    ]),
                  ),
              ])),
              const Gap(80),
            ],
          )),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value, trend; final Color color; final IconData icon;
  const _KpiCard({required this.label, required this.value, required this.trend, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width: 130, margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, color: color, size: 20),
        if (trend.isNotEmpty) Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
          child: Text(trend, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ]),
      const Gap(8),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 22)),
      const Gap(2),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 2),
    ]),
  );
}

class _PieLegend extends StatelessWidget {
  final Color color; final String label;
  const _PieLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const Gap(6),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ]),
  );
}
