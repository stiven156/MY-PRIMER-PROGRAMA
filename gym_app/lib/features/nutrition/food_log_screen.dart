import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/nutrition_provider.dart';
import 'package:gym_app/core/models/nutrition_model.dart';
import 'package:gym_app/core/data/food_database.dart';
import 'package:uuid/uuid.dart';

class FoodLogScreen extends ConsumerStatefulWidget {
  const FoodLogScreen({super.key});
  @override
  ConsumerState<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends ConsumerState<FoodLogScreen> {
  final _searchCtrl = TextEditingController();
  MealType _selectedMeal = MealType.lunch;
  String _query = '';
  String? _selectedCategory;

  static const _categories = [
    'Todos', 'Proteínas', 'Carbohidratos', 'Verduras', 'Frutas', 'Lácteos', 'Grasas', 'Suplementos'
  ];

  List<FoodItem> get _results {
    if (_query.length < 2) return FoodDatabase.recent;
    return FoodDatabase.search(_query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Registrar Alimento', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal type selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: MealType.values.map((t) {
                  final labels = {
                    MealType.breakfast: 'Desayuno', MealType.midMorning: 'Media mañana',
                    MealType.lunch: 'Almuerzo', MealType.afternoon: 'Merienda',
                    MealType.dinner: 'Cena', MealType.postWorkout: 'Post-Entreno',
                    MealType.preWorkout: 'Pre-Entreno',
                  };
                  final sel = _selectedMeal == t;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMeal = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(labels[t]!, style: TextStyle(
                          color: sel ? Colors.white : AppColors.textSecondary,
                          fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Gap(12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Buscar alimento...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              ),
            ),
          ),
          const Gap(8),

          // Category chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((c) {
                final sel = _selectedCategory == c || (_selectedCategory == null && c == 'Todos');
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c == 'Todos' ? null : c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.secondary.withOpacity(0.2) : AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: sel ? AppColors.secondary : AppColors.border),
                    ),
                    child: Text(c, style: TextStyle(
                        color: sel ? AppColors.secondary : AppColors.textSecondary,
                        fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
          ),
          const Gap(8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_query.length < 2 ? 'Recientes' : '${_results.length} resultados',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          const Gap(8),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Gap(6),
              itemBuilder: (context, i) {
                final food = _results[i];
                return _FoodCard(food: food, mealType: _selectedMeal,
                  onAdd: (qty) {
                    final entry = MealEntry(
                      id: const Uuid().v4(),
                      foodItemId: food.id,
                      foodItem: food,
                      quantity: qty,
                      mealType: _selectedMeal,
                      timestamp: DateTime.now(),
                    );
                    ref.read(nutritionProvider.notifier).addMealEntry(entry);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${food.name} añadido ✓')),
                    );
                    Navigator.pop(context);
                  },
                ).animate(delay: (i * 20).ms).fadeIn();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodItem food; final MealType mealType; final void Function(double qty) onAdd;
  const _FoodCard({required this.food, required this.mealType, required this.onAdd});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _showQtyPicker(context),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(width: 42, height: 42,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Center(child: Text('🥗', style: TextStyle(fontSize: 20)))),
        const Gap(12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(food.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          if (food.brand != null)
            Text(food.brand!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const Gap(2),
          Row(children: [
            _MacroChip('${food.calories.toStringAsFixed(0)} kcal', AppColors.primary),
            const Gap(4),
            _MacroChip('P ${food.protein.toStringAsFixed(0)}g', AppColors.success),
            const Gap(4),
            _MacroChip('C ${food.carbs.toStringAsFixed(0)}g', AppColors.accent),
          ]),
        ])),
        IconButton(
          onPressed: () => onAdd(100),
          icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
        ),
      ]),
    ),
  );

  void _showQtyPicker(BuildContext context) {
    double qty = 100;
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(food.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
            const Gap(16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(icon: const Icon(Icons.remove_circle, color: AppColors.primary, size: 32),
                  onPressed: () => ss(() => qty = (qty - 25).clamp(1, 2000))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('${qty.toStringAsFixed(0)} g',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 28))),
              IconButton(icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 32),
                  onPressed: () => ss(() => qty = (qty + 25).clamp(1, 2000))),
            ]),
            const Gap(8),
            Text('${(food.calories * qty / 100).toStringAsFixed(0)} kcal · P:${(food.protein * qty / 100).toStringAsFixed(0)}g · C:${(food.carbs * qty / 100).toStringAsFixed(0)}g · G:${(food.fat * qty / 100).toStringAsFixed(0)}g',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const Gap(20),
            ElevatedButton(onPressed: () { Navigator.pop(ctx); onAdd(qty); },
                child: const Text('Añadir')),
          ]),
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label; final Color color;
  const _MacroChip(this.label, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );
}
