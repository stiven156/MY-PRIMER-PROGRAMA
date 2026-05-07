import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/members_provider.dart';
import 'package:gym_app/core/providers/body_tracking_provider.dart';
import 'package:gym_app/core/models/member_model.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Color get _statusColor {
    final state = ref.read(membersProvider);
    final m = state.members.firstWhere((m) => m.id == widget.memberId, orElse: () => MemberModel.mock());
    return switch(m.status) {
      MemberStatus.active => AppColors.success,
      MemberStatus.expired => AppColors.error,
      MemberStatus.frozen => AppColors.accent,
      MemberStatus.cancelled => AppColors.textMuted,
      MemberStatus.trial => AppColors.warning,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membersProvider);
    final member = state.members.firstWhere((m) => m.id == widget.memberId, orElse: () => MemberModel.mock());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: const BackButton(color: Colors.white),
            actions: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.qr_code, color: Colors.white), onPressed: () => _showQR(context, member)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.secondaryGradient),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    CircleAvatar(radius: 44, backgroundColor: Colors.white24,
                        child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32))),
                    const Gap(16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                      const Gap(4),
                      Text(member.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const Gap(6),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20), border: Border.all(color: _statusColor.withOpacity(0.6))),
                          child: Text(_statusLabel(member.status),
                              style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const Gap(8),
                        Text('${member.daysUntilExpiry} días', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ]),
                    ])),
                  ]),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              isScrollable: false,
              tabs: const [Tab(text: 'Resumen'), Tab(text: 'Progreso'), Tab(text: 'Historial'), Tab(text: 'Clases')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _SummaryTab(member: member),
            _ProgressTab(memberId: widget.memberId),
            _HistoryTab(member: member),
            _ClassesTab(member: member),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: () {
              ref.read(membersProvider.notifier).checkInMember(member.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✓ Check-in registrado para ${member.name}')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Check-in Manual'),
          )),
          const Gap(8),
          Expanded(child: ElevatedButton(
            onPressed: () {},
            child: const Text('Renovar Membresía'),
          )),
        ]),
      ),
    );
  }

  String _statusLabel(MemberStatus s) => switch(s) {
    MemberStatus.active => 'Activo', MemberStatus.expired => 'Vencido',
    MemberStatus.frozen => 'Congelado', MemberStatus.cancelled => 'Cancelado',
    MemberStatus.trial => 'Trial',
  };

  void _showQR(BuildContext context, MemberModel member) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(member.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        const Gap(16),
        Container(width: 160, height: 160, color: Colors.white, child: const Icon(Icons.qr_code, size: 120, color: Colors.black)),
        const Gap(12),
        Text(member.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ])),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final MemberModel member;
  const _SummaryTab({required this.member});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    // Membership card
    Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Membresía', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const Gap(12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Inicio:', style: TextStyle(color: AppColors.textSecondary)),
          Text('${member.startDate.day}/${member.startDate.month}/${member.startDate.year}',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ]),
        const Gap(6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Vence:', style: TextStyle(color: AppColors.textSecondary)),
          Text('${member.endDate.day}/${member.endDate.month}/${member.endDate.year}',
              style: TextStyle(color: member.isExpiringSoon ? AppColors.warning : AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ]),
        const Gap(10),
        LinearProgressIndicator(
          value: member.startDate.isBefore(member.endDate)
              ? 1 - (member.daysUntilExpiry / member.endDate.difference(member.startDate).inDays).clamp(0, 1)
              : 1,
          backgroundColor: AppColors.inputFill,
          valueColor: AlwaysStoppedAnimation(member.isExpiringSoon ? AppColors.warning : AppColors.primary),
          minHeight: 8, borderRadius: BorderRadius.circular(4),
        ),
        const Gap(6),
        Text(member.daysUntilExpiry > 0 ? 'Vence en ${member.daysUntilExpiry} días' : 'Membresía vencida',
            style: TextStyle(color: member.daysUntilExpiry > 0 ? AppColors.textSecondary : AppColors.error, fontSize: 12)),
      ]),
    ),
    const Gap(12),

    // Stats grid
    Row(children: [
      _InfoCard(icon: '🏃', label: 'Check-ins', value: '${member.totalCheckIns}'),
      const Gap(8),
      _InfoCard(icon: '💪', label: 'Entrenos', value: '${member.totalWorkouts}'),
      const Gap(8),
      _InfoCard(icon: '⭐', label: 'Puntos', value: '${member.totalPoints}'),
    ]),
    const Gap(12),

    // Personal info
    Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Información Personal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const Gap(12),
        _InfoRow('Teléfono', member.phone),
        if (member.birthDate != null) _InfoRow('Fecha de nacimiento',
            '${member.birthDate!.day}/${member.birthDate!.month}/${member.birthDate!.year} (${member.age} años)'),
        if (member.bloodType != null) _InfoRow('Tipo de sangre', member.bloodType!),
        if (member.gender.isNotEmpty) _InfoRow('Género', member.gender),
        if (member.weight != null) _InfoRow('Peso', '${member.weight} kg'),
        if (member.height != null) _InfoRow('Altura', '${member.height} cm'),
      ]),
    ),
    const Gap(12),

    if (member.emergencyContactName != null)
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Contacto de Emergencia', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          const Gap(12),
          _InfoRow('Nombre', member.emergencyContactName!),
          if (member.emergencyContactPhone != null) _InfoRow('Teléfono', member.emergencyContactPhone!),
        ]),
      ),
    if (member.notes != null && member.notes!.isNotEmpty) ...[
      const Gap(12),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Notas del Entrenador', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          const Gap(8),
          Text(member.notes!, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        ]),
      ),
    ],
    const Gap(80),
  ]);
}

class _InfoCard extends StatelessWidget {
  final String icon, label, value;
  const _InfoCard({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const Gap(4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ]),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
    ]));
}

class _ProgressTab extends ConsumerWidget {
  final String memberId;
  const _ProgressTab({required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spots = ref.watch(weightHistoryProvider);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Historial de Peso', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
      const Gap(12),
      SizedBox(height: 180, child: LineChart(LineChartData(
        lineBarsData: [LineChartBarData(
          spots: spots.isNotEmpty ? spots : [const FlSpot(0, 70)],
          isCurved: true, color: AppColors.primary, barWidth: 3,
          belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
          dotData: const FlDotData(show: false),
        )],
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40,
              getTitlesWidget: (v, _) => Text('${v.toInt()}kg', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ))),
      const Gap(20),
      const Text('Sin medidas recientes', style: TextStyle(color: AppColors.textSecondary)),
    ]);
  }
}

class _HistoryTab extends StatelessWidget {
  final MemberModel member;
  const _HistoryTab({required this.member});
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('Historial próximamente', style: TextStyle(color: AppColors.textSecondary)));
}

class _ClassesTab extends StatelessWidget {
  final MemberModel member;
  const _ClassesTab({required this.member});
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('Clases próximamente', style: TextStyle(color: AppColors.textSecondary)));
}
