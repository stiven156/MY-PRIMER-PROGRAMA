import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/workout_provider.dart';
import 'package:gym_app/core/models/workout_model.dart';
import 'package:gym_app/core/models/exercise_model.dart';
import 'package:gym_app/core/data/exercises_data.dart';

class CreateWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutPlan? existingPlan;
  const CreateWorkoutScreen({super.key, this.existingPlan});

  @override
  ConsumerState<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends ConsumerState<CreateWorkoutScreen> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  WorkoutGoal _goal = WorkoutGoal.muscleMass;
  int _durationWeeks = 4;
  int _daysPerWeek = 3;
  bool _isSaving = false;

  // Days: local name + exercises
  final List<_DayData> _days = [];

  @override
  void initState() {
    super.initState();
    final plan = widget.existingPlan;
    if (plan != null) {
      _nameCtrl.text = plan.name;
      _descCtrl.text = plan.description;
      _goal = plan.goal;
      _durationWeeks = plan.durationWeeks;
      for (final d in plan.days) {
        _days.add(_DayData(
          name: d.name,
          exercises: d.exercises.map((e) => _ExData(exercise: e.exercise, sets: e.sets.length, reps: e.sets.first.targetReps ?? 12, weight: e.sets.first.targetWeight)).toList(),
        ));
      }
      _daysPerWeek = _days.length;
    } else {
      _days.add(_DayData(name: 'Día 1', exercises: []));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: BackButton(color: AppColors.textPrimary, onPressed: () => Navigator.pop(context)),
        title: Text(widget.existingPlan != null ? 'Editar Rutina' : 'Nueva Rutina',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 3, backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ),
      body: IndexedStack(
        index: _step,
        children: [_buildStep1(), _buildStep2(), _buildStep3()],
      ),
      bottomNavigationBar: _BottomBar(
        step: _step, isSaving: _isSaving,
        onBack: _step > 0 ? () => setState(() => _step--) : null,
        onNext: _step < 2 ? _goNext : _save,
      ),
    );
  }

  Widget _buildStep1() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Información básica', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
    const Gap(6),
    const Text('Define el nombre y objetivo de tu rutina', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
    const Gap(24),
    TextField(
      controller: _nameCtrl, onChanged: (_) => setState(() {}),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Nombre de la rutina', hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true, fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    ),
    const Gap(16),
    TextField(
      controller: _descCtrl, maxLines: 3,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Descripción (opcional)', hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true, fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    ),
    const Gap(24),
    const Text('Objetivo', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
    const Gap(10),
    Wrap(spacing: 8, runSpacing: 8, children: WorkoutGoal.values.map((g) {
      final selected = _goal == g;
      return GestureDetector(
        onTap: () => setState(() => _goal = g),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_goalEmoji(g)),
            const Gap(6),
            Text(_goalLabel(g), style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      );
    }).toList()),
    const Gap(24),
    const Text('Duración', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
    const Gap(10),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.textMuted), iconSize: 28,
          onPressed: _durationWeeks > 1 ? () => setState(() => _durationWeeks--) : null),
      Text('$_durationWeeks semanas', style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800)),
      IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary), iconSize: 28,
          onPressed: _durationWeeks < 24 ? () => setState(() => _durationWeeks++) : null),
    ]),
  ]);

  Widget _buildStep2() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Estructura semanal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
    const Gap(6),
    const Text('¿Cuántos días por semana entrenas?', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
    const Gap(24),
    Center(child: Column(children: [
      Text('$_daysPerWeek', style: const TextStyle(color: AppColors.primary, fontSize: 64, fontWeight: FontWeight.w900)),
      const Text('días / semana', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
    ])),
    const Gap(16),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(7, (i) {
      final d = i + 1;
      final selected = d <= _daysPerWeek;
      return GestureDetector(
        onTap: () => setState(() { _daysPerWeek = d; _syncDays(); }),
        child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 36, height: 36,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Center(child: Text('$d', style: TextStyle(color: selected ? AppColors.primary : AppColors.textMuted, fontWeight: FontWeight.w700))),
        ),
      );
    })),
    const Gap(32),
    const Text('Nombres de los días', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
    const Gap(12),
    ...List.generate(_days.length, (i) {
      final ctrl = TextEditingController(text: _days[i].name);
      return Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(
        controller: ctrl,
        style: const TextStyle(color: AppColors.textPrimary),
        onChanged: (v) => _days[i] = _DayData(name: v, exercises: _days[i].exercises),
        decoration: InputDecoration(
          labelText: 'Día ${i + 1}', labelStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 18),
          filled: true, fillColor: AppColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        ),
      ));
    }),
  ]);

  Widget _buildStep3() {
    if (_days.isEmpty) return const Center(child: Text('Sin días', style: TextStyle(color: AppColors.textMuted)));
    return DefaultTabController(
      length: _days.length,
      child: Column(children: [
        const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Agrega ejercicios a cada día', style: TextStyle(color: AppColors.textSecondary, fontSize: 14))),
        const Gap(8),
        TabBar(
          isScrollable: true, labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted, indicatorColor: AppColors.primary,
          tabs: _days.map((d) => Tab(text: d.name)).toList(),
        ),
        Expanded(child: TabBarView(
          children: List.generate(_days.length, (i) => _DayExerciseEditor(
            day: _days[i],
            onChanged: (updated) => setState(() => _days[i] = updated),
          )),
        )),
      ]),
    );
  }

  void _syncDays() {
    while (_days.length < _daysPerWeek) _days.add(_DayData(name: 'Día ${_days.length + 1}', exercises: []));
    while (_days.length > _daysPerWeek) _days.removeLast();
  }

  void _goNext() {
    if (_step == 0 && _nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un nombre para la rutina')));
      return;
    }
    if (_step == 1) _syncDays();
    setState(() => _step++);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final plan = WorkoutPlan(
      id: widget.existingPlan?.id ?? 'plan_${DateTime.now().millisecondsSinceEpoch}',
      gymId: 'g1', createdBy: 'u1',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      goal: _goal, durationWeeks: _durationWeeks,
      days: _days.asMap().entries.map((e) => WorkoutDay(
        id: 'day_${e.key}',
        name: e.value.name,
        exercises: e.value.exercises.map((ex) => WorkoutExercise(
          exercise: ex.exercise,
          sets: List.generate(ex.sets, (si) => ExerciseSet(
            setNumber: si + 1, targetReps: ex.reps, targetWeight: ex.weight,
          )),
        )).toList(),
      )).toList(),
      createdAt: DateTime.now(),
    );

    if (widget.existingPlan != null) {
      ref.read(workoutProvider.notifier).updatePlan(plan);
    } else {
      ref.read(workoutProvider.notifier).createPlan(plan);
    }

    if (mounted) { setState(() => _isSaving = false); Navigator.pop(context); }
  }

  String _goalEmoji(WorkoutGoal g) => switch(g) {
    WorkoutGoal.muscleMass => '💪', WorkoutGoal.weightLoss => '🔥', WorkoutGoal.endurance => '🏃',
    WorkoutGoal.strength => '🏋️', WorkoutGoal.generalFitness => '⚡', WorkoutGoal.sportsPerformance => '🎯',
    _ => '🎯',
  };

  String _goalLabel(WorkoutGoal g) => switch(g) {
    WorkoutGoal.muscleMass => 'Músculo', WorkoutGoal.weightLoss => 'Pérdida de grasa', WorkoutGoal.endurance => 'Resistencia',
    WorkoutGoal.strength => 'Fuerza', WorkoutGoal.generalFitness => 'Fitness General', WorkoutGoal.sportsPerformance => 'Rendimiento',
    _ => g.name,
  };
}

