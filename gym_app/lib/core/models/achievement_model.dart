import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum AchievementCategory {
  attendance,
  workout,
  nutrition,
  measurements,
  social,
  financial,
  special;

  String get displayName {
    switch (this) {
      case AchievementCategory.attendance:
        return 'Attendance';
      case AchievementCategory.workout:
        return 'Workout';
      case AchievementCategory.nutrition:
        return 'Nutrition';
      case AchievementCategory.measurements:
        return 'Measurements';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.financial:
        return 'Financial';
      case AchievementCategory.special:
        return 'Special';
    }
  }

  static AchievementCategory fromString(String value) {
    return AchievementCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AchievementCategory.special,
    );
  }
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  legendary;

  String get displayName {
    switch (this) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.platinum:
        return 'Platinum';
      case AchievementTier.legendary:
        return 'Legendary';
    }
  }

  static AchievementTier fromString(String value) {
    return AchievementTier.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AchievementTier.bronze,
    );
  }
}

// ---------------------------------------------------------------------------
// Achievement
// ---------------------------------------------------------------------------

@immutable
class Achievement {
  final String id;
  final String title;
  final String description;

  /// Emoji icon representing this achievement, e.g. "🏆".
  final String icon;

  final int xpReward;
  final AchievementCategory category;
  final AchievementTier tier;
  final bool unlocked;
  final DateTime? unlockedAt;

  /// Target value to complete this achievement (e.g. 30 check-ins).
  final int requirement;

  /// Member's current progress towards [requirement].
  final int currentProgress;

  /// Null means this is a global achievement not tied to a specific gym.
  final String? gymId;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.category,
    required this.tier,
    this.unlocked = false,
    this.unlockedAt,
    required this.requirement,
    this.currentProgress = 0,
    this.gymId,
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// Progress as a fraction 0.0–1.0.
  double get progressPercentage {
    if (requirement <= 0) return unlocked ? 1.0 : 0.0;
    return (currentProgress / requirement).clamp(0.0, 1.0);
  }

