import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/core/models/nutrition_model.dart';
import 'package:gym_app/core/data/food_database.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class NutritionState {
  final NutritionLog? todayLog;
  final List<NutritionLog> weekLogs;
  final NutritionGoals goals;
  final List<FoodItem> searchResults;
  final bool isLoading;
  final String? error;

  const NutritionState({
    this.todayLog,
    this.weekLogs = const [],
    this.goals = const NutritionGoals(),
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  NutritionState copyWith({
    NutritionLog? todayLog,
    List<NutritionLog>? weekLogs,
    NutritionGoals? goals,
    List<FoodItem>? searchResults,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearTodayLog = false,
  }) {
    return NutritionState(
      todayLog: clearTodayLog ? null : (todayLog ?? this.todayLog),
      weekLogs: weekLogs ?? this.weekLogs,
      goals: goals ?? this.goals,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper — build a mock today log for demo
// ---------------------------------------------------------------------------

NutritionLog _buildTodayLog(String memberId) {
  final today = DateTime.now();
  final todayId =
      'log_${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}_$memberId';

  // Grab some foods from the database
  final chicken = FoodDatabase.proteins
      .firstWhere((f) => f.name.contains('Pollo'), orElse: () => FoodDatabase.proteins.first);
  final rice = FoodDatabase.carbs
      .firstWhere((f) => f.name.contains('Arroz'), orElse: () => FoodDatabase.carbs.first);
  final oats = FoodDatabase.carbs
      .firstWhere((f) => f.name.contains('Avena'), orElse: () => FoodDatabase.carbs.first);
  final eggs = FoodDatabase.proteins
      .firstWhere((f) => f.name.contains('Huevo'), orElse: () => FoodDatabase.proteins[1]);
  final banana = FoodDatabase.fruits
      .firstWhere((f) => f.name.contains('Banano') || f.name.contains('Plátano'),
          orElse: () => FoodDatabase.fruits.first);
  final yogurt = FoodDatabase.dairy
      .firstWhere((f) => f.name.contains('Yogur'), orElse: () => FoodDatabase.dairy.first);

  return NutritionLog(
    id: todayId,
    memberId: memberId,
    date: today,
    waterIntakeMl: 1600,
    entries: [
      MealEntry(
        id: 'entry_001',
        mealType: 'Desayuno',
        foodItem: oats,
        quantity: 80,
        loggedAt: today.copyWith(hour: 7, minute: 30),
      ),
      MealEntry(
        id: 'entry_002',
        mealType: 'Desayuno',
        foodItem: eggs,
        quantity: 200,
        loggedAt: today.copyWith(hour: 7, minute: 35),
      ),
      MealEntry(
        id: 'entry_003',
        mealType: 'Merienda',
        foodItem: banana,
        quantity: 120,
        loggedAt: today.copyWith(hour: 10, minute: 0),
      ),
      MealEntry(
        id: 'entry_004',
        mealType: 'Almuerzo',
        foodItem: chicken,
        quantity: 200,
        loggedAt: today.copyWith(hour: 13, minute: 0),
      ),
      MealEntry(
        id: 'entry_005',
        mealType: 'Almuerzo',
        foodItem: rice,
        quantity: 150,
        loggedAt: today.copyWith(hour: 13, minute: 5),
      ),
      MealEntry(
        id: 'entry_006',
        mealType: 'Merienda',
        foodItem: yogurt,
        quantity: 150,
        loggedAt: today.copyWith(hour: 16, minute: 30),
      ),
    ],
  );
}

List<NutritionLog> _buildWeekLogs(String memberId) {
  final today = DateTime.now();
  return List.generate(7, (i) {
    final date = today.subtract(Duration(days: i + 1));
    final dateStr =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return NutritionLog(
      id: 'log_${dateStr}_$memberId',
      memberId: memberId,
      date: date,
      waterIntakeMl: 1500 + (i * 100).toDouble(),
      entries: [
        MealEntry(
          id: 'e_${dateStr}_1',
          mealType: 'Desayuno',
          foodItem: FoodDatabase.carbs.first,
          quantity: 80,
          loggedAt: date.copyWith(hour: 8),
        ),
        MealEntry(
          id: 'e_${dateStr}_2',
          mealType: 'Almuerzo',
          foodItem: FoodDatabase.proteins.first,
          quantity: 200,
          loggedAt: date.copyWith(hour: 13),
        ),
        MealEntry(
          id: 'e_${dateStr}_3',
          mealType: 'Cena',
          foodItem: FoodDatabase.proteins[2],
          quantity: 150,
          loggedAt: date.copyWith(hour: 20),
        ),
      ],
    );
  });
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier() : super(const NutritionState());

  /// Loads today's nutrition log for [memberId].
  Future<void> loadTodayLog(String memberId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isLoading: false,
      todayLog: _buildTodayLog(memberId),
      clearError: true,
    );
  }

  /// Appends a meal entry to today's log.
  Future<void> addMealEntry(MealEntry entry) async {
    final log = state.todayLog;
    if (log == null) return;
    final updated =
        log.copyWith(entries: [...log.entries, entry]);
    state = state.copyWith(todayLog: updated);
  }

  /// Removes a meal entry by id from today's log.
  Future<void> removeMealEntry(String entryId) async {
    final log = state.todayLog;
    if (log == null) return;
    final entries =
        log.entries.where((e) => e.id != entryId).toList();
    state = state.copyWith(todayLog: log.copyWith(entries: entries));
  }

  /// Updates the water intake (adds ml to today's total).
  void updateWaterIntake(double ml) {
    final log = state.todayLog;
    if (log == null) return;
    state = state.copyWith(
      todayLog: log.copyWith(waterIntakeMl: log.waterIntakeMl + ml),
    );
  }

  /// Searches the local food database by name.
  void searchFood(String query) {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }
    final results = FoodDatabase.search(query);
    state = state.copyWith(searchResults: results);
  }

  /// Replaces the current nutrition goals.
  void updateGoals(NutritionGoals goals) {
    state = state.copyWith(goals: goals);
  }

  /// Loads the past 7 days of nutrition logs.
  Future<void> loadWeekHistory(String memberId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isLoading: false,
      weekLogs: _buildWeekLogs(memberId),
      clearError: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>(
  (ref) => NutritionNotifier(),
);

/// Returns a map {calories, protein, carbs, fat} from today's log, or zeros.
final todayMacrosProvider = Provider<Map<String, double>>((ref) {
  final log = ref.watch(nutritionProvider).todayLog;
  if (log == null) {
    return {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0};
  }
  return {
    'calories': log.totalCalories,
    'protein': log.totalProtein,
    'carbs': log.totalCarbs,
    'fat': log.totalFat,
  };
});

/// Returns the fraction of the daily water goal consumed (0.0 – 1.0+).
final waterProgressProvider = Provider<double>((ref) {
  final state = ref.watch(nutritionProvider);
  final log = state.todayLog;
  if (log == null || state.goals.waterMl <= 0) return 0.0;
  return log.waterIntakeMl / state.goals.waterMl;
});
