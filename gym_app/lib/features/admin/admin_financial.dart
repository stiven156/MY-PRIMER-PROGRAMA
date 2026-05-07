import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/models/payment_model.dart';

class AdminFinancialScreen extends ConsumerWidget {
  const AdminFinancialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock payments
    final payments = _mockPayments();
    final completed = payments.where((p) => p.status == PaymentStatus.completed);
    final pending = payments.where((p) => p.status == PaymentStatus.pending);
    final overdue = payments.where((p) => p.status == PaymentStatus.overdue);
    final totalRevenue = completed.fold(0.0, (s, p) => s + p.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: const Text('Finanzas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
            actions: [
              IconButton(icon: const Icon(Icons.download, color: AppColors.textSecondary), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Revenue summary
            Padding(padding: const EdgeInsets.all(16), child: Row(children: [
              _RevCard(label: 'Ingresos', value: '\$${totalRevenue.toStringAsFixed(0)}', color: AppColors.success),
              const Gap(8),
              _RevCard(label: 'Pendiente', value: '\$${pending.fold(0.0, (s, p) => s + p.amount).toStringAsFixed(0)}', color: AppColors.warning),
              const Gap(8),
              _RevCard(label: 'Vencido', value: '\$${overdue.fold(0.0, (s, p) => s + p.amount).toStringAsFixed(0)}', color: AppColors.error),
            ])),

            // Chart
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: LineChart(LineChartData(
                lineBarsData: [LineChartBarData(
                  spots: [
                    const FlSpot(0, 4200), const FlSpot(1, 5100), const FlSpot(2, 4800),
                    const FlSpot(3, 6200), const FlSpot(4, 7100), const FlSpot(5, 8420),
                  ],
                  isCurved: true, color: AppColors.primary, barWidth: 3,
                  belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                  dotData: const FlDotData(show: false),
                )],
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                      getTitlesWidget: (v, _) => Text(['J','A','S','O','N','D'][v.toInt()],
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11)))),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              )),
            )),
            const Gap(16),

            // Payments list with tabs
            DefaultTabController(
              length: 4,
              child: Column(children: [
                const TabBar(tabs: [Tab(text: 'Todos'), Tab(text: 'Pagados'), Tab(text: 'Pendiente'), Tab(text: 'Vencidos')]),
                SizedBox(
                  height: 400,
                  child: TabBarView(children: [
                    _PaymentList(payments: payments.toList()),
                    _PaymentList(payments: completed.toList()),
                    _PaymentList(payments: pending.toList()),
                    _PaymentList(payments: overdue.toList()),
                  ]),
                ),
              ]),
            ),
            const Gap(80),
          ])),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Registrar Pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  List<Payment> _mockPayments() {
    return [
      Payment(id: '1', memberId: 'm1', memberName: 'Carlos López', gymId: 'g1', amount: 50, date: DateTime.now().subtract(const Duration(days: 2)), membershipPlanId: 'plan_standard', membershipPlanName: 'Estándar', method: PaymentMethod.creditCard, status: PaymentStatus.completed, currency: 'USD'),
      Payment(id: '2', memberId: 'm2', memberName: 'Ana García', gymId: 'g1', amount: 120, date: DateTime.now().subtract(const Duration(days: 5)), membershipPlanId: 'plan_pro', membershipPlanName: 'Pro', method: PaymentMethod.cash, status: PaymentStatus.completed, currency: 'USD'),
      Payment(id: '3', memberId: 'm3', memberName: 'Roberto Martínez', gymId: 'g1', amount: 50, date: DateTime.now().subtract(const Duration(days: 35)), membershipPlanId: 'plan_standard', membershipPlanName: 'Estándar', method: PaymentMethod.bankTransfer, status: PaymentStatus.overdue, currency: 'USD'),
      Payment(id: '4', memberId: 'm4', memberName: 'María Rodríguez', gymId: 'g1', amount: 30, date: DateTime.now(), membershipPlanId: 'plan_basic', membershipPlanName: 'Básico', method: PaymentMethod.cash, status: PaymentStatus.pending, currency: 'USD'),
      Payment(id: '5', memberId: 'm5', memberName: 'Juan Pérez', gymId: 'g1', amount: 400, date: DateTime.now().subtract(const Duration(days: 10)), membershipPlanId: 'plan_elite', membershipPlanName: 'Elite', method: PaymentMethod.creditCard, status: PaymentStatus.completed, currency: 'USD'),
    ];
  }
}

class _RevCard extends StatelessWidget {
  final String label, value; final Color color;
  const _RevCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const Gap(4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
      ]),
    ),
  );
}

class _PaymentList extends StatelessWidget {
  final List<Payment> payments;
  const _PaymentList({required this.payments});

  IconData _methodIcon(PaymentMethod m) => switch(m) {
    PaymentMethod.cash => Icons.payments,
    PaymentMethod.creditCard => Icons.credit_card,
    PaymentMethod.debitCard => Icons.credit_card,
    PaymentMethod.bankTransfer => Icons.account_balance,
    PaymentMethod.qrCode => Icons.qr_code,
    PaymentMethod.paypal => Icons.paypal,
    PaymentMethod.other => Icons.attach_money,
  };

  Color _statusColor(PaymentStatus s) => switch(s) {
    PaymentStatus.completed => AppColors.success, PaymentStatus.pending => AppColors.warning,
    PaymentStatus.overdue => AppColors.error, PaymentStatus.refunded => AppColors.accent,
    PaymentStatus.cancelled => AppColors.textMuted,
  };

  String _statusLabel(PaymentStatus s) => switch(s) {
    PaymentStatus.completed => 'Pagado', PaymentStatus.pending => 'Pendiente',
    PaymentStatus.overdue => 'Vencido', PaymentStatus.refunded => 'Reembolsado',
    PaymentStatus.cancelled => 'Cancelado',
  };

  @override
  Widget build(BuildContext context) => payments.isEmpty
      ? const Center(child: Text('Sin registros', style: TextStyle(color: AppColors.textMuted)))
      : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: payments.length,
          separatorBuilder: (_, __) => const Gap(6),
          itemBuilder: (_, i) {
            final p = payments[i];
            final sc = _statusColor(p.status);
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(_methodIcon(p.method), color: sc, size: 18)),
                const Gap(10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.memberName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(p.membershipPlanName, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('\$${p.amount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: sc.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text(_statusLabel(p.status), style: TextStyle(color: sc, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ]),
            );
          },
        );
}