// ---------------------------------------------------------------------------
// Day exercise editor
// ---------------------------------------------------------------------------

class _DayExerciseEditor extends StatelessWidget {
  final _DayData day; final void Function(_DayData) onChanged;
  const _DayExerciseEditor({required this.day, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: day.exercises.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.fitness_center, color: AppColors.textMuted, size: 48),
            const Gap(12),
            const Text('Sin ejercicios', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const Gap(8),
            const Text('Toca + para agregar', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ]))
        : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: day.exercises.length,
            separatorBuilder: (_, __) => const Gap(6),
            itemBuilder: (_, i) => _ExCard(
              entry: day.exercises[i],
              onDelete: () { final list = [...day.exercises]..removeAt(i); onChanged(_DayData(name: day.name, exercises: list)); },
              onEdit: (updated) { final list = [...day.exercises]..[i] = updated; onChanged(_DayData(name: day.name, exercises: list)); },
            ),
          )),
    Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(
      icon: const Icon(Icons.add, color: AppColors.primary),
      label: const Text('Agregar ejercicio', style: TextStyle(color: AppColors.primary)),
      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      onPressed: () => _pickExercise(context),
    ))),
  ]);

  void _pickExercise(BuildContext context) {
    String query = '';
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(expand: false, initialChildSize: 0.8, maxChildSize: 0.95,
        builder: (_, ctrl) => StatefulBuilder(builder: (_, ss) {
          final all = ExercisesData.all;
          final filtered = all.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();
          return Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              const Text('Selecciona ejercicio', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
              const Gap(12),
              TextField(
                onChanged: (v) => ss(() => query = v),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar...', hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
            ])),
            Expanded(child: ListView.separated(
              controller: ctrl, padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
              itemBuilder: (_, i) {
                final ex = filtered[i];
                return ListTile(
                  leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 18)),
                  title: Text(ex.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  subtitle: Text(ex.muscleGroup.name, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onChanged(_DayData(name: day.name, exercises: [...day.exercises, _ExData(exercise: ex, sets: 3, reps: 12, weight: null)]));
                  },
                );
              },
            )),
          ]);
        }),
      ),
    );
  }
}

