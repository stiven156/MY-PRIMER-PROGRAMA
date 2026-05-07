import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum MealType {
  breakfast,
  midMorning,
  lunch,
  afternoon,
  dinner,
  postWorkout,
  preWorkout;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.midMorning:
        return 'Mid-Morning Snack';
      case MealType.lunch:
        return 'Lunch';
      case MealType.afternoon:
        return 'Afternoon Snack';
      case MealType.dinner:
        return 'Dinner';
      case MealType.postWorkout:
        return 'Post-Workout';
      case MealType.preWorkout:
        return 'Pre-Workout';
    }
  }

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MealType.lunch,
    );
  }
}

// ---------------------------------------------------------------------------
// FoodItem
// ---------------------------------------------------------------------------

@immutable
class FoodItem {
  final String id;
  final String name;
  final String? brand;

  /// Calories per 100 g (or per 100 ml for liquids).
  final double calories;

  /// Protein (g) per 100 g.
  final double protein;

  /// Carbohydrates (g) per 100 g.
  final double carbs;

  /// Fat (g) per 100 g.
  final double fat;

  /// Dietary fibre (g) per 100 g.
  final double fiber;

  /// Sugar (g) per 100 g.
  final double sugar;

  /// Sodium (mg) per 100 g.
  final double sodium;

  /// Unit used when displaying a "default serving" (e.g. "g", "ml", "pieza").
  final String servingUnit;

  /// Default serving size in [servingUnit] units.
  final double defaultServing;

  final String? imageUrl;

  final String category;

