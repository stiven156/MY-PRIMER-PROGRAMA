import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mercados/features/employees/providers/employees_provider.dart';

// ---------------------------------------------------------------------------
// Role colour mapping
// ---------------------------------------------------------------------------

extension EmployeeRoleColor on EmployeeRole {
  Color get badgeColor {
    switch (this) {
      case EmployeeRole.manager:
        return const Color(0xFF6750A4); // purple
      case EmployeeRole.supervisor:
        return const Color(0xFF0277BD); // blue
      case EmployeeRole.cashier:
        return const Color(0xFF2E7D32); // green
      case EmployeeRole.stocker:
        return const Color(0xFFF57F17); // amber
      case EmployeeRole.deliveryPerson:
        return const Color(0xFFBF360C); // deep orange
    }
  }

  Color get badgeTextColor => Colors.white;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  EmployeeRole? _selectedRoleFilter;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeesProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final filtered = _selectedRoleFilter == null
        ? state.employees
        : state.employees
            .where((e) => e.role == _selectedRoleFilter)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () =>
                ref.read(employeesProvider.notifier).loadEmployees(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmployeeDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Añadir'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Role filter chips ─────────────────────────
                _RoleFilterChips(
                  selected: _selectedRoleFilter,
                  onSelected: (role) =>
                      setState(() => _selectedRoleFilter = role),
                ),
                // ── Employee list ─────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 64,
                                  color: cs.onSurface.withAlpha(80)),
                              const SizedBox(height: 12),
                              Text(
                                'Sin empleados',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: cs.onSurface.withAlpha(120),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => _EmployeeCard(
                            employee: filtered[i],
                            onEdit: () =>
                                _showEmployeeDialog(context, filtered[i]),
                            onToggleActive: () => ref
                                .read(employeesProvider.notifier)
                                .toggleActive(filtered[i].id),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  // ── Add / Edit dialog ─────────────────────────────────────────────────────

  Future<void> _showEmployeeDialog(BuildContext context,
      [Employee? existing]) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _EmployeeFormDialog(existing: existing),
    );
  }
}

// ---------------------------------------------------------------------------
// Role filter chips
// ---------------------------------------------------------------------------

class _RoleFilterChips extends StatelessWidget {
  const _RoleFilterChips({required this.selected, required this.onSelected});

  final EmployeeRole? selected;
  final ValueChanged<EmployeeRole?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _chip(context, null, 'Todos'),
          const SizedBox(width: 8),
          ...EmployeeRole.values.map(
            (r) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(context, r, r.label),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, EmployeeRole? role, String label) {
    final isSelected = selected == role;
    final color =
        role == null ? Theme.of(context).colorScheme.primary : role.badgeColor;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(isSelected ? null : role),
      selectedColor: color.withAlpha(40),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: isSelected ? BorderSide(color: color) : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Employee card
// ---------------------------------------------------------------------------

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({
    required this.employee,
    required this.onEdit,
    required this.onToggleActive,
  });

  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateStr =
        DateFormat('dd MMM yyyy', 'es').format(employee.hireDate);
    final roleColor = employee.role.badgeColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ─────────────────────────────
            _Avatar(
              initials: employee.initials,
              color: roleColor,
              isActive: employee.isActive,
            ),
            const SizedBox(width: 14),
            // ── Info ───────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          employee.fullName,
                          style: theme.textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RoleBadge(role: employee.role),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    text: employee.phone,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 3),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: 'Ingresó: $dateStr',
                    color: cs.onSurfaceVariant,
                  ),
                  if (!employee.isActive) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Inactivo',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // ── Actions ────────────────────────────
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: cs.onSurfaceVariant, size: 20),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'toggle') onToggleActive();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: ListTile(
                    leading: Icon(employee.isActive
                        ? Icons.person_off_outlined
                        : Icons.person_outline),
                    title: Text(employee.isActive ? 'Desactivar' : 'Activar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.color,
    required this.isActive,
  });

  final String initials;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withAlpha(30),
          child: Text(
            initials,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final EmployeeRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: role.badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          color: role.badgeTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Employee form dialog
// ---------------------------------------------------------------------------

class _EmployeeFormDialog extends ConsumerStatefulWidget {
  const _EmployeeFormDialog({this.existing});
  final Employee? existing;

  @override
  ConsumerState<_EmployeeFormDialog> createState() =>
      _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends ConsumerState<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _notes;
  late EmployeeRole _role;
  late DateTime _hireDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _firstName = TextEditingController(text: e?.firstName ?? '');
    _lastName = TextEditingController(text: e?.lastName ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _role = e?.role ?? EmployeeRole.cashier;
    _hireDate = e?.hireDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _hireDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final notifier = ref.read(employeesProvider.notifier);

    if (widget.existing == null) {
      await notifier.addEmployee(
        firstName: _firstName.text,
        lastName: _lastName.text,
        role: _role,
        phone: _phone.text,
        email: _email.text,
        hireDate: _hireDate,
        notes: _notes.text.isEmpty ? null : _notes.text,
      );
    } else {
      await notifier.updateEmployee(
        widget.existing!.copyWith(
          firstName: _firstName.text,
          lastName: _lastName.text,
          role: _role,
          phone: _phone.text,
          email: _email.text,
          hireDate: _hireDate,
          notes: _notes.text.isEmpty ? null : _notes.text,
          clearNotes: _notes.text.isEmpty,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd/MM/yyyy', 'es').format(_hireDate);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Empleado' : 'Nuevo Empleado'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _firstName,
                        label: 'Nombre',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Requerido'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        controller: _lastName,
                        label: 'Apellido',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Requerido'
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Role dropdown
                DropdownButtonFormField<EmployeeRole>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: EmployeeRole.values
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.label),
                          ))
                      .toList(),
                  onChanged: (r) {
                    if (r != null) setState(() => _role = r);
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _phone,
                  label: 'Teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _email,
                  label: 'Correo',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Hire date picker
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de ingreso',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(dateStr,
                        style: theme.textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _notes,
                  label: 'Notas (opcional)',
                  icon: Icons.notes_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Guardar' : 'Añadir'),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
