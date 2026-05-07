import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/nutrition_provider.dart';
import 'package:gym_app/core/models/nutrition_model.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});
  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);
    final log = state.todayLog;
    final goals = state.goals;

    final totalCals = log?.totalCalories ?? 0.0;
    final totalProtein = log?.totalProtein ?? 0.0;
    final totalCarbs = log?.totalCarbs ?? 0.0;
    final totalFat = log?.totalFat ?? 0.0;
    final water = log?.waterIntake ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: const Text('Nutrición', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
            actions: [
              IconButton(icon: const Icon(Icons.tune, color: AppColors.textSecondary),
                  onPressed: () => _showGoalsDialog(context, goals)),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Date selector
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 7,
                    itemBuilder: (_, i) {
                      final d = DateTime.now().subtract(Duration(days: 6 - i));
                      final isSelected = d.day == _selectedDate.day && d.month == _selectedDate.month;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDate = d),
                        child: Container(
                          width: 50, margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(['L','M','X','J','V','S','D'][d.weekday - 1],
                                style: TextStyle(color: isSelected ? Colors.white : AppColors.textMuted, fontSize: 11)),
                            const Gap(2),
                            Text('${d.day}', style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w700, fontSize: 16)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                const Gap(16),

                // Calories card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _CaloriesCard(
                    consumed: totalCals, goal: goals.calories,
                    protein: totalProtein, proteinGoal: goals.protein,
                    carbs: totalCarbs, carbsGoal: goals.carbs,
                    fat: totalFat, fatGoal: goals.fat,
                  ).animate().fadeIn().slideY(begin: 0.1),
                ),
                const Gap(16),

                // Water tracker
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _WaterCard(
                    current: water, goal: goals.water,
                    onAdd: () => ref.read(nutritionProvider.notifier).updateWaterIntake(250),
                  ).animate().fadeIn().slideY(begin: 0.1, delay: 100.ms),
                ),
                const Gap(16),

                // Meals
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Comidas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
                    TextButton.icon(
                      onPressed: () => context.push('/nutrition/log'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Registrar'),
                    ),
                  ]),
                ),

                ...MealType.values.map((type) {
                  final entries = log?.meals.where((m) => m.mealType == type).toList() ?? [];
                  return _MealSection(type: type, entries: entries,
                      onAdd: () => context.push('/nutrition/log', extra: type));
                }),
                const Gap(80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalsDialog(BuildContext context, NutritionGoals goals) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _GoalsSheet(goals: goals,
          onSave: (ng) => ref.read(nutritionProvider.notifier).updateGoals(ng)),
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  final double consumed, goal, protein, proteinGoal, carbs, carbsGoal, fat, fatGoal;
  const _CaloriesCard({required this.consumed, required this.goal, required this.protein,
      required this.proteinGoal, required this.carbs, required this.carbsGoal,
      required this.fat, required this.fatGoal});

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed;
    final progress = (consumed / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Row(children: [
            CircularPercentIndicator(
              radius: 55, lineWidth: 10, percent: progress,
              backgroundColor: AppColors.inputFill,
              linearGradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF1060)]),
              center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(consumed.toStringAsFixed(0), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
                const Text('kcal', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ]),
            ),
            const Gap(16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(remaining > 0 ? '${remaining.toStringAsFixed(0)} kcal restantes' : '¡Objetivo alcanzado! ✓',
                  style: TextStyle(color: remaining > 0 ? AppColors.textPrimary : AppColors.success,
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const Gap(4),
              Text('Meta: ${goal.toStringAsFixed(0)} kcal', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const Gap(12),
              Row(children: [
                _MacroDot(color: AppColors.primary, label: 'P ${protein.toStringAsFixed(0)}g'),
                const Gap(8),
                _MacroDot(color: AppColors.accent, label: 'C ${carbs.toStringAsFixed(0)}g'),
                const Gap(8),
                _MacroDot(color: AppColors.secondary, label: 'G ${fat.toStringAsFixed(0)}g'),
              ]),
            ])),
          ]),
          const Gap(16),
          _MacroBar(label: 'Proteína', current: protein, goal: proteinGoal, color: AppColors.primary, unit: 'g'),
          const Gap(8),
          _MacroBar(label: 'Carbos', current: carbs, goal: carbsGoal, color: AppColors.accent, unit: 'g'),
          const Gap(8),
          _MacroBar(label: 'Grasas', current: fat, goal: fatGoal, color: AppColors.secondary, unit: 'g'),
        ],
      ),
    );
  }
}

class _MacroDot extends StatelessWidget {
  final Color color; final String label;
  const _MacroDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const Gap(4),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
  ]);
}

class _MacroBar extends StatelessWidget {
  final String label, unit; final double current, goal; final Color color;
  const _MacroBar({required this.label, required this.current, required this.goal, required this.color, required this.unit});

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text('${current.toStringAsFixed(0)}/${goal.toStringAsFixed(0)}$unit',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
      const Gap(4),
      LinearProgressIndicator(value: progress, backgroundColor: AppColors.inputFill,
          valueColor: AlwaysStoppedAnimation(color), minHeight: 6,
          borderRadius: BorderRadius.circular(3)),
    ]);
  }
}

