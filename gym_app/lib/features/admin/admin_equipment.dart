import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/equipment_provider.dart';

class AdminEquipmentScreen extends ConsumerStatefulWidget {
  const AdminEquipmentScreen({super.key});
  @override
  ConsumerState<AdminEquipmentScreen> createState() => _AdminEquipmentScreenState();
}

class _AdminEquipmentScreenState extends ConsumerState<AdminEquipmentScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equipmentProvider);
    final byCategory = ref.watch(equipmentByCategoryProvider);
    final dueMaintenance = ref.watch(maintenanceDueProvider);

    final categories = state.equipment.map((e) => e.category).toSet().toList()..sort();
    final operational = state.equipment.where((e) => e.status == EquipmentStatus.operational).length;
    final inMaint = state.equipment.where((e) => e.status == EquipmentStatus.maintenance).length;
    final outOfService = state.equipment.where((e) => e.status == EquipmentStatus.outOfService).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: const Text('Equipamiento', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
            actions: [
              IconButton(icon: const Icon(Icons.search, color: AppColors.textSecondary), onPressed: () {}),
              IconButton(icon: const Icon(Icons.filter_list, color: AppColors.textSecondary), onPressed: () => _showFilter(context, categories)),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Stats
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(children: [
                  _StatChip(label: 'Total', value: '${state.equipment.length}', color: AppColors.primary),
                  const Gap(8),
                  _StatChip(label: 'Operativo', value: '$operational', color: AppColors.success),
                  const Gap(8),
                  _StatChip(label: 'Mant.', value: '$inMaint', color: AppColors.warning),
                  const Gap(8),
                  _StatChip(label: 'Fuera', value: '$outOfService', color: AppColors.error),
                ]),
              ),

              // Maintenance alerts
              if (dueMaintenance.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.build_circle, color: AppColors.warning, size: 18),
                        const Gap(8),
                        Text('${dueMaintenance.length} con mantenimiento próximo',
                            style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 13)),
                      ]),
                      const Gap(8),
                      ...dueMaintenance.take(3).map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          const Gap(26),
                          Expanded(child: Text(e.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                          if (e.nextMaintenanceDate != null)
                            Text(_daysLabel(e.nextMaintenanceDate!),
                                style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600)),
                        ]),
                      )),
                    ]),
                  ),
                ),
                const Gap(16),
              ],

              // Category filter chips
              if (categories.length > 1) ...[
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, __) => const Gap(8),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return _CatChip(label: 'Todos', selected: _selectedCategory == null,
                            onTap: () { setState(() => _selectedCategory = null); ref.read(equipmentProvider.notifier).filterByCategory(null); });
                      }
                      final cat = categories[i - 1];
                      return _CatChip(label: cat, selected: _selectedCategory == cat,
                          onTap: () { setState(() => _selectedCategory = cat); ref.read(equipmentProvider.notifier).filterByCategory(cat); });
                    },
                  ),
                ),
                const Gap(16),
              ],

              // Equipment by category
              ...byCategory.entries.map((entry) => _CategorySection(
                title: entry.key,
                items: entry.value,
                onEdit: (item) => _showEditDialog(context, item),
                onDelete: (id) => _confirmDelete(context, id),
                onMaintenance: (item) => _showMaintenanceSheet(context, item),
              )),

              const Gap(80),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar Equipo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  String _daysLabel(DateTime date) {
    final days = date.difference(DateTime.now()).inDays;
    if (days < 0) return 'Vencido';
    if (days == 0) return 'Hoy';
    return 'en $days días';
  }

  void _showFilter(BuildContext context, List<String> categories) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Filtrar por Categoría', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const Gap(16),
        Wrap(spacing: 8, children: categories.map((c) => FilterChip(label: Text(c), selected: _selectedCategory == c,
            onSelected: (_) { setState(() => _selectedCategory = c); ref.read(equipmentProvider.notifier).filterByCategory(c); Navigator.pop(context); })).toList()),
        const Gap(16),
      ])),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('¿Eliminar equipo?', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Esta acción no se puede deshacer.', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () { ref.read(equipmentProvider.notifier).deleteEquipment(id); Navigator.pop(context); },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error))),
      ],
    ));
  }

  void _showEditDialog(BuildContext context, EquipmentItem item) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(item.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _InfoRow('Marca', item.brand),
        _InfoRow('Modelo', item.model ?? '-'),
        _InfoRow('S/N', item.serialNumber ?? '-'),
        _InfoRow('Cantidad', '${item.quantity}'),
        _InfoRow('Estado', item.status.displayName),
        if (item.maintenanceNotes != null) _InfoRow('Notas', item.maintenanceNotes!),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        TextButton(onPressed: () {
          Navigator.pop(context);
          ref.read(equipmentProvider.notifier).updateEquipment(
            item.copyWith(status: item.status == EquipmentStatus.operational ? EquipmentStatus.maintenance : EquipmentStatus.operational));
        }, child: const Text('Cambiar Estado')),
      ],
    ));
  }

  void _showMaintenanceSheet(BuildContext context, EquipmentItem item) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Mantenimiento: ${item.name}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const Gap(20),
        ListTile(
          leading: const Icon(Icons.check_circle, color: AppColors.success),
          title: const Text('Marcar como completado', style: TextStyle(color: AppColors.textPrimary)),
          onTap: () { ref.read(equipmentProvider.notifier).markMaintenanceComplete(item.id); Navigator.pop(context); },
        ),
        ListTile(
          leading: const Icon(Icons.schedule, color: AppColors.warning),
          title: const Text('Programar mantenimiento', style: TextStyle(color: AppColors.textPrimary)),
          onTap: () async {
            Navigator.pop(context);
            final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (date != null) ref.read(equipmentProvider.notifier).scheduleMaintenance(item.id, date);
          },
        ),
        const Gap(8),
      ])),
    );
  }

  void _showAddSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    String category = 'Cardio';

    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: StatefulBuilder(builder: (_, ss) => Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Agregar Equipo', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
          const Gap(16),
          TextField(controller: nameCtrl, style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Nombre del equipo', filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted))),
          const Gap(12),
          TextField(controller: brandCtrl, style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Marca', filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted))),
          const Gap(12),
          Row(children: [
            Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Cantidad', filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted)))),
            const Gap(12),
            Expanded(child: DropdownButtonFormField<String>(
              value: category,
              dropdownColor: AppColors.card,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(labelText: 'Categoría', filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted)),
              items: ['Cardio', 'Pesas Libres', 'Máquinas de Fuerza', 'Funcional', 'Accesorios', 'Studio', 'Recuperación']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => ss(() => category = v!),
            )),
          ]),
          const Gap(20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              ref.read(equipmentProvider.notifier).addEquipment(EquipmentItem(
                id: 'eq_${DateTime.now().millisecondsSinceEpoch}', gymId: 'g1',
                name: nameCtrl.text, category: category, brand: brandCtrl.text.isEmpty ? 'Sin marca' : brandCtrl.text,
                purchaseDate: DateTime.now(), quantity: int.tryParse(qtyCtrl.text) ?? 1,
              ));
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

class _CategorySection extends StatelessWidget {
  final String title;
  final List<EquipmentItem> items;
  final void Function(EquipmentItem) onEdit;
  final void Function(String) onDelete;
  final void Function(EquipmentItem) onMaintenance;

  const _CategorySection({required this.title, required this.items, required this.onEdit, required this.onDelete, required this.onMaintenance});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13))),
    ...items.map((item) => _EquipmentTile(item: item, onEdit: onEdit, onDelete: onDelete, onMaintenance: onMaintenance)),
    const Gap(16),
  ]);
}

