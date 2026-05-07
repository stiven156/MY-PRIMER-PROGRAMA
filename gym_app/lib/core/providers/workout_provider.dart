import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/core/models/workout_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class WorkoutState {
  final List<WorkoutPlan> plans;
  final WorkoutSession? activeSession;
  final List<WorkoutSession> sessionHistory;
  final List<PersonalRecord> personalRecords;
  final bool isLoading;
  final String? error;

  const WorkoutState({
    this.plans = const [],
    this.activeSession,
    this.sessionHistory = const [],
    this.personalRecords = const [],
    this.isLoading = false,
    this.error,
  });

  WorkoutState copyWith({
    List<WorkoutPlan>? plans,
    WorkoutSession? activeSession,
    List<WorkoutSession>? sessionHistory,
    List<PersonalRecord>? personalRecords,
    bool? isLoading,
    String? error,
    bool clearActiveSession = false,
    bool clearError = false,
  }) {
    return WorkoutState(
      plans: plans ?? this.plans,
      activeSession:
          clearActiveSession ? null : (activeSession ?? this.activeSession),
      sessionHistory: sessionHistory ?? this.sessionHistory,
      personalRecords: personalRecords ?? this.personalRecords,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock workout plans
// ---------------------------------------------------------------------------

List<WorkoutPlan> _buildMockPlans() {
  final gymId = 'gym_mock_001';
  final creator = 'user_trainer_001';
  final baseDate = DateTime(2024, 1, 1);

  return [
    // 1 — Push
    WorkoutPlan(
      id: 'plan_push',
      name: 'Push Day',
      description: 'Pecho, hombros y tríceps. Enfoque en empuje horizontal y vertical.',
      gymId: gymId,
      createdBy: creator,
      primaryMuscleGroup: MuscleGroup.chest,
      difficulty: ExerciseDifficulty.intermediate,
      estimatedMinutes: 65,
      createdAt: baseDate,
      isTemplate: true,
      exercises: [
        WorkoutExercise(
          exerciseId: 'ex_bench_press',
          exerciseName: 'Press de Banca',
          sets: [
            WorkoutSet(reps: 10, weight: 60, restSeconds: 90),
            WorkoutSet(reps: 8, weight: 70, restSeconds: 90),
            WorkoutSet(reps: 6, weight: 80, restSeconds: 120),
            WorkoutSet(reps: 6, weight: 80, restSeconds: 120),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_incline_press',
          exerciseName: 'Press Inclinado con Mancuernas',
          sets: [
            WorkoutSet(reps: 12, weight: 24, restSeconds: 75),
            WorkoutSet(reps: 10, weight: 28, restSeconds: 75),
            WorkoutSet(reps: 10, weight: 28, restSeconds: 75),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_military_press',
          exerciseName: 'Press Militar',
          sets: [
            WorkoutSet(reps: 10, weight: 40, restSeconds: 90),
            WorkoutSet(reps: 8, weight: 50, restSeconds: 90),
            WorkoutSet(reps: 8, weight: 50, restSeconds: 90),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_lateral_raises',
          exerciseName: 'Elevaciones Laterales',
          sets: [
            WorkoutSet(reps: 15, weight: 10, restSeconds: 60),
            WorkoutSet(reps: 15, weight: 10, restSeconds: 60),
            WorkoutSet(reps: 12, weight: 12, restSeconds: 60),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_tricep_ext',
          exerciseName: 'Extensiones de Tríceps en Polea',
          sets: [
            WorkoutSet(reps: 15, weight: 25, restSeconds: 60),
            WorkoutSet(reps: 12, weight: 30, restSeconds: 60),
            WorkoutSet(reps: 12, weight: 30, restSeconds: 60),
          ],
        ),
      ],
    ),

    // 2 — Pull
    WorkoutPlan(
      id: 'plan_pull',
      name: 'Pull Day',
      description: 'Espalda y bíceps. Dominadas, remos y curls.',
      gymId: gymId,
      createdBy: creator,
      primaryMuscleGroup: MuscleGroup.back,
      difficulty: ExerciseDifficulty.intermediate,
      estimatedMinutes: 60,
      createdAt: baseDate.add(const Duration(days: 1)),
      isTemplate: true,
      exercises: [
        WorkoutExercise(
          exerciseId: 'ex_pullup',
          exerciseName: 'Dominadas',
          sets: [
            WorkoutSet(reps: 8, weight: 0, restSeconds: 120),
            WorkoutSet(reps: 8, weight: 0, restSeconds: 120),
            WorkoutSet(reps: 6, weight: 0, restSeconds: 120),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_barbell_row',
          exerciseName: 'Remo con Barra',
          sets: [
            WorkoutSet(reps: 10, weight: 60, restSeconds: 90),
            WorkoutSet(reps: 8, weight: 70, restSeconds: 90),
            WorkoutSet(reps: 8, weight: 70, restSeconds: 90),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_lat_pulldown',
          exerciseName: 'Jalones en Polea',
          sets: [
            WorkoutSet(reps: 12, weight: 55, restSeconds: 75),
            WorkoutSet(reps: 10, weight: 65, restSeconds: 75),
            WorkoutSet(reps: 10, weight: 65, restSeconds: 75),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_bicep_curl',
          exerciseName: 'Curl de Bíceps con Barra',
          sets: [
            WorkoutSet(reps: 12, weight: 30, restSeconds: 60),
            WorkoutSet(reps: 10, weight: 35, restSeconds: 60),
            WorkoutSet(reps: 10, weight: 35, restSeconds: 60),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_hammer_curl',
          exerciseName: 'Curl Martillo',
          sets: [
            WorkoutSet(reps: 12, weight: 14, restSeconds: 60),
            WorkoutSet(reps: 12, weight: 14, restSeconds: 60),
            WorkoutSet(reps: 10, weight: 16, restSeconds: 60),
          ],
        ),
      ],
    ),

    // 3 — Legs
    WorkoutPlan(
      id: 'plan_legs',
      name: 'Leg Day',
      description: 'Cuádriceps, isquiotibiales, glúteos y pantorrillas.',
      gymId: gymId,
      createdBy: creator,
      primaryMuscleGroup: MuscleGroup.legs,
      difficulty: ExerciseDifficulty.advanced,
      estimatedMinutes: 75,
      createdAt: baseDate.add(const Duration(days: 2)),
      isTemplate: true,
      exercises: [
        WorkoutExercise(
          exerciseId: 'ex_squat',
          exerciseName: 'Sentadilla con Barra',
          sets: [
            WorkoutSet(reps: 10, weight: 80, restSeconds: 120),
            WorkoutSet(reps: 8, weight: 100, restSeconds: 120),
            WorkoutSet(reps: 6, weight: 110, restSeconds: 150),
            WorkoutSet(reps: 6, weight: 110, restSeconds: 150),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_leg_press',
          exerciseName: 'Prensa de Piernas',
          sets: [
            WorkoutSet(reps: 15, weight: 120, restSeconds: 90),
            WorkoutSet(reps: 12, weight: 150, restSeconds: 90),
            WorkoutSet(reps: 10, weight: 180, restSeconds: 90),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_deadlift',
          exerciseName: 'Peso Muerto',
          sets: [
            WorkoutSet(reps: 8, weight: 100, restSeconds: 120),
            WorkoutSet(reps: 6, weight: 120, restSeconds: 120),
            WorkoutSet(reps: 5, weight: 130, restSeconds: 150),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_lunges',
          exerciseName: 'Zancadas con Mancuernas',
          sets: [
            WorkoutSet(reps: 12, weight: 20, restSeconds: 75),
            WorkoutSet(reps: 12, weight: 20, restSeconds: 75),
            WorkoutSet(reps: 10, weight: 24, restSeconds: 75),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_calf_raises',
          exerciseName: 'Elevaciones de Pantorrillas',
          sets: [
            WorkoutSet(reps: 20, weight: 60, restSeconds: 45),
            WorkoutSet(reps: 20, weight: 60, restSeconds: 45),
            WorkoutSet(reps: 15, weight: 80, restSeconds: 45),
          ],
        ),
      ],
    ),

    // 4 — Full Body
    WorkoutPlan(
      id: 'plan_full_body',
      name: 'Full Body',
      description: 'Entrenamiento de cuerpo completo, ideal 3 veces por semana.',
      gymId: gymId,
      createdBy: creator,
      primaryMuscleGroup: MuscleGroup.functional,
      difficulty: ExerciseDifficulty.beginner,
      estimatedMinutes: 55,
      createdAt: baseDate.add(const Duration(days: 3)),
      isTemplate: true,
      exercises: [
        WorkoutExercise(
          exerciseId: 'ex_squat',
          exerciseName: 'Sentadilla',
          sets: [
            WorkoutSet(reps: 12, weight: 40, restSeconds: 90),
            WorkoutSet(reps: 10, weight: 50, restSeconds: 90),
            WorkoutSet(reps: 10, weight: 50, restSeconds: 90),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_bench_press',
          exerciseName: 'Press de Banca',
          sets: [
            WorkoutSet(reps: 12, weight: 40, restSeconds: 90),
            WorkoutSet(reps: 10, weight: 50, restSeconds: 90),
            WorkoutSet(reps: 10, weight: 50, restSeconds: 90),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_barbell_row',
          exerciseName: 'Remo con Barra',
          sets: [
            WorkoutSet(reps: 12, weight: 40, restSeconds: 90),
            WorkoutSet(reps: 10, weight: 50, restSeconds: 90),
            WorkoutSet(reps: 10, weight: 50, restSeconds: 90),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_plank',
          exerciseName: 'Plancha',
          sets: [
            WorkoutSet(reps: 60, weight: 0, restSeconds: 60),
            WorkoutSet(reps: 60, weight: 0, restSeconds: 60),
            WorkoutSet(reps: 45, weight: 0, restSeconds: 60),
          ],
          notes: 'Reps = segundos',
        ),
      ],
    ),

    // 5 — Cardio
    WorkoutPlan(
      id: 'plan_cardio',
      name: 'Cardio & Conditioning',
      description: 'Sesión de cardio de alta intensidad con ejercicios funcionales.',
      gymId: gymId,
      createdBy: creator,
      primaryMuscleGroup: MuscleGroup.cardio,
      difficulty: ExerciseDifficulty.intermediate,
      estimatedMinutes: 45,
      createdAt: baseDate.add(const Duration(days: 4)),
      isTemplate: true,
      exercises: [
        WorkoutExercise(
          exerciseId: 'ex_burpees',
          exerciseName: 'Burpees',
          sets: [
            WorkoutSet(reps: 15, weight: 0, restSeconds: 60),
            WorkoutSet(reps: 15, weight: 0, restSeconds: 60),
            WorkoutSet(reps: 12, weight: 0, restSeconds: 60),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_box_jump',
          exerciseName: 'Box Jump',
          sets: [
            WorkoutSet(reps: 10, weight: 0, restSeconds: 75),
            WorkoutSet(reps: 10, weight: 0, restSeconds: 75),
            WorkoutSet(reps: 8, weight: 0, restSeconds: 75),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_jump_rope',
          exerciseName: 'Salto de Cuerda',
          sets: [
            WorkoutSet(reps: 60, weight: 0, restSeconds: 45),
            WorkoutSet(reps: 60, weight: 0, restSeconds: 45),
            WorkoutSet(reps: 60, weight: 0, restSeconds: 45),
          ],
          notes: 'Reps = segundos',
        ),
        WorkoutExercise(
          exerciseId: 'ex_running',
          exerciseName: 'Carrera en Cinta',
          sets: [
            WorkoutSet(reps: 20, weight: 0, restSeconds: 0),
          ],
          notes: '20 minutos a ritmo moderado-alto',
        ),
      ],
    ),

    // 6 — Functional
    WorkoutPlan(
      id: 'plan_functional',
      name: 'Entrenamiento Funcional',
      description: 'Kettlebell, TRX y movimientos funcionales para fuerza real.',
      gymId: gymId,
      createdBy: creator,
      primaryMuscleGroup: MuscleGroup.functional,
      difficulty: ExerciseDifficulty.intermediate,
      estimatedMinutes: 50,
      createdAt: baseDate.add(const Duration(days: 5)),
      isTemplate: true,
      exercises: [
        WorkoutExercise(
          exerciseId: 'ex_kb_swing',
          exerciseName: 'Kettlebell Swing',
          sets: [
            WorkoutSet(reps: 20, weight: 16, restSeconds: 60),
            WorkoutSet(reps: 20, weight: 20, restSeconds: 60),
            WorkoutSet(reps: 15, weight: 24, restSeconds: 60),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_turkish_getup',
          exerciseName: 'Turkish Get-Up',
          sets: [
            WorkoutSet(reps: 5, weight: 16, restSeconds: 90),
            WorkoutSet(reps: 5, weight: 16, restSeconds: 90),
            WorkoutSet(reps: 4, weight: 20, restSeconds: 90),
          ],
          notes: 'Alternar lados',
        ),
        WorkoutExercise(
          exerciseId: 'ex_battle_ropes',
          exerciseName: 'Battle Ropes',
          sets: [
            WorkoutSet(reps: 30, weight: 0, restSeconds: 60),
            WorkoutSet(reps: 30, weight: 0, restSeconds: 60),
            WorkoutSet(reps: 30, weight: 0, restSeconds: 60),
          ],
          notes: 'Reps = segundos',
        ),
        WorkoutExercise(
          exerciseId: 'ex_box_jump',
          exerciseName: 'Box Jump',
          sets: [
            WorkoutSet(reps: 8, weight: 0, restSeconds: 75),
            WorkoutSet(reps: 8, weight: 0, restSeconds: 75),
            WorkoutSet(reps: 6, weight: 0, restSeconds: 75),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_burpees',
          exerciseName: 'Burpees',
          sets: [
            WorkoutSet(reps: 10, weight: 0, restSeconds: 60),
            WorkoutSet(reps: 10, weight: 0, restSeconds: 60),
            WorkoutSet(reps: 10, weight: 0, restSeconds: 60),
          ],
        ),
      ],
    ),
  ];
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  WorkoutNotifier() : super(WorkoutState(plans: _buildMockPlans()));

  /// Reloads plans for a gym (simulated).
  Future<void> loadPlans(String gymId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false, clearError: true);
  }

  /// Adds a new workout plan.
  Future<void> createPlan(WorkoutPlan plan) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(
      isLoading: false,
      plans: [...state.plans, plan],
    );
  }

  /// Replaces an existing plan.
  Future<void> updatePlan(WorkoutPlan updated) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));
    final plans =
        state.plans.map((p) => p.id == updated.id ? updated : p).toList();
    state = state.copyWith(isLoading: false, plans: plans);
  }

  /// Removes a plan by id.
  Future<void> deletePlan(String planId) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));
    final plans = state.plans.where((p) => p.id != planId).toList();
    state = state.copyWith(isLoading: false, plans: plans);
  }

  /// Starts a new workout session, optionally from a plan.
  void startSession(WorkoutPlan? plan, List<WorkoutExercise> exercises) {
    if (state.activeSession != null) return; // already active
    final session = WorkoutSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      planId: plan?.id,
      planName: plan?.name,
      exercises: exercises.isNotEmpty
          ? exercises
          : (plan?.exercises ?? []),
      startTime: DateTime.now(),
    );
    state = state.copyWith(activeSession: session);
  }

  /// Updates the actual reps and weight for a specific set.
  void logSet(int exerciseIndex, int setIndex, int actualReps,
      double actualWeight) {
    final session = state.activeSession;
    if (session == null) return;

    final exercises = List<WorkoutExercise>.from(session.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<WorkoutSet>.from(exercise.sets);
    sets[setIndex] = sets[setIndex].copyWith(
      actualReps: actualReps,
      actualWeight: actualWeight,
    );
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);

    state = state.copyWith(
      activeSession: session.copyWith(exercises: exercises),
    );
  }

  /// Marks a set as completed.
  void completeSet(int exerciseIndex, int setIndex) {
    final session = state.activeSession;
    if (session == null) return;

    final exercises = List<WorkoutExercise>.from(session.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<WorkoutSet>.from(exercise.sets);
    final s = sets[setIndex];
    sets[setIndex] = s.copyWith(
      isCompleted: true,
      actualReps: s.actualReps ?? s.reps,
      actualWeight: s.actualWeight ?? s.weight,
    );
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);

    final updatedSession = session.copyWith(exercises: exercises);
    state = state.copyWith(activeSession: updatedSession);

    // Check for PR after completing.
    final completedSet = sets[setIndex];
    checkAndUpdatePR(
      exercise.exerciseId,
      exercise.exerciseName,
      completedSet.actualWeight ?? completedSet.weight,
      completedSet.actualReps ?? completedSet.reps,
    );
  }

  /// Finalises the active session and moves it to history.
  void finishSession() {
    final session = state.activeSession;
    if (session == null) return;
    final finished = session.copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
    );
    state = state.copyWith(
      clearActiveSession: true,
      sessionHistory: [finished, ...state.sessionHistory],
    );
  }

  /// Discards the active session without saving.
  void cancelSession() {
    state = state.copyWith(clearActiveSession: true);
  }

  /// Updates personal records if [weight] × [reps] exceeds the current best.
  void checkAndUpdatePR(
      String exerciseId, String exerciseName, double weight, int reps) {
    final existing =
        state.personalRecords.where((pr) => pr.exerciseId == exerciseId).firstOrNull;

    // Use estimated 1RM (Epley formula) to compare.
    final new1RM = weight * (1 + reps / 30.0);
    final current1RM = existing == null
        ? 0.0
        : existing.weight * (1 + existing.reps / 30.0);

    if (new1RM > current1RM) {
      final newPR = PersonalRecord(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        weight: weight,
        reps: reps,
        achievedAt: DateTime.now(),
      );
      final records = [
        ...state.personalRecords.where((pr) => pr.exerciseId != exerciseId),
        newPR,
      ];
      state = state.copyWith(personalRecords: records);
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final workoutProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>(
  (ref) => WorkoutNotifier(),
);

/// Returns the currently active [WorkoutSession], or `null`.
final activeSessionProvider = Provider<WorkoutSession?>(
  (ref) => ref.watch(workoutProvider).activeSession,
);

/// Returns the list of personal records.
final personalRecordsProvider = Provider<List<PersonalRecord>>(
  (ref) => ref.watch(workoutProvider).personalRecords,
);
