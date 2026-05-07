import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/models/staff_model.dart';

// ---------------------------------------------------------------------------
// Mock provider
// ---------------------------------------------------------------------------

final _staffProvider = StateProvider<List<StaffMember>>((ref) => _mockStaff());

List<StaffMember> _mockStaff() => [
  StaffMember(id: 's1', gymId: 'g1', name: 'Carlos Mendoza', email: 'carlos@fitpro.com', phone: '+57 300 111 2233',
      role: StaffRole.personalTrainer, salary: 2800, hireDate: DateTime(2021, 3, 10),
      specializations: ['Powerlifting', 'Funcional'], certifications: ['NSCA-CSCS', 'FMS'], rating: 4.9, totalMembers: 18, totalClasses: 0),
  StaffMember(id: 's2', gymId: 'g1', name: 'Ana Ríos', email: 'ana@fitpro.com', phone: '+57 311 222 3344',
      role: StaffRole.groupInstructor, salary: 2200, hireDate: DateTime(2022, 1, 15),
      specializations: ['Spinning', 'Yoga', 'Pilates'], certifications: ['ACE GFI', 'RPM'], rating: 4.8, totalClasses: 240),
  StaffMember(id: 's3', gymId: 'g1', name: 'Miguel Torres', email: 'miguel@fitpro.com', phone: '+57 320 333 4455',
      role: StaffRole.gymManager, salary: 4500, hireDate: DateTime(2020, 6, 1),
      specializations: ['Gestión Deportiva'], certifications: ['MBA Deportivo'], rating: 4.7, totalMembers: 0, totalClasses: 0),
  StaffMember(id: 's4', gymId: 'g1', name: 'Laura Vega', email: 'laura@fitpro.com', phone: '+57 315 444 5566',
      role: StaffRole.nutritionist, salary: 3200, hireDate: DateTime(2023, 2, 20),
      specializations: ['Nutrición Deportiva', 'Pérdida de Peso'], certifications: ['R.D.', 'ISAK'], rating: 5.0, totalMembers: 25),
  StaffMember(id: 's5', gymId: 'g1', name: 'Pedro Castillo', email: 'pedro@fitpro.com',
      role: StaffRole.receptionist, salary: 1600, hireDate: DateTime(2023, 8, 5)),
  StaffMember(id: 's6', gymId: 'g1', name: 'Sofía Herrera', email: 'sofia@fitpro.com', phone: '+57 313 555 6677',
      role: StaffRole.personalTrainer, salary: 2600, hireDate: DateTime(2022, 9, 12),
      specializations: ['Crossfit', 'Rehabilitación'], certifications: ['CrossFit L2', 'FMS'], rating: 4.6, totalMembers: 14),
  StaffMember(id: 's7', gymId: 'g1', name: 'Andrés Morales', email: 'andres@fitpro.com',
      role: StaffRole.physio, salary: 3500, hireDate: DateTime(2023, 4, 18),
      specializations: ['Fisioterapia Deportiva', 'Masajes'], certifications: ['PT', 'Manual Therapy'], rating: 4.9, totalMembers: 8),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AdminStaffScreen extends ConsumerStatefulWidget {
  const AdminStaffScreen({super.key});
  @override
  ConsumerState<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends ConsumerState<AdminStaffScreen> {
  StaffRole? _filterRole;

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(_staffProvider);
    final filtered = _filterRole == null ? staff : staff.where((s) => s.role == _filterRole).toList();
    final active = staff.where((s) => s.isActive).length;
    final trainers = staff.where((s) => s.role == StaffRole.personalTrainer || s.role == StaffRole.groupInstructor).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: const Text('Personal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
            actions: [
              IconButton(icon: const Icon(Icons.filter_list, color: AppColors.textSecondary), onPressed: () => _showFilter(context)),
            ],
          ),
          SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stats
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Row(children: [
              _SCard(label: 'Total Personal', value: '${staff.length}', color: AppColors.primary),
              const Gap(8),
              _SCard(label: 'Activos', value: '$active', color: AppColors.success),
              const Gap(8),
              _SCard(label: 'Entrenadores', value: '$trainers', color: AppColors.accent),
            ])),

            // Role filter chips
            SizedBox(height: 36, child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _RoleChip(label: 'Todos', selected: _filterRole == null, onTap: () => setState(() => _filterRole = null)),
                const Gap(8),
                ...StaffRole.values.map((r) => Padding(padding: const EdgeInsets.only(right: 8),
                    child: _RoleChip(label: _roleLabel(r), selected: _filterRole == r, onTap: () => setState(() => _filterRole = r)))),
              ],
            )),
            const Gap(16),

            // Staff list
            ...filtered.map((s) => _StaffTile(staff: s,
                onTap: () => _showDetail(context, s),
                onEdit: () => _showEditSheet(context, s))),
            const Gap(80),
          ])),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Agregar Personal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  String _roleLabel(StaffRole r) => switch(r) {
    StaffRole.gymManager => 'Manager',
    StaffRole.personalTrainer => 'Entrenador',
    StaffRole.groupInstructor => 'Instructor',
    StaffRole.receptionist => 'Recepción',
    StaffRole.nutritionist => 'Nutricionista',
    StaffRole.physio => 'Fisio',
    StaffRole.cleaner => 'Limpieza',
    StaffRole.security => 'Seguridad',
  };

  Color _roleColor(StaffRole r) => switch(r) {
    StaffRole.gymManager => AppColors.primary,
    StaffRole.personalTrainer => AppColors.success,
    StaffRole.groupInstructor => AppColors.accent,
    StaffRole.receptionist => AppColors.textSecondary,
    StaffRole.nutritionist => AppColors.warning,
    StaffRole.physio => const Color(0xFF7B2FF7),
    _ => AppColors.textMuted,
  };

  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Filtrar por Rol', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const Gap(16),
        Wrap(spacing: 8, children: [
          FilterChip(label: const Text('Todos'), selected: _filterRole == null,
              onSelected: (_) { setState(() => _filterRole = null); Navigator.pop(context); }),
          ...StaffRole.values.map((r) => FilterChip(label: Text(_roleLabel(r)), selected: _filterRole == r,
              onSelected: (_) { setState(() => _filterRole = r); Navigator.pop(context); })),
        ]),
        const Gap(16),
      ])),
    );
  }

  void _showDetail(BuildContext context, StaffMember s) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.7, maxChildSize: 0.95,
        builder: (_, ctrl) => SingleChildScrollView(controller: ctrl, padding: const EdgeInsets.all(20), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: CircleAvatar(radius: 36, backgroundColor: _roleColor(s.role).withOpacity(0.15),
              child: Text(s.name[0], style: TextStyle(color: _roleColor(s.role), fontSize: 28, fontWeight: FontWeight.w800)))),
          const Gap(12),
          Center(child: Text(s.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20))),
          Center(child: Text(s.role.displayName, style: TextStyle(color: _roleColor(s.role), fontSize: 13))),
          const Gap(20),
          if (s.rating != null) Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            ...List.generate(5, (i) => Icon(Icons.star, size: 18, color: i < s.rating!.floor() ? AppColors.warning : AppColors.border)),
            const Gap(6),
            Text('${s.rating!.toStringAsFixed(1)}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          ])),
          const Gap(20),
          _DetailRow(Icons.email_outlined, s.email),
          if (s.phone != null) _DetailRow(Icons.phone_outlined, s.phone!),
          _DetailRow(Icons.calendar_today, 'Contratado: ${s.hireDate.day}/${s.hireDate.month}/${s.hireDate.year}'),
          if (s.salary != null) _DetailRow(Icons.attach_money, 'Salario: \$${s.salary!.toStringAsFixed(0)}/mes'),
          if (s.totalMembers > 0) _DetailRow(Icons.people, '${s.totalMembers} miembros asignados'),
          if (s.totalClasses > 0) _DetailRow(Icons.event, '${s.totalClasses} clases impartidas'),
          const Gap(16),
          if (s.specializations.isNotEmpty) ...[
            const Text('Especialidades', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
            const Gap(8),
            Wrap(spacing: 8, runSpacing: 6, children: s.specializations.map((sp) => _Tag(sp, AppColors.primary)).toList()),
            const Gap(16),
          ],
          if (s.certifications.isNotEmpty) ...[
            const Text('Certificaciones', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
            const Gap(8),
            Wrap(spacing: 8, runSpacing: 6, children: s.certifications.map((c) => _Tag(c, AppColors.success)).toList()),
            const Gap(16),
          ],
          const Text('Horario', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
          const Gap(8),
          Row(children: [
            ...List.generate(7, (i) {
              final day = i + 1;
              final works = s.workingDays.contains(day);
              final label = ['L','M','X','J','V','S','D'][i];
              return Container(margin: const EdgeInsets.only(right: 6), width: 28, height: 28,
                decoration: BoxDecoration(color: works ? AppColors.primary : AppColors.border, borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text(label, style: TextStyle(color: works ? Colors.white : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))));
            }),
            const Gap(12),
            Text(s.workingHours, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
          const Gap(20),
        ])),
      ),
    );
  }

  void _showEditSheet(BuildContext context, StaffMember s) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Opciones: ${s.name}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const Gap(16),
        ListTile(
          leading: const Icon(Icons.toggle_on, color: AppColors.warning),
          title: Text(s.isActive ? 'Desactivar empleado' : 'Activar empleado',
              style: const TextStyle(color: AppColors.textPrimary)),
          onTap: () { Navigator.pop(context); },
        ),
        ListTile(
          leading: const Icon(Icons.delete, color: AppColors.error),
          title: const Text('Eliminar del sistema', style: TextStyle(color: AppColors.error)),
          onTap: () {
            ref.read(_staffProvider.notifier).state = ref.read(_staffProvider).where((m) => m.id != s.id).toList();
            Navigator.pop(context);
          },
        ),
        const Gap(8),
      ])),
    );
  }

  void _showAddSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    StaffRole role = StaffRole.personalTrainer;

    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: StatefulBuilder(builder: (_, ss) => Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Nuevo Personal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
          const Gap(16),
          TextField(controller: nameCtrl, style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Nombre completo', filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted))),
          const Gap(12),
          TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted))),
          const Gap(12),
          TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Teléfono', filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted))),
          const Gap(12),
          DropdownButtonFormField<StaffRole>(
            value: role, dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(labelText: 'Rol', filled: true, fillColor: AppColors.surface,
                border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted)),
            items: StaffRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.displayName))).toList(),
            onChanged: (v) => ss(() => role = v!),
          ),
          const Gap(20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
              final newStaff = StaffMember(
                id: 's_${DateTime.now().millisecondsSinceEpoch}', gymId: 'g1',
                name: nameCtrl.text, email: emailCtrl.text,
                phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                role: role, hireDate: DateTime.now(),
              );
              ref.read(_staffProvider.notifier).state = [...ref.read(_staffProvider), newStaff];
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Agregar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          )),
        ])),
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  const _StaffTile({required this.staff, required this.onTap, required this.onEdit});

  Color get _rc => switch(staff.role) {
    StaffRole.gymManager => AppColors.primary,
    StaffRole.personalTrainer => AppColors.success,
    StaffRole.groupInstructor => AppColors.accent,
    StaffRole.nutritionist => AppColors.warning,
    StaffRole.physio => const Color(0xFF7B2FF7),
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: _rc.withOpacity(0.15),
              child: Text(staff.name[0], style: TextStyle(color: _rc, fontWeight: FontWeight.w800, fontSize: 16))),
          const Gap(12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(staff.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            const Gap(2),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: _rc.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text(staff.role.displayName, style: TextStyle(color: _rc, fontSize: 10, fontWeight: FontWeight.w700))),
              if (!staff.isActive) ...[
                const Gap(6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Inactivo', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w700))),
              ],
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (staff.rating != null) Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star, size: 13, color: AppColors.warning),
              const Gap(2),
              Text('${staff.rating!.toStringAsFixed(1)}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
            if (staff.salary != null) Text('\$${staff.salary!.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
          const Gap(4),
          IconButton(icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 18), onPressed: onEdit, padding: EdgeInsets.zero),
        ]),
      ),
    ),
  );
}

class _SCard extends StatelessWidget {
  final String label, value; final Color color;
  const _SCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
    ]),
  ));
}

class _RoleChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _RoleChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon; final String text;
  const _DetailRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
    Icon(icon, size: 16, color: AppColors.textMuted),
    const Gap(10),
    Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
  ]));
}

class _Tag extends StatelessWidget {
  final String label; final Color color;
  const _Tag(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
