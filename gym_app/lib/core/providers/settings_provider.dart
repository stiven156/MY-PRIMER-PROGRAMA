import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class SettingsState {
  final ThemeMode themeMode;
  final String language;
  final String weightUnit; // 'kg' | 'lb'
  final String heightUnit; // 'cm' | 'in'
  final bool notificationsEnabled;
  final bool workoutReminders;
  final bool classReminders;
  final bool paymentReminders;
  final TimeOfDay reminderTime;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'es',
    this.weightUnit = 'kg',
    this.heightUnit = 'cm',
    this.notificationsEnabled = true,
    this.workoutReminders = true,
    this.classReminders = true,
    this.paymentReminders = true,
    this.reminderTime = const TimeOfDay(hour: 8, minute: 0),
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    String? weightUnit,
    String? heightUnit,
    bool? notificationsEnabled,
    bool? workoutReminders,
    bool? classReminders,
    bool? paymentReminders,
    TimeOfDay? reminderTime,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      classReminders: classReminders ?? this.classReminders,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'language': language,
      'weightUnit': weightUnit,
      'heightUnit': heightUnit,
      'notificationsEnabled': notificationsEnabled,
      'workoutReminders': workoutReminders,
      'classReminders': classReminders,
      'paymentReminders': paymentReminders,
      'reminderHour': reminderTime.hour,
      'reminderMinute': reminderTime.minute,
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      themeMode:
          ThemeMode.values[map['themeMode'] as int? ?? ThemeMode.system.index],
      language: map['language'] as String? ?? 'es',
      weightUnit: map['weightUnit'] as String? ?? 'kg',
      heightUnit: map['heightUnit'] as String? ?? 'cm',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      workoutReminders: map['workoutReminders'] as bool? ?? true,
      classReminders: map['classReminders'] as bool? ?? true,
      paymentReminders: map['paymentReminders'] as bool? ?? true,
      reminderTime: TimeOfDay(
        hour: map['reminderHour'] as int? ?? 8,
        minute: map['reminderMinute'] as int? ?? 0,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    // Load persisted settings when the notifier is first created.
    loadFromPrefs();
  }

  /// Cycles through Light → Dark → System.
  void toggleTheme() {
    final next = switch (state.themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    state = state.copyWith(themeMode: next);
    saveToPrefs();
  }

  /// Forces a specific [ThemeMode].
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    saveToPrefs();
  }

  /// Changes the display language (e.g. 'es', 'en', 'pt').
  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
    saveToPrefs();
  }

  /// Sets the weight unit. Accepted values: `'kg'`, `'lb'`.
  void setWeightUnit(String unit) {
    assert(unit == 'kg' || unit == 'lb', 'Weight unit must be kg or lb.');
    state = state.copyWith(weightUnit: unit);
    saveToPrefs();
  }

  /// Sets the height unit. Accepted values: `'cm'`, `'in'`.
  void setHeightUnit(String unit) {
    assert(unit == 'cm' || unit == 'in', 'Height unit must be cm or in.');
    state = state.copyWith(heightUnit: unit);
    saveToPrefs();
  }

  /// Toggles the master notifications switch.
  void toggleNotifications() {
    state = state.copyWith(
        notificationsEnabled: !state.notificationsEnabled);
    saveToPrefs();
  }

  /// Toggles workout reminder notifications.
  void toggleWorkoutReminders() {
    state =
        state.copyWith(workoutReminders: !state.workoutReminders);
    saveToPrefs();
  }

  /// Toggles class booking reminder notifications.
  void toggleClassReminders() {
    state = state.copyWith(classReminders: !state.classReminders);
    saveToPrefs();
  }

  /// Toggles payment due notifications.
  void togglePaymentReminders() {
    state =
        state.copyWith(paymentReminders: !state.paymentReminders);
    saveToPrefs();
  }

  /// Sets the daily reminder time.
  void setReminderTime(TimeOfDay time) {
    state = state.copyWith(reminderTime: time);
    saveToPrefs();
  }

  /// Persists the current settings to shared preferences.
  /// In this mock implementation the method is a no-op because there is
  /// no `shared_preferences` dependency injected here, but it is the
  /// correct extension point — replace the body with:
  ///
  /// ```dart
  /// final prefs = await SharedPreferences.getInstance();
  /// final map = state.toMap();
  /// map.forEach((k, v) { ... });
  /// ```
  Future<void> saveToPrefs() async {
    // No-op in mock — extend with SharedPreferences when needed.
    await Future.delayed(Duration.zero);
  }

  /// Loads settings from shared preferences and updates state.
  /// Replace the body with a real SharedPreferences read when needed.
  Future<void> loadFromPrefs() async {
    // No-op in mock — defaults from the SettingsState constructor apply.
    await Future.delayed(Duration.zero);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