class _WaterCard extends StatelessWidget {
  final double current, goal; final VoidCallback onAdd;
  const _WaterCard({required this.current, required this.goal, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final glasses = (current / 250).floor();
    final totalGlasses = (goal / 250).floor();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Text('💧', style: TextStyle(fontSize: 20)),
            Gap(8),
            Text('Hidratación', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
          Text('${(current / 1000).toStringAsFixed(1)}L / ${(goal / 1000).toStringAsFixed(1)}L',
              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
        ]),
        const Gap(12),
        Wrap(spacing: 8, runSpacing: 8, children: List.generate(totalGlasses.clamp(1, 10), (i) => Text(
          i < glasses ? '🥤' : '🫙',
          style: const TextStyle(fontSize: 24),
        ))),
        const Gap(12),
        Row(children: [
          Expanded(child: LinearProgressIndicator(
            value: (current / goal).clamp(0.0, 1.0),
            backgroundColor: AppColors.inputFill,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            minHeight: 8, borderRadius: BorderRadius.circular(4),
          )),
          const Gap(12),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent.withOpacity(0.2),
              foregroundColor: AppColors.accent,
              minimumSize: const Size(60, 36), padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('+250ml'),
          ),
        ]),
      ]),
    );
  }
}

class _MealSection extends StatelessWidget {
  final MealType type; final List<MealEntry> entries; final VoidCallback onAdd;
  const _MealSection({required this.type, required this.entries, required this.onAdd});

  String get _name => switch(type) {
    MealType.breakfast => '🌅 Desayuno',
    MealType.midMorning => '☕ Media mañana',
    MealType.lunch => '🍽️ Almuerzo',
    MealType.afternoon => '🍎 Merienda',
    MealType.dinner => '🌙 Cena',
    MealType.postWorkout => '💪 Post-Entreno',
    MealType.preWorkout => '⚡ Pre-Entreno',
  };

  double get _totalCals => entries.fold(0, (s, e) => s + (e.foodItem.calories * e.quantity / 100));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: null,
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            Text(entries.isEmpty ? '' : '${_totalCals.toStringAsFixed(0)} kcal',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
          trailing: IconButton(icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 22), onPressed: onAdd),
          children: [
            if (entries.isEmpty)
              Padding(padding: const EdgeInsets.only(bottom: 12),
                  child: TextButton.icon(onPressed: onAdd,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text('Añadir ${_name.split(' ').last}'))),
            ...entries.map((e) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              title: Text(e.foodItem.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              subtitle: Text('${e.quantity.toStringAsFixed(0)}g · ${(e.foodItem.calories * e.quantity / 100).toStringAsFixed(0)} kcal',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
                onPressed: () => context.read(nutritionProvider.notifier).removeMealEntry(e.id),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  T read<T>(T provider) => (this as dynamic).read(provider);
}

class _GoalsSheet extends StatefulWidget {
  final NutritionGoals goals; final void Function(NutritionGoals) onSave;
  const _GoalsSheet({required this.goals, required this.onSave});
  @override
  State<_GoalsSheet> createState() => _GoalsSheetState();
}

class _GoalsSheetState extends State<_GoalsSheet> {
  late double _cal, _protein, _carbs, _fat, _water;
  @override
  void initState() {
    super.initState();
    _cal = widget.goals.calories; _protein = widget.goals.protein;
    _carbs = widget.goals.carbs; _fat = widget.goals.fat; _water = widget.goals.water;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Objetivos Nutricionales', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
      const Gap(20),
      _GoalSlider(label: 'Calorías', value: _cal, min: 1200, max: 5000, unit: 'kcal', onChanged: (v) => setState(() => _cal = v)),
      _GoalSlider(label: 'Proteína', value: _protein, min: 50, max: 300, unit: 'g', onChanged: (v) => setState(() => _protein = v)),
      _GoalSlider(label: 'Carbohidratos', value: _carbs, min: 50, max: 600, unit: 'g', onChanged: (v) => setState(() => _carbs = v)),
      _GoalSlider(label: 'Grasas', value: _fat, min: 20, max: 200, unit: 'g', onChanged: (v) => setState(() => _fat = v)),
      _GoalSlider(label: 'Agua', value: _water, min: 1000, max: 5000, unit: 'ml', onChanged: (v) => setState(() => _water = v)),
      const Gap(16),
      ElevatedButton(
        onPressed: () { widget.onSave(NutritionGoals(calories: _cal, protein: _protein, carbs: _carbs, fat: _fat, water: _water)); Navigator.pop(context); },
        child: const Text('Guardar Objetivos'),
      ),
    ])),
  );
}

class _GoalSlider extends StatelessWidget {
  final String label, unit; final double value, min, max; final void Function(double) onChanged;
  const _GoalSlider({required this.label, required this.value, required this.min, required this.max, required this.unit, required this.onChanged});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Text('${value.toStringAsFixed(0)} $unit', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
    ]),
    Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
  ]);
}
