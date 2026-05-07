import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/workout_provider.dart';
import 'package:gym_app/core/models/workout_model.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _timer;
  int _elapsed = 0;
  int? _restCountdown;
  Timer? _restTimer;
  bool _showRest = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  String get _elapsedFormatted {
    final h = _elapsed ~/ 3600;
    final m = (_elapsed % 3600) ~/ 60;
    final s = _elapsed % 60;
    return h > 0
        ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() { _restCountdown = seconds; _showRest = true; });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_restCountdown! > 0) {
          _restCountdown = _restCountdown! - 1;
        } else {
          _showRest = false;
          t.cancel();
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() { _showRest = false; _restCountdown = null; });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutProvider);
    final session = state.activeSession;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: _confirmCancel,
                ),
                title: Text(_elapsedFormatted,
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        fontFamily: 'monospace')),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: _finishWorkout,
                    child: const Text('Terminar',
                        style: TextStyle(
                            color: AppColors.success, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),

              // Volume Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: 'Series', value: session != null
                          ? '${session.exercises.fold(0, (s, e) => s + e.sets.where((s) => s.completed).length)}'
                          : '0'),
                      _StatItem(label: 'Volumen', value: session != null
                          ? '${session.totalVolume.toStringAsFixed(0)} kg'
                          : '0 kg'),
                      _StatItem(label: 'Ejercicios', value: session != null
                          ? '${session.exercises.length}'
                          : '0'),
                    ],
                  ),
                ),
              ),

              if (session == null)
                SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fitness_center, color: AppColors.textMuted, size: 64),
                      const Gap(16),
                      const Text('No hay sesión activa',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                      const Gap(8),
                      const Text('Ve a Mis Rutinas para iniciar',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ExerciseSection(
                      exercise: session.exercises[i],
                      index: i,
                      onSetComplete: (setIdx, reps, weight) {
                        HapticFeedback.lightImpact();
                        ref.read(workoutProvider.notifier)
                            .completeSet(i, setIdx);
                        _startRestTimer(
                            session.exercises[i].restSeconds ?? 60);
                      },
                    ).animate(delay: (i * 100).ms).fadeIn().slideY(begin: 0.1),
                    childCount: session.exercises.length,
                  ),
                ),

              const SliverToBoxAdapter(child: Gap(80)),
            ],
          ),

          // Rest timer overlay
          if (_showRest && _restCountdown != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _RestTimerCard(
                countdown: _restCountdown!,
                onSkip: _skipRest,
                onAdd15: () => setState(() => _restCountdown = _restCountdown! + 15),
              ).animate().slideY(begin: 1).fadeIn(),
            ),
        ],
      ),
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('¿Cancelar entrenamiento?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Perderás el progreso de esta sesión.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Continuar')),
          TextButton(
            onPressed: () {
              ref.read(workoutProvider.notifier).cancelSession();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _finishWorkout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FinishWorkoutSheet(
        elapsed: _elapsed,
        onSave: (notes) {
          ref.read(workoutProvider.notifier).finishSession();
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Entrenamiento guardado! 💪')),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label; final String value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}

class _ExerciseSection extends StatefulWidget {
  final WorkoutExercise exercise;
  final int index;
  final void Function(int setIdx, int reps, double weight) onSetComplete;
  const _ExerciseSection({required this.exercise, required this.index, required this.onSetComplete});

  @override
  State<_ExerciseSection> createState() => _ExerciseSectionState();
}

class _ExerciseSectionState extends State<_ExerciseSection> {
  final _weightControllers = <TextEditingController>[];
  final _repsControllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    for (final s in widget.exercise.sets) {
      _weightControllers.add(TextEditingController(
          text: (s.targetWeight ?? 0).toStringAsFixed(1)));
      _repsControllers.add(TextEditingController(
          text: (s.targetReps ?? 10).toString()));
    }
  }

  @override
  void dispose() {
    for (final c in _weightControllers) c.dispose();
    for (final c in _repsControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('${widget.index + 1}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16))),
                ),
                const Gap(12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ex.exercise.name, style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(ex.exercise.primaryMuscle.name,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ])),
              ],
            ),
          ),
          // Sets table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: const [
              SizedBox(width: 32, child: Text('Set', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
              Gap(8),
              Expanded(child: Text('kg', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
              Gap(8),
              Expanded(child: Text('Reps', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
              Gap(8),
              SizedBox(width: 44, child: Center(child: Text('✓', style: TextStyle(color: AppColors.textMuted, fontSize: 14)))),
            ]),
          ),
          const Gap(8),
          ...ex.sets.asMap().entries.map((entry) {
            final idx = entry.key;
            final set = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: set.completed ? AppColors.success.withOpacity(0.05) : null,
              child: Row(children: [
                SizedBox(width: 32,
                    child: Text('${idx + 1}', style: TextStyle(
                        color: set.completed ? AppColors.success : AppColors.textSecondary,
                        fontWeight: FontWeight.w600))),
                const Gap(8),
                Expanded(child: TextField(
                  controller: _weightControllers[idx],
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true, fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    isDense: true,
                  ),
                )),
                const Gap(8),
                Expanded(child: TextField(
                  controller: _repsControllers[idx],
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true, fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    isDense: true,
                  ),
                )),
                const Gap(8),
                SizedBox(
                  width: 44,
                  child: GestureDetector(
                    onTap: () => widget.onSetComplete(
                        idx,
                        int.tryParse(_repsControllers[idx].text) ?? 10,
                        double.tryParse(_weightControllers[idx].text) ?? 0),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: set.completed ? AppColors.success : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.check,
                          color: set.completed ? Colors.white : AppColors.textMuted,
                          size: 20),
                    ),
                  ),
                ),
              ]),
            );
          }),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Añadir serie', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestTimerCard extends StatelessWidget {
  final int countdown; final VoidCallback onSkip; final VoidCallback onAdd15;
  const _RestTimerCard({required this.countdown, required this.onSkip, required this.onAdd15});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.cardElevated,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.accent.withOpacity(0.4)),
    ),
    child: Row(children: [
      SizedBox(width: 60, height: 60,
        child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(
            value: countdown / 60,
            color: AppColors.accent,
            backgroundColor: AppColors.inputFill,
            strokeWidth: 4,
          ),
          Text('$countdown', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
      ),
      const Gap(16),
      const Expanded(child: Text('Descansando...', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16))),
      TextButton(onPressed: onAdd15, child: const Text('+15s', style: TextStyle(color: AppColors.warning))),
      TextButton(onPressed: onSkip, child: const Text('Saltar', style: TextStyle(color: AppColors.error))),
    ]),
  );
}