  bool get isCompleted => unlocked || currentProgress >= requirement;

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'xpReward': xpReward,
      'category': category.name,
      'tier': tier.name,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'requirement': requirement,
      'currentProgress': currentProgress,
      'gymId': gymId,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? '🏅',
      xpReward: (json['xpReward'] as num).toInt(),
      category: AchievementCategory.fromString(
          json['category'] as String? ?? 'special'),
      tier: AchievementTier.fromString(
          json['tier'] as String? ?? 'bronze'),
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      requirement: (json['requirement'] as num).toInt(),
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      gymId: json['gymId'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? xpReward,
    AchievementCategory? category,
    AchievementTier? tier,
    bool? unlocked,
    DateTime? unlockedAt,
    int? requirement,
    int? currentProgress,
    String? gymId,
    bool clearUnlockedAt = false,
    bool clearGymId = false,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      xpReward: xpReward ?? this.xpReward,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: clearUnlockedAt ? null : (unlockedAt ?? this.unlockedAt),
      requirement: requirement ?? this.requirement,
      currentProgress: currentProgress ?? this.currentProgress,
      gymId: clearGymId ? null : (gymId ?? this.gymId),
    );
  }

  // ---------------------------------------------------------------------------
  // Static catalogue  (20 achievements)
  // ---------------------------------------------------------------------------

  static List<Achievement> allAchievements() {
    return [
      // --- Attendance ---
      const Achievement(
        id: 'ach_first_checkin',
        title: 'First Step',
        description: 'Complete your first check-in at the gym.',
        icon: '👟',
        xpReward: 50,
        category: AchievementCategory.attendance,
        tier: AchievementTier.bronze,
        requirement: 1,
      ),
      const Achievement(
        id: 'ach_10_checkins',
        title: 'Getting Started',
        description: 'Check in 10 times.',
        icon: '🔟',
        xpReward: 100,
        category: AchievementCategory.attendance,
        tier: AchievementTier.bronze,
        requirement: 10,
      ),
      const Achievement(
        id: 'ach_30_checkins',
        title: 'Monthly Regular',
        description: 'Check in 30 times.',
        icon: '📅',
        xpReward: 200,
        category: AchievementCategory.attendance,
        tier: AchievementTier.silver,
        requirement: 30,
      ),
      const Achievement(
        id: 'ach_100_checkins',
        title: 'Century Club',
        description: 'Check in 100 times.',
        icon: '💯',
        xpReward: 500,
        category: AchievementCategory.attendance,
        tier: AchievementTier.gold,
        requirement: 100,
      ),
      const Achievement(
        id: 'ach_365_checkins',
        title: 'Year Warrior',
        description: 'Check in 365 times — a full year of dedication!',
        icon: '🏟️',
        xpReward: 2000,
        category: AchievementCategory.attendance,
        tier: AchievementTier.legendary,
        requirement: 365,
      ),
      // --- Workout ---
      const Achievement(
        id: 'ach_first_workout',
        title: 'First Sweat',
        description: 'Log your first workout session.',
        icon: '💪',
        xpReward: 50,
        category: AchievementCategory.workout,
        tier: AchievementTier.bronze,
        requirement: 1,
      ),
      const Achievement(
        id: 'ach_50_workouts',
        title: 'Iron Habit',
        description: 'Complete 50 workout sessions.',
        icon: '🏋️',
        xpReward: 300,
        category: AchievementCategory.workout,
        tier: AchievementTier.silver,
        requirement: 50,
      ),
      const Achievement(
        id: 'ach_pr',
        title: 'New Personal Record',
        description: 'Set your first personal record.',
        icon: '🎯',
        xpReward: 150,
        category: AchievementCategory.workout,
        tier: AchievementTier.silver,
        requirement: 1,
      ),
      const Achievement(
        id: 'ach_10_pr',
        title: 'Record Breaker',
        description: 'Set 10 personal records across different exercises.',
        icon: '📈',
        xpReward: 400,
        category: AchievementCategory.workout,
        tier: AchievementTier.gold,
        requirement: 10,
      ),
      const Achievement(
        id: 'ach_1000kg_volume',
        title: 'Ton Lifter',
        description: 'Lift a cumulative total of 1,000 kg in a single session.',
        icon: '🦾',
        xpReward: 250,
        category: AchievementCategory.workout,
        tier: AchievementTier.gold,
        requirement: 1000,
      ),
      // --- Nutrition ---
      const Achievement(
        id: 'ach_7day_log',
        title: 'Week of Greens',
        description: 'Log meals for 7 consecutive days.',
        icon: '🥦',
        xpReward: 150,
        category: AchievementCategory.nutrition,
        tier: AchievementTier.bronze,
        requirement: 7,
      ),
      const Achievement(
        id: 'ach_30day_log',
        title: 'Nutrition Ninja',
        description: 'Log meals for 30 consecutive days.',
        icon: '🥗',
        xpReward: 400,
        category: AchievementCategory.nutrition,
        tier: AchievementTier.gold,
        requirement: 30,
      ),
      const Achievement(
        id: 'ach_water_goal',
        title: 'Hydration Hero',
        description: 'Reach your daily water goal 14 days in a row.',
        icon: '💧',
        xpReward: 200,
        category: AchievementCategory.nutrition,
        tier: AchievementTier.silver,
        requirement: 14,
      ),
      // --- Measurements ---
      const Achievement(
        id: 'ach_first_measurement',
        title: 'Body Scan',
        description: 'Record your first body measurement.',
        icon: '📏',
        xpReward: 75,
        category: AchievementCategory.measurements,
        tier: AchievementTier.bronze,
        requirement: 1,
      ),
      const Achievement(
        id: 'ach_12_measurements',
        title: 'Progress Tracker',
        description: 'Record 12 body measurements (roughly one per month).',
        icon: '📊',
        xpReward: 350,
        category: AchievementCategory.measurements,
        tier: AchievementTier.gold,
        requirement: 12,
      ),
      // --- Social ---
      const Achievement(
        id: 'ach_first_post',
        title: 'Social Butterfly',
        description: 'Publish your first post in the community feed.',
        icon: '🦋',
        xpReward: 50,
        category: AchievementCategory.social,
        tier: AchievementTier.bronze,
        requirement: 1,
      ),
      const Achievement(
        id: 'ach_challenge_winner',
        title: 'Challenge Champion',
        description: 'Win a gym challenge.',
        icon: '🏆',
        xpReward: 500,
        category: AchievementCategory.social,
        tier: AchievementTier.platinum,
        requirement: 1,
      ),
      // --- Financial ---
      const Achievement(
        id: 'ach_on_time_payments',
        title: 'Reliable Member',
        description: 'Make 12 on-time membership payments.',
        icon: '💳',
        xpReward: 300,
        category: AchievementCategory.financial,
        tier: AchievementTier.silver,
        requirement: 12,
      ),
      // --- Special ---
      const Achievement(
        id: 'ach_early_bird',
        title: 'Early Bird',
        description: 'Check in before 07:00 AM on 20 occasions.',
        icon: '🌅',
        xpReward: 200,
        category: AchievementCategory.special,
        tier: AchievementTier.silver,
        requirement: 20,
      ),
      const Achievement(
        id: 'ach_legendary_member',
        title: 'FitPro Legend',
        description:
            'Unlock every other achievement. You are truly legendary.',
        icon: '⭐',
        xpReward: 5000,
        category: AchievementCategory.special,
        tier: AchievementTier.legendary,
        requirement: 19,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Achievement(id: $id, title: $title, tier: ${tier.name})';
}
