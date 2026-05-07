import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/members_provider.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/core/models/member_model.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});
  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _form = GlobalKey<FormState>();
  int _step = 0;

  // Personal data
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _gender = 'Masculino';
  DateTime? _birthDate;
  String? _bloodType;

  // Membership
  String _planId = 'plan_basic';
  DateTime _startDate = DateTime.now();

  // Goals
  final Set<MemberGoal> _goals = {};

  // Emergency
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();

  // Measurements
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _notes = TextEditingController();

  final _steps = ['Personal', 'Membresía', 'Objetivos', 'Emergencia'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Nuevo Miembro', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_steps.length * 2 - 1, (i) {
                if (i.isOdd) return Expanded(child: Container(height: 2,
                    color: i ~/ 2 < _step ? AppColors.primary : AppColors.border));
                final idx = i ~/ 2;
                return Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: idx <= _step ? AppColors.primary : AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: idx <= _step ? AppColors.primary : AppColors.border),
                  ),
                  child: Center(child: idx < _step
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('${idx + 1}', style: TextStyle(
                          color: idx == _step ? Colors.white : AppColors.textMuted,
                          fontSize: 13, fontWeight: FontWeight.w700))),
                );
              }),
            ),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 8),
              child: Text(_steps[_step], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),

          Expanded(
            child: Form(
              key: _form,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: [
                  _step1(), _step2(), _step3(), _step4(),
                ][_step],
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              if (_step > 0)
                Expanded(child: OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  child: const Text('Atrás'),
                )),
              if (_step > 0) const Gap(12),
              Expanded(child: ElevatedButton(
                onPressed: _step < 3 ? () => setState(() => _step++) : _save,
                child: Text(_step < 3 ? 'Siguiente' : 'Guardar Miembro'),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _step1() => ListView(key: const ValueKey(0), padding: const EdgeInsets.all(16), children: [
    // Avatar placeholder
    Center(child: Column(children: [
      Container(width: 80, height: 80,
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
        child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 30)),
      const Gap(8),
      const Text('Subir Foto', style: TextStyle(color: AppColors.primary, fontSize: 13)),
    ])),
    const Gap(20),
    _Field('Nombre Completo *', _name, validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
    const Gap(12),
    _Field('Email *', _email, keyboard: TextInputType.emailAddress,
        validator: (v) => v?.contains('@') != true ? 'Email inválido' : null),
    const Gap(12),
    _Field('Teléfono', _phone, keyboard: TextInputType.phone),
    const Gap(12),
    Row(children: [
      Expanded(child: DropdownButtonFormField<String>(
        value: _gender,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: _deco('Género'),
        items: ['Masculino', 'Femenino', 'Otro'].map((g) =>
            DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _gender = v!),
      )),
      const Gap(12),
      Expanded(child: DropdownButtonFormField<String>(
        value: _bloodType,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: _deco('Tipo de sangre'),
        items: ['A+','A-','B+','B-','AB+','AB-','O+','O-'].map((g) =>
            DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _bloodType = v),
      )),
    ]),
    const Gap(12),
    GestureDetector(
      onTap: () async {
        final d = await showDatePicker(context: context,
          initialDate: DateTime(2000), firstDate: DateTime(1940), lastDate: DateTime.now(),
          builder: (_, w) => Theme(data: ThemeData.dark(), child: w!));
        if (d != null) setState(() => _birthDate = d);
      },
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_birthDate == null ? 'Fecha de nacimiento (opcional)' : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
              style: TextStyle(color: _birthDate == null ? AppColors.textMuted : AppColors.textPrimary)),
          const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 18),
        ])),
    ),
  ]);

  Widget _step2() => ListView(key: const ValueKey(1), padding: const EdgeInsets.all(16), children: [
    const Text('Selecciona el Plan', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
    const Gap(12),
    ...{
      'plan_basic': ['Básico', '\$30/mes', '30 días', AppColors.bronzeTier],
      'plan_standard': ['Estándar', '\$50/mes', '30 días', AppColors.silverTier],
      'plan_pro': ['Pro', '\$120/trim', '90 días', AppColors.goldTier],
      'plan_elite': ['Elite', '\$400/año', '365 días', AppColors.platinumTier],
    }.entries.map((e) {
      final selected = _planId == e.key;
      return GestureDetector(
        onTap: () => setState(() => _planId = e.key),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? (e.value[3] as Color).withOpacity(0.1) : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? (e.value[3] as Color) : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: (e.value[3] as Color).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(e.value[0][0], style: TextStyle(color: e.value[3] as Color, fontWeight: FontWeight.w800)))),
            const Gap(12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.value[0] as String, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              Text(e.value[2] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ])),
            Text(e.value[1] as String, style: TextStyle(color: e.value[3] as Color, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
    }),
    const Gap(12),
    GestureDetector(
      onTap: () async {
        final d = await showDatePicker(context: context,
          initialDate: _startDate, firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (_, w) => Theme(data: ThemeData.dark(), child: w!));
        if (d != null) setState(() => _startDate = d);
      },
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Inicio: ${_startDate.day}/${_startDate.month}/${_startDate.year}',
              style: const TextStyle(color: AppColors.textPrimary)),
          const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 18),
        ])),
    ),
  ]);

  Widget _step3() => ListView(key: const ValueKey(2), padding: const EdgeInsets.all(16), children: [
    const Text('Objetivos del Miembro', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
    const Gap(8),
    const Text('Selecciona uno o más objetivos', style: TextStyle(color: AppColors.textSecondary)),
    const Gap(16),
    Wrap(spacing: 10, runSpacing: 10, children: MemberGoal.values.map((g) {
      final selected = _goals.contains(g);
      const labels = {
        MemberGoal.weightLoss: '⚖️ Pérdida de peso',
        MemberGoal.muscleGain: '💪 Ganar músculo',
        MemberGoal.endurance: '🏃 Resistencia',
        MemberGoal.flexibility: '🧘 Flexibilidad',
        MemberGoal.generalFitness: '🎯 Fitness general',
        MemberGoal.rehabilitation: '🩺 Rehabilitación',
        MemberGoal.sportsPerformance: '🏆 Rendimiento',
        MemberGoal.weightMaintenance: '⚡ Mantenimiento',
      };
      return FilterChip(
        label: Text(labels[g] ?? g.name),
        selected: selected,
        onSelected: (v) => setState(() => v ? _goals.add(g) : _goals.remove(g)),
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      );
    }).toList()),
    const Gap(20),
    _Field('Peso (kg)', _weight, keyboard: TextInputType.number),
    const Gap(12),
    _Field('Altura (cm)', _height, keyboard: TextInputType.number),
  ]);

  Widget _step4() => ListView(key: const ValueKey(3), padding: const EdgeInsets.all(16), children: [
    const Text('Contacto de Emergencia', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
    const Gap(8),
    const Text('Opcional pero muy recomendado', style: TextStyle(color: AppColors.textSecondary)),
    const Gap(16),
    _Field('Nombre del contacto', _emergencyName),
    const Gap(12),
    _Field('Teléfono del contacto', _emergencyPhone, keyboard: TextInputType.phone),
    const Gap(16),
    const Text('Notas para el Entrenador', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
    const Gap(8),
    TextFormField(
      controller: _notes, maxLines: 4,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _deco('Lesiones, condiciones médicas, preferencias...'),
    ),
  ]);

  InputDecoration _deco(String hint) => InputDecoration(labelText: hint);

  Widget _Field(String label, TextEditingController ctrl,
      {TextInputType? keyboard, String? Function(String?)? validator}) =>
    TextFormField(
      controller: ctrl, keyboardType: keyboard,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );

  void _save() {
    if (_form.currentState?.validate() != true) return;
    final gymId = ref.read(authProvider).currentGymId ?? '';
    final endDate = _startDate.add(const Duration(days: 30));
    final member = MemberModel(
      id: const Uuid().v4(),
      gymId: gymId,
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      membershipPlanId: _planId,
      startDate: _startDate,
      endDate: endDate,
      goals: _goals.toList(),
      gender: _gender,
      birthDate: _birthDate,
      bloodType: _bloodType,
      weight: double.tryParse(_weight.text),
      height: double.tryParse(_height.text),
      emergencyContactName: _emergencyName.text.isEmpty ? null : _emergencyName.text,
      emergencyContactPhone: _emergencyPhone.text.isEmpty ? null : _emergencyPhone.text,
      notes: _notes.text.isEmpty ? null : _notes.text,
      createdAt: DateTime.now(),
    );
    ref.read(membersProvider.notifier).addMember(member);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ ${member.name} añadido exitosamente')),
    );
    Navigator.pop(context);
  }
}
