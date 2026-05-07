import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/schedule_provider.dart';
import 'package:gym_app/core/models/gym_class_model.dart';

class AddClassScreen extends ConsumerStatefulWidget {
  final GymClass? existingClass;
  const AddClassScreen({super.key, this.existingClass});

  @override
  ConsumerState<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends ConsumerState<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _instructorCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _durationCtrl;

  ClassCategory _category = ClassCategory.spinning;
  ClassDifficulty _difficulty = ClassDifficulty.beginner;
  DateTime _startDate = DateTime.now().add(const Duration(hours: 2));
  bool _isRecurring = false;
  List<int> _recurringDays = [];
  double _price = 0;
  bool _isFree = true;
  Color _color = AppColors.primary;
  bool _saving = false;

  static const _colorOptions = [
    AppColors.primary, AppColors.success, AppColors.accent, AppColors.warning,
    Color(0xFF7B2FF7), Color(0xFFFF6B35), Color(0xFF00BFA5), Color(0xFFE91E63),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.existingClass;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _instructorCtrl = TextEditingController(text: c?.instructorName ?? '');
    _locationCtrl = TextEditingController(text: c?.location ?? '');
    _capacityCtrl = TextEditingController(text: '${c?.maxCapacity ?? 20}');
    _durationCtrl = TextEditingController(text: '${c?.durationMinutes ?? 60}');
    if (c != null) {
      _category = c.category;
      _difficulty = c.difficulty;
      _startDate = c.startTime;
      _price = c.price;
      _isFree = c.price == 0;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _instructorCtrl.dispose();
    _locationCtrl.dispose(); _capacityCtrl.dispose(); _durationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingClass != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: BackButton(color: AppColors.textPrimary, onPressed: () => Navigator.pop(context)),
        title: Text(isEdit ? 'Editar Clase' : 'Nueva Clase',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : const Text('Guardar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          // Color + preview banner
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _color.withOpacity(0.4)),
            ),
            child: Center(child: Text(
              _nameCtrl.text.isEmpty ? 'Nombre de la clase' : _nameCtrl.text,
              style: TextStyle(color: _color, fontWeight: FontWeight.w800, fontSize: 20),
            )),
          ),
          const Gap(8),

          // Color picker
          SizedBox(height: 32, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _colorOptions.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (_, i) {
              final c = _colorOptions[i];
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(width: 28, height: 28,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                    border: Border.all(color: _color == c ? Colors.white : Colors.transparent, width: 3)),
                ),
              );
            },
          )),
          const Gap(20),

          // Name
          _buildField(_nameCtrl, 'Nombre de la clase', Icons.fitness_center,
              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              onChanged: (_) => setState(() {})),
          const Gap(12),

          // Description
          _buildField(_descCtrl, 'Descripción (opcional)', Icons.description, maxLines: 3),
          const Gap(12),

          // Instructor
          _buildField(_instructorCtrl, 'Instructor', Icons.person,
              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null),
          const Gap(12),

          // Location
          _buildField(_locationCtrl, 'Ubicación (sala, zona...)', Icons.room),
          const Gap(20),

          // Category & Difficulty row
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Categoría', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              const Gap(8),
              DropdownButtonFormField<ClassCategory>(
                value: _category, dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(filled: true, fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border))),
                items: ClassCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ])),
            const Gap(12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Dificultad', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              const Gap(8),
              DropdownButtonFormField<ClassDifficulty>(
                value: _difficulty, dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(filled: true, fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border))),
                items: ClassDifficulty.values.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                onChanged: (v) => setState(() => _difficulty = v!),
              ),
            ])),
          ]),
          const Gap(20),

          // Capacity & Duration row
          Row(children: [
            Expanded(child: _buildField(_capacityCtrl, 'Capacidad', Icons.people, keyboardType: TextInputType.number)),
            const Gap(12),
            Expanded(child: _buildField(_durationCtrl, 'Duración (min)', Icons.timer, keyboardType: TextInputType.number)),
          ]),
          const Gap(20),

          // Date & Time
          const Text('Fecha y Hora', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const Gap(8),
          GestureDetector(
            onTap: _pickDateTime,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const Gap(12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_formatDate(_startDate), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(_formatTime(_startDate), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ])),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ]),
            ),
          ),
          const Gap(20),

          // Recurring
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.repeat, color: AppColors.textSecondary, size: 20),
                const Gap(12),
                const Expanded(child: Text('Clase recurrente', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                Switch(value: _isRecurring, onChanged: (v) => setState(() => _isRecurring = v), activeColor: AppColors.primary),
              ]),
              if (_isRecurring) ...[
                const Gap(12),
                const Divider(color: AppColors.border, height: 1),
                const Gap(12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final label = ['L', 'M', 'X', 'J', 'V', 'S', 'D'][i];
                      final selected = _recurringDays.contains(day);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (selected) _recurringDays.remove(day); else _recurringDays.add(day);
                        }),
                        child: Container(width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 13))),
                        ),
                      );
                    })),
              ],
            ]),
          ),
          const Gap(20),

          // Price
          const Text('Precio', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const Gap(8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.attach_money, color: AppColors.textSecondary, size: 20),
                const Gap(12),
                const Expanded(child: Text('Clase gratuita', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                Switch(value: _isFree, onChanged: (v) => setState(() { _isFree = v; if (v) _price = 0; }), activeColor: AppColors.success),
              ]),
              if (!_isFree) ...[
                const Gap(12),
                const Divider(color: AppColors.border, height: 1),
                const Gap(12),
                Row(children: [
                  const Text('\$', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800)),
                  const Gap(8),
                  Expanded(child: Text('${_price.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700))),
                ]),
                Slider(value: _price, min: 0, max: 100, divisions: 20,
                    activeColor: AppColors.primary, inactiveColor: AppColors.border,
                    onChanged: (v) => setState(() => _price = v)),
              ],
            ]),
          ),
          const Gap(40),

          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(isEdit ? 'Guardar Cambios' : 'Crear Clase',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          )),
          const Gap(40),
        ]),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator, void Function(String)? onChanged}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        filled: true, fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context, initialDate: _startDate,
      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_startDate));
    if (time == null) return;
    setState(() => _startDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final durationMins = int.tryParse(_durationCtrl.text) ?? 60;
    final gymClass = GymClass(
      id: widget.existingClass?.id ?? 'class_${DateTime.now().millisecondsSinceEpoch}',
      gymId: 'g1',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      instructorId: 'instructor_1',
      instructorName: _instructorCtrl.text.trim(),
      category: _category,
      difficulty: _difficulty,
      startTime: _startDate,
      endTime: _startDate.add(Duration(minutes: durationMins)),
      maxCapacity: int.tryParse(_capacityCtrl.text) ?? 20,
      location: _locationCtrl.text.trim(),
      price: _isFree ? 0 : _price,
      color: '#${_color.value.toRadixString(16).substring(2).toUpperCase()}',
    );

    if (widget.existingClass != null) {
      ref.read(scheduleProvider.notifier).updateClass(gymClass);
    } else {
      ref.read(scheduleProvider.notifier).addClass(gymClass);
    }

    if (mounted) { setState(() => _saving = false); Navigator.pop(context); }
  }

  String _formatDate(DateTime d) {
    const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    final days = ['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'];
    return '${days[d.weekday - 1]}, ${d.day} de ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    final end = d.add(Duration(minutes: int.tryParse(_durationCtrl.text) ?? 60));
    final eh = end.hour.toString().padLeft(2, '0');
    final em = end.minute.toString().padLeft(2, '0');
    return '$h:$m - $eh:$em';
  }
}