  const FoodItem({
    required this.id,
    required this.name,
    this.brand,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.servingUnit = 'g',
    this.defaultServing = 100,
    this.imageUrl,
    required this.category,
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns macros scaled to [quantity] (in the same unit as [servingUnit]).
  FoodItem scaledTo(double quantity) {
    final factor = quantity / 100.0; // all values are per 100 g/ml
    return FoodItem(
      id: id,
      name: name,
      brand: brand,
      calories: calories * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      fiber: fiber * factor,
      sugar: sugar * factor,
      sodium: sodium * factor,
      servingUnit: servingUnit,
      defaultServing: quantity,
      imageUrl: imageUrl,
      category: category,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'servingUnit': servingUnit,
      'defaultServing': defaultServing,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
      servingUnit: json['servingUnit'] as String? ?? 'g',
      defaultServing: (json['defaultServing'] as num?)?.toDouble() ?? 100,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? 'General',
    );
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? brand,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    String? servingUnit,
    double? defaultServing,
    String? imageUrl,
    String? category,
    bool clearBrand = false,
    bool clearImageUrl = false,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: clearBrand ? null : (brand ?? this.brand),
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      servingUnit: servingUnit ?? this.servingUnit,
      defaultServing: defaultServing ?? this.defaultServing,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FoodItem(id: $id, name: $name, cal: $calories/100g)';
}

// ---------------------------------------------------------------------------
// MealEntry
// ---------------------------------------------------------------------------

@immutable
class MealEntry {
  final String id;
  final String foodItemId;
  final FoodItem foodItem;

  /// Quantity consumed in [foodItem.servingUnit] units.
  final double quantity;

  final MealType mealType;
  final DateTime timestamp;

  const MealEntry({
    required this.id,
    required this.foodItemId,
    required this.foodItem,
    required this.quantity,
    required this.mealType,
    required this.timestamp,
  });

  // Macro helpers (scaled to consumed quantity)
  double get calories => foodItem.calories * (quantity / 100.0);
  double get protein => foodItem.protein * (quantity / 100.0);
  double get carbs => foodItem.carbs * (quantity / 100.0);
  double get fat => foodItem.fat * (quantity / 100.0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodItemId': foodItemId,
      'foodItem': foodItem.toJson(),
      'quantity': quantity,
      'mealType': mealType.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'] as String,
      foodItemId: json['foodItemId'] as String,
      foodItem: FoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      mealType: MealType.fromString(json['mealType'] as String? ?? 'lunch'),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  MealEntry copyWith({
    String? id,
    String? foodItemId,
    FoodItem? foodItem,
    double? quantity,
    MealType? mealType,
    DateTime? timestamp,
  }) {
    return MealEntry(
      id: id ?? this.id,
      foodItemId: foodItemId ?? this.foodItemId,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      mealType: mealType ?? this.mealType,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// NutritionGoals
// ---------------------------------------------------------------------------

@immutable
class NutritionGoals {
  /// Daily calorie target (kcal).
  final double calories;

  /// Daily protein target (g).
  final double protein;

  /// Daily carbohydrate target (g).
  final double carbs;

  /// Daily fat target (g).
  final double fat;

  /// Daily water intake target (ml).
  final double water;

  const NutritionGoals({
    this.calories = 2000,
    this.protein = 150,
    this.carbs = 250,
    this.fat = 65,
    this.water = 2500,
  });

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'water': water,
    };
  }

  factory NutritionGoals.fromJson(Map<String, dynamic> json) {
    return NutritionGoals(
      calories: (json['calories'] as num?)?.toDouble() ?? 2000,
      protein: (json['protein'] as num?)?.toDouble() ?? 150,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 250,
      fat: (json['fat'] as num?)?.toDouble() ?? 65,
      water: (json['water'] as num?)?.toDouble() ?? 2500,
    );
  }

  NutritionGoals copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? water,
  }) {
    return NutritionGoals(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      water: water ?? this.water,
    );
  }
}

// ---------------------------------------------------------------------------
// NutritionLog
// ---------------------------------------------------------------------------

@immutable
class NutritionLog {
  final String id;
  final String memberId;
  final DateTime date;
  final List<MealEntry> meals;

  /// Water consumed today in ml.
  final double waterIntake;

  final NutritionGoals goals;
  final String? notes;

  const NutritionLog({
    required this.id,
    required this.memberId,
    required this.date,
    this.meals = const [],
    this.waterIntake = 0,
    required this.goals,
    this.notes,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  double get totalCalories =>
      meals.fold(0.0, (sum, e) => sum + e.calories);

  double get totalProtein =>
      meals.fold(0.0, (sum, e) => sum + e.protein);

  double get totalCarbs =>
      meals.fold(0.0, (sum, e) => sum + e.carbs);

  double get totalFat =>
      meals.fold(0.0, (sum, e) => sum + e.fat);

  double get caloriesRemaining => goals.calories - totalCalories;

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'date': date.toIso8601String(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'waterIntake': waterIntake,
      'goals': goals.toJson(),
      'notes': notes,
    };
  }

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    return NutritionLog(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      date: DateTime.parse(json['date'] as String),
      meals: (json['meals'] as List<dynamic>?)
              ?.map((m) => MealEntry.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      waterIntake: (json['waterIntake'] as num?)?.toDouble() ?? 0,
      goals: json['goals'] != null
          ? NutritionGoals.fromJson(json['goals'] as Map<String, dynamic>)
          : const NutritionGoals(),
      notes: json['notes'] as String?,
    );
  }

  NutritionLog copyWith({
    String? id,
    String? memberId,
    DateTime? date,
    List<MealEntry>? meals,
    double? waterIntake,
    NutritionGoals? goals,
    String? notes,
    bool clearNotes = false,
  }) {
    return NutritionLog(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      waterIntake: waterIntake ?? this.waterIntake,
      goals: goals ?? this.goals,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionLog &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// MealPlanDay
// ---------------------------------------------------------------------------

@immutable
class MealPlanDay {
  final int dayNumber;

  /// Map from [MealType] to a list of recommended [FoodItem]s.
  final Map<MealType, List<FoodItem>> meals;

  final double totalCalories;
  final String? notes;

  const MealPlanDay({
    required this.dayNumber,
    this.meals = const {},
    this.totalCalories = 0,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'meals': meals.map(
        (k, v) => MapEntry(k.name, v.map((f) => f.toJson()).toList()),
      ),
      'totalCalories': totalCalories,
      'notes': notes,
    };
  }

  factory MealPlanDay.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'] as Map<String, dynamic>? ?? {};
    final parsedMeals = rawMeals.map(
      (k, v) => MapEntry(
        MealType.fromString(k),
        (v as List<dynamic>)
            .map((f) => FoodItem.fromJson(f as Map<String, dynamic>))
            .toList(),
      ),
    );
    return MealPlanDay(
      dayNumber: (json['dayNumber'] as num).toInt(),
      meals: parsedMeals,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  MealPlanDay copyWith({
    int? dayNumber,
    Map<MealType, List<FoodItem>>? meals,
    double? totalCalories,
    String? notes,
    bool clearNotes = false,
  }) {
    return MealPlanDay(
      dayNumber: dayNumber ?? this.dayNumber,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }
}

// ---------------------------------------------------------------------------
// MealPlan
// ---------------------------------------------------------------------------

@immutable
class MealPlan {
  final String id;
  final String gymId;
  final String name;
  final String description;
  final String createdBy;
  final int durationDays;
  final List<MealPlanDay> days;
  final String goal;
  final DateTime createdAt;

  const MealPlan({
    required this.id,
    required this.gymId,
    required this.name,
    this.description = '',
    required this.createdBy,
    required this.durationDays,
    this.days = const [],
    this.goal = 'General Fitness',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gymId': gymId,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'durationDays': durationDays,
      'days': days.map((d) => d.toJson()).toList(),
      'goal': goal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdBy: json['createdBy'] as String,
      durationDays: (json['durationDays'] as num).toInt(),
      days: (json['days'] as List<dynamic>?)
              ?.map((d) => MealPlanDay.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      goal: json['goal'] as String? ?? 'General Fitness',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  MealPlan copyWith({
    String? id,
    String? gymId,
    String? name,
    String? description,
    String? createdBy,
    int? durationDays,
    List<MealPlanDay>? days,
    String? goal,
    DateTime? createdAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      durationDays: durationDays ?? this.durationDays,
      days: days ?? this.days,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlan && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MealPlan(id: $id, name: $name, days: $durationDays)';
}