class _ExCard extends StatelessWidget {
  final _ExData entry; final VoidCallback onDelete; final void Function(_ExData) onEdit;
  const _ExCard({required this.entry, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      const Icon(Icons.drag_handle, color: AppColors.textMuted, size: 20),
      const Gap(10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(entry.exercise.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        const Gap(4),
        Row(children: [
          _Pill('${entry.sets} series', AppColors.primary),
          const Gap(6),
          _Pill('${entry.reps} reps', AppColors.success),
          if (entry.weight != null) ...[const Gap(6), _Pill('${entry.weight!.toStringAsFixed(0)}kg', AppColors.warning)],
        ]),
      ])),
      PopupMenuButton<String>(
        color: AppColors.card,
        icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 18),
        onSelected: (v) {
          if (v == 'edit') _editDialog(context);
          if (v == 'delete') onDelete();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16, color: AppColors.accent), Gap(8), Text('Editar', style: TextStyle(color: AppColors.textPrimary))])),
          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: AppColors.error), Gap(8), Text('Eliminar', style: TextStyle(color: AppColors.error))])),
        ],
      ),
    ]),
  );

  void _editDialog(BuildContext context) {
    int sets = entry.sets, reps = entry.reps;
    double? weight = entry.weight;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (_, ss) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(entry.exercise.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          const Text('Series:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Gap(12),
          _Counter(value: sets, min: 1, max: 10, onChanged: (v) => ss(() => sets = v)),
        ]),
        const Gap(12),
        Row(children: [
          const Text('Reps:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Gap(12),
          _Counter(value: reps, min: 1, max: 50, onChanged: (v) => ss(() => reps = v)),
        ]),
        const Gap(12),
        Row(children: [
          const Text('Peso (kg):', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Gap(12),
          Expanded(child: TextField(
            controller: TextEditingController(text: weight?.toString() ?? ''),
            keyboardType: TextInputType.number, onChanged: (v) => weight = double.tryParse(v),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(hintText: 'Opcional', border: OutlineInputBorder(),
                hintStyle: TextStyle(color: AppColors.textMuted), isDense: true),
          )),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () { onEdit(_ExData(exercise: entry.exercise, sets: sets, reps: reps, weight: weight)); Navigator.pop(context); },
            child: const Text('Guardar')),
      ],
    )));
  }
}

// ---------------------------------------------------------------------------
// Shared widgets / helpers
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  final int step; final bool isSaving;
  final VoidCallback? onBack; final VoidCallback onNext;
  const _BottomBar({required this.step, required this.isSaving, required this.onBack, required this.onNext});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
    child: Row(children: [
      if (onBack != null) ...[
        OutlinedButton(onPressed: onBack,
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
            child: const Text('Atrás', style: TextStyle(color: AppColors.textSecondary))),
        const Gap(12),
      ],
      Expanded(child: ElevatedButton(
        onPressed: isSaving ? null : onNext,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: isSaving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(step < 2 ? 'Continuar' : 'Guardar Rutina', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
      )),
    ]),
  );
}

class _Counter extends StatelessWidget {
  final int value, min, max; final void Function(int) onChanged;
  const _Counter({required this.value, required this.min, required this.max, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(children: [
    IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.textMuted, size: 20), onPressed: value > min ? () => onChanged(value - 1) : null),
    Text('$value', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
    IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20), onPressed: value < max ? () => onChanged(value + 1) : null),
  ]);
}

class _Pill extends StatelessWidget {
  final String label; final Color color;
  const _Pill(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

class _DayData {
  final String name; final List<_ExData> exercises;
  _DayData({required this.name, required this.exercises});
}

class _ExData {
  final ExerciseModel exercise; final int sets, reps; final double? weight;
  _ExData({required this.exercise, required this.sets, required this.reps, this.weight});
}