class _FinishWorkoutSheet extends StatefulWidget {
  final int elapsed; final void Function(String notes) onSave;
  const _FinishWorkoutSheet({required this.elapsed, required this.onSave});
  @override
  State<_FinishWorkoutSheet> createState() => _FinishWorkoutSheetState();
}

class _FinishWorkoutSheetState extends State<_FinishWorkoutSheet> {
  final _notesCtrl = TextEditingController();
  double _rpe = 7;

  String get _formatted {
    final m = widget.elapsed ~/ 60; final s = widget.elapsed % 60;
    return '${m}min ${s}s';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('¡Entrenamiento Completo! 🎉', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
        const Gap(8),
        Text('Duración: $_formatted', style: const TextStyle(color: AppColors.success, fontSize: 16, fontWeight: FontWeight.w600)),
        const Gap(20),
        const Text('Esfuerzo percibido (RPE)', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Slider(value: _rpe, min: 1, max: 10, divisions: 9,
            label: _rpe.toStringAsFixed(0),
            onChanged: (v) => setState(() => _rpe = v)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('1 - Fácil', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const Text('10 - Máximo', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ]),
        const Gap(16),
        TextField(
          controller: _notesCtrl, maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Notas (opcional)...'),
        ),
        const Gap(20),
        ElevatedButton(
          onPressed: () => widget.onSave(_notesCtrl.text),
          child: const Text('Guardar Entrenamiento 💪'),
        ),
      ]),
    ),
  );
}
