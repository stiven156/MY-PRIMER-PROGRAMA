import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/models/exercise_model.dart';
import 'package:gym_app/core/data/exercises_data.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  final _searchCtrl = TextEditingController();
  MuscleGroup? _selectedMuscle;
  ExerciseDifficulty? _selectedDiff;
  String _query = '';

  List<ExerciseModel> get _filtered => ExercisesData.all.where((e) {
        final matchQ = _query.isEmpty || e.name.toLowerCase().contains(_query.toLowerCase());
        final matchM = _selectedMuscle == null || e.primaryMuscle == _selectedMuscle;
        final matchD = _selectedDiff == null || e.difficulty == _selectedDiff;
        return matchQ && matchM && matchD;
      }).toList();

  Color _muscleColor(MuscleGroup m) {
    switch (m) {
      case MuscleGroup.chest: return AppColors.chest;
      case MuscleGroup.back: return AppColors.back;
      case MuscleGroup.shoulders: return AppColors.shoulders;
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.forearms: return AppColors.arms;
      case MuscleGroup.core: return AppColors.core;
      default: return AppColors.legs;
    }
  }

  String _muscleLabel(MuscleGroup m) {
    const map = {
      MuscleGroup.chest: 'Pecho', MuscleGroup.back: 'Espalda',
      MuscleGroup.shoulders: 'Hombros', MuscleGroup.biceps: 'Bíceps',
      MuscleGroup.triceps: 'Tríceps', MuscleGroup.forearms: 'Antebrazos',
      MuscleGroup.core: 'Core', MuscleGroup.quadriceps: 'Cuádriceps',
      MuscleGroup.hamstrings: 'Femorales', MuscleGroup.glutes: 'Glúteos',
      MuscleGroup.calves: 'Pantorrillas', MuscleGroup.fullBody: 'Cuerpo Completo',
      MuscleGroup.cardio: 'Cardio',
    };
    return map[m] ?? m.name;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Ejercicios', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar ejercicio...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); })
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _Chip(label: 'Todos', selected: _selectedMuscle == null,
                    color: AppColors.primary,
                    onTap: () => setState(() => _selectedMuscle = null)),
                ...MuscleGroup.values.map((m) => _Chip(
                    label: _muscleLabel(m), selected: _selectedMuscle == m,
                    color: _muscleColor(m),
                    onTap: () => setState(() => _selectedMuscle = _selectedMuscle == m ? null : m))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Text('${filtered.length} ejercicios',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, i) {
                final ex = filtered[i];
                return _ExCard(ex: ex, color: _muscleColor(ex.primaryMuscle))
                    .animate(delay: (i * 25).ms).fadeIn();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final bool selected; final Color color; final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.2) : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? color : AppColors.border),
      ),
      child: Text(label, style: TextStyle(color: selected ? color : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400, fontSize: 13)),
    ),
  );
}

class _ExCard extends StatelessWidget {
  final ExerciseModel ex; final Color color;
  const _ExCard({required this.ex, required this.color});

  String get _diff => switch(ex.difficulty) {
    ExerciseDifficulty.beginner => 'Principiante',
    ExerciseDifficulty.intermediate => 'Intermedio',
    ExerciseDifficulty.advanced => 'Avanzado',
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65, maxChildSize: 0.92, minChildSize: 0.4, expand: false,
        builder: (_, ctrl) => ListView(controller: ctrl, padding: const EdgeInsets.all(24), children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const Gap(16),
          Text(ex.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
          const Gap(12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _Tag(ex.primaryMuscle.name, color),
            _Tag(ex.equipment.name, AppColors.accent),
            _Tag(_diff, AppColors.warning),
          ]),
          const Gap(20),
          const Text('Instrucciones', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          const Gap(8),
          Text(ex.instructions, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
          if (ex.tips.isNotEmpty) ...[
            const Gap(16),
            const Text('💡 Tips', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 16)),
            const Gap(8),
            ...ex.tips.map((t) => Padding(padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('• ', style: TextStyle(color: AppColors.warning)),
                Expanded(child: Text(t, style: const TextStyle(color: AppColors.textSecondary))),
              ]))),
          ],
          const Gap(24),
          ElevatedButton.icon(onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add), label: const Text('Añadir al Entrenamiento')),
        ]),
      ),
    ),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.fitness_center, color: color, size: 20)),
        const Gap(12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ex.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
          const Gap(4),
          Row(children: [
            _SmallTag(_diff, AppColors.warning),
            const Gap(6),
            _SmallTag(ex.equipment.name, AppColors.textMuted),
          ]),
        ])),
        const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ]),
    ),
  );
}

class _Tag extends StatelessWidget {
  final String label; final Color color;
  const _Tag(this.label, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

class _SmallTag extends StatelessWidget {
  final String label; final Color color;
  const _SmallTag(this.label, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
  );
}
