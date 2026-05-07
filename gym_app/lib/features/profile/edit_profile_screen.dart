import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  String _gender = 'Masculino';
  String _goal = 'Ganancia muscular';
  DateTime? _birthDate;
  bool _saving = false;

  static const _genderOptions = ['Masculino', 'Femenino', 'No binario', 'Prefiero no decir'];
  static const _goalOptions = ['Ganancia muscular', 'Pérdida de grasa', 'Resistencia', 'Fuerza', 'Flexibilidad', 'Salud general'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _gender = user?.gender ?? 'Masculino';
    _birthDate = user?.birthDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final initials = (_nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : user?.name?[0] ?? 'U').toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: BackButton(color: AppColors.textPrimary, onPressed: () => Navigator.pop(context)),
        title: const Text('Editar Perfil', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : const Text('Guardar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Avatar
        Center(child: Stack(children: [
          CircleAvatar(radius: 52, backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 36))),
          Positioned(right: 0, bottom: 0, child: GestureDetector(
            onTap: () {},
            child: Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 2)),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16)),
          )),
        ])),
        const Gap(28),

        _Section('👤 Información Personal', [
          _buildField(_nameCtrl, 'Nombre completo', Icons.person, onChanged: (_) => setState(() {})),
          const Gap(12),
          _buildField(_emailCtrl, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
          const Gap(12),
          _buildField(_phoneCtrl, 'Teléfono', Icons.phone, keyboardType: TextInputType.phone),
          const Gap(12),
          _buildField(_bioCtrl, 'Bio / Descripción', Icons.notes, maxLines: 3),
        ]),

        _Section('⚧ Género', [
          Wrap(spacing: 8, runSpacing: 8, children: _genderOptions.map((g) {
            final selected = _gender == g;
            return GestureDetector(
              onTap: () => setState(() => _gender = g),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.card,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                ),
                child: Text(g, style: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
              ),
            );
          }).toList()),
        ]),

        _Section('🎂 Fecha de Nacimiento', [
          GestureDetector(
            onTap: _pickBirthDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 20),
                const Gap(12),
                Expanded(child: Text(
                  _birthDate != null
                      ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                      : 'Selecciona tu fecha de nacimiento',
                  style: TextStyle(color: _birthDate != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 14),
                )),
                if (_birthDate != null) Text('${_age} años', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ]),
            ),
          ),
        ]),

        _Section('🎯 Objetivo Principal', [
          Wrap(spacing: 8, runSpacing: 8, children: _goalOptions.map((g) {
            final selected = _goal == g;
            final color = _goalColor(g);
            return GestureDetector(
              onTap: () => setState(() => _goal = g),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? color.withOpacity(0.15) : AppColors.card,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: selected ? color : AppColors.border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_goalEmoji(g)),
                  const Gap(6),
                  Text(g, style: TextStyle(color: selected ? color : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 12)),
                ]),
              ),
            );
          }).toList()),
        ]),

        _Section('🔐 Seguridad', [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
            title: const Text('Cambiar contraseña', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
            onTap: () => _showChangePassword(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fingerprint, color: AppColors.textSecondary, size: 20),
            title: const Text('Autenticación biométrica', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            trailing: Switch(value: false, onChanged: (_) {}, activeColor: AppColors.primary),
          ),
        ]),

        const Gap(40),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        const Gap(40),
      ]),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType, void Function(String)? onChanged}) {
    return TextField(
      controller: ctrl, maxLines: maxLines, keyboardType: keyboardType, onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        filled: true, fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  int get _age {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month || (now.month == _birthDate!.month && now.day < _birthDate!.day)) age--;
    return age;
  }

  Color _goalColor(String g) {
    if (g.contains('muscular')) return AppColors.primary;
    if (g.contains('grasa')) return AppColors.error;
    if (g.contains('Resistencia')) return AppColors.accent;
    if (g.contains('Fuerza')) return AppColors.warning;
    if (g.contains('Flex')) return AppColors.success;
    return AppColors.textSecondary;
  }

  String _goalEmoji(String g) {
    if (g.contains('muscular')) return '💪';
    if (g.contains('grasa')) return '🔥';
    if (g.contains('Resistencia')) return '🏃';
    if (g.contains('Fuerza')) return '🏋️';
    if (g.contains('Flex')) return '🧘';
    return '⚡';
  }

  Future<void> _pickBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1995),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
    );
    if (date != null) setState(() => _birthDate = date);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre no puede estar vacío')));
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }

  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true, obscureNew = true, obscureConfirm = true;

    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: StatefulBuilder(builder: (_, ss) => Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Cambiar Contraseña', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
          const Gap(20),
          _pwField(currentCtrl, 'Contraseña actual', obscureCurrent, () => ss(() => obscureCurrent = !obscureCurrent)),
          const Gap(12),
          _pwField(newCtrl, 'Nueva contraseña', obscureNew, () => ss(() => obscureNew = !obscureNew)),
          const Gap(12),
          _pwField(confirmCtrl, 'Confirmar contraseña', obscureConfirm, () => ss(() => obscureConfirm = !obscureConfirm)),
          const Gap(20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden')));
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña cambiada'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Cambiar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          )),
        ])),
      ),
    );
  }

  Widget _pwField(TextEditingController ctrl, String label, bool obscure, VoidCallback toggle) =>
      TextField(controller: ctrl, obscureText: obscure, style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 20),
              suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 18), onPressed: toggle),
              filled: true, fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border))));
}

class _Section extends StatelessWidget {
  final String title; final List<Widget> children;
  const _Section(this.title, this.children);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13))),
    Container(
      padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: children),
    ),
  ]);
}
