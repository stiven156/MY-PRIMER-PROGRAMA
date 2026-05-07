import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/members_provider.dart';
import 'package:gym_app/core/models/member_model.dart';

class AdminMembersScreen extends ConsumerStatefulWidget {
  const AdminMembersScreen({super.key});
  @override
  ConsumerState<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends ConsumerState<AdminMembersScreen> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membersProvider);
    final filtered = ref.watch(filteredMembersProvider);
    final active = state.members.where((m) => m.status == MemberStatus.active).length;
    final expired = state.members.where((m) => m.status == MemberStatus.expired).length;
    final trial = state.members.where((m) => m.status == MemberStatus.trial).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: _searching
            ? TextField(controller: _searchCtrl, autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Buscar miembro...', border: InputBorder.none),
                onChanged: (q) => ref.read(membersProvider.notifier).searchMembers(q))
            : const Text('Miembros', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: Icon(_searching ? Icons.close : Icons.search, color: AppColors.textSecondary),
              onPressed: () { setState(() => _searching = !_searching); if (!_searching) { _searchCtrl.clear(); ref.read(membersProvider.notifier).searchMembers(''); } }),
          IconButton(icon: const Icon(Icons.filter_list, color: AppColors.textSecondary), onPressed: () => _showFilters(context)),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              _Chip('Total ${state.members.length}', null),
              const Gap(8), _Chip('Activos $active', AppColors.success),
              const Gap(8), _Chip('Vencidos $expired', AppColors.error),
              const Gap(8), _Chip('Trial $trial', AppColors.warning),
            ]),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.people_outline, color: AppColors.textMuted, size: 64),
                    Gap(16),
                    Text('Sin miembros', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18)),
                    Gap(8),
                    Text('Agrega tu primer miembro', style: TextStyle(color: AppColors.textSecondary)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Gap(8),
                    itemBuilder: (context, i) {
                      final m = filtered[i];
                      return Slidable(
                        key: ValueKey(m.id),
                        startActionPane: ActionPane(motion: const BehindMotion(), children: [
                          SlidableAction(onPressed: (_) {
                            ref.read(membersProvider.notifier).checkInMember(m.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Check-in: ${m.name}')));
                          }, backgroundColor: AppColors.success, icon: Icons.check, label: 'Check-in'),
                        ]),
                        endActionPane: ActionPane(motion: const BehindMotion(), children: [
                          SlidableAction(onPressed: (_) => context.push('/members/${m.id}'),
                              backgroundColor: AppColors.accent, icon: Icons.edit, label: 'Editar'),
                          SlidableAction(onPressed: (_) => _confirmDelete(context, m.id),
                              backgroundColor: AppColors.error, icon: Icons.delete, label: 'Eliminar'),
                        ]),
                        child: _MemberTile(member: m)
                            .animate(delay: (i * 30).ms).fadeIn(),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/members/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Filtrar Miembros', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        const Gap(16),
        const Text('Estado', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Gap(8),
        Wrap(spacing: 8, children: [null, ...MemberStatus.values].map((s) {
          final label = s == null ? 'Todos' : switch(s) {
            MemberStatus.active => 'Activo', MemberStatus.expired => 'Vencido',
            MemberStatus.frozen => 'Congelado', MemberStatus.cancelled => 'Cancelado',
            MemberStatus.trial => 'Trial',
          };
          return FilterChip(label: Text(label), selected: false,
              onSelected: (_) { ref.read(membersProvider.notifier).filterByStatus(s); Navigator.pop(context); });
        }).toList()),
        const Gap(16),
      ])),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('¿Eliminar miembro?', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Esta acción no se puede deshacer.', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () { ref.read(membersProvider.notifier).deleteMember(id); Navigator.pop(context); },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}

class _MemberTile extends StatelessWidget {
  final MemberModel member;
  const _MemberTile({required this.member});

  Color get _statusColor => switch(member.status) {
    MemberStatus.active => AppColors.success, MemberStatus.expired => AppColors.error,
    MemberStatus.frozen => AppColors.accent, MemberStatus.cancelled => AppColors.textMuted,
    MemberStatus.trial => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/members/${member.id}'),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Stack(children: [
          CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16))),
          Positioned(right: 0, bottom: 0, child: Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2)),
          )),
        ]),
        const Gap(12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(member.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          const Gap(2),
          Text(member.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), overflow: TextOverflow.ellipsis),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(member.daysUntilExpiry > 0 ? '${member.daysUntilExpiry}d' : 'Vencida',
                style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const Gap(4),
          Text('${member.totalCheckIns} check-ins', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ]),
      ]),
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label; final Color? color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: (color ?? AppColors.textMuted).withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: (color ?? AppColors.textMuted).withOpacity(0.3)),
    ),
    child: Text(label, style: TextStyle(color: color ?? AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}