class _EquipmentTile extends StatelessWidget {
  final EquipmentItem item;
  final void Function(EquipmentItem) onEdit;
  final void Function(String) onDelete;
  final void Function(EquipmentItem) onMaintenance;

  const _EquipmentTile({required this.item, required this.onEdit, required this.onDelete, required this.onMaintenance});

  Color get _statusColor => switch(item.status) {
    EquipmentStatus.operational => AppColors.success,
    EquipmentStatus.maintenance => AppColors.warning,
    EquipmentStatus.outOfService => AppColors.error,
    EquipmentStatus.retired => AppColors.textMuted,
  };

  IconData get _categoryIcon => switch(item.category) {
    'Cardio' => Icons.directions_run,
    'Pesas Libres' => Icons.fitness_center,
    'Máquinas de Fuerza' => Icons.sports_gymnastics,
    'Funcional' => Icons.sports,
    _ => Icons.build,
  };

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: GestureDetector(
      onTap: () => onEdit(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.isMaintenanceDue ? AppColors.warning.withOpacity(0.5) : AppColors.border),
        ),
        child: Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(_categoryIcon, color: _statusColor, size: 20)),
          const Gap(12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            const Gap(2),
            Text('${item.brand}${item.model != null ? " · ${item.model}" : ""}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: _statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(item.status.displayName, style: TextStyle(color: _statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            const Gap(4),
            Text('x${item.quantity}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
          const Gap(4),
          PopupMenuButton<String>(
            color: AppColors.card,
            icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 18),
            onSelected: (v) {
              if (v == 'maint') onMaintenance(item);
              if (v == 'delete') onDelete(item.id);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'maint', child: Row(children: [Icon(Icons.build, size: 16, color: AppColors.warning), Gap(8), Text('Mantenimiento', style: TextStyle(color: AppColors.textPrimary))])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: AppColors.error), Gap(8), Text('Eliminar', style: TextStyle(color: AppColors.error))])),
            ],
          ),
        ]),
      ),
    ),
  );
}

class _StatChip extends StatelessWidget {
  final String label, value; final Color color;
  const _StatChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ]),
  ));
}

class _CatChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _CatChip({required this.label, required this.selected, required this.onTap});
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

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    SizedBox(width: 70, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
    Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
  ]));
}
