import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum ClassCategory {
  spinning,
  yoga,
  crossfit,
  zumba,
  pilates,
  boxing,
  functional,
  hiit,
  bodyPump,
  stretching;

  String get displayName {
    switch (this) {
      case ClassCategory.spinning:
        return 'Spinning';
      case ClassCategory.yoga:
        return 'Yoga';
      case ClassCategory.crossfit:
        return 'CrossFit';
      case ClassCategory.zumba:
        return 'Zumba';
      case ClassCategory.pilates:
        return 'Pilates';
      case ClassCategory.boxing:
        return 'Boxeo';
      case ClassCategory.functional:
        return 'Funcional';
      case ClassCategory.hiit:
        return 'HIIT';
      case ClassCategory.bodyPump:
        return 'Body Pump';
      case ClassCategory.stretching:
        return 'Estiramiento';
    }
  }

  String get emoji {
    switch (this) {
      case ClassCategory.spinning:
        return '🚴';
      case ClassCategory.yoga:
        return '🧘';
      case ClassCategory.crossfit:
        return '🏋️';
      case ClassCategory.zumba:
        return '💃';
      case ClassCategory.pilates:
        return '🤸';
      case ClassCategory.boxing:
        return '🥊';
      case ClassCategory.functional:
        return '⚡';
      case ClassCategory.hiit:
        return '🔥';
      case ClassCategory.bodyPump:
        return '💪';
      case ClassCategory.stretching:
        return '🌿';
    }
  }
}

@immutable
class GymClass {
  final String id;
  final String gymId;
  final String name;
  final String trainerId;
  final String trainerName;
  final ClassCategory category;
  final DateTime startTime;
  final DateTime endTime;
  final int maxParticipants;
  final List<String> bookedMemberIds;
  final String? description;
  final String? location;
  final bool isCancelled;
  final String? cancelReason;

  const GymClass({
    required this.id,
    required this.gymId,
    required this.name,
    required this.trainerId,
    required this.trainerName,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.maxParticipants,
    this.bookedMemberIds = const [],
    this.description,
    this.location,
    this.isCancelled = false,
    this.cancelReason,
  });

  int get availableSpots => maxParticipants - bookedMemberIds.length;
  bool get isFull => bookedMemberIds.length >= maxParticipants;
  Duration get duration => endTime.difference(startTime);

  GymClass copyWith({
    String? id,
    String? gymId,
    String? name,
    String? trainerId,
    String? trainerName,
    ClassCategory? category,
    DateTime? startTime,
    DateTime? endTime,
    int? maxParticipants,
    List<String>? bookedMemberIds,
    String? description,
    String? location,
    bool? isCancelled,
    String? cancelReason,
  }) {
    return GymClass(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      bookedMemberIds: bookedMemberIds ?? this.bookedMemberIds,
      description: description ?? this.description,
      location: location ?? this.location,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymClass && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ScheduleState {
  final List<GymClass> classes;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;

  ScheduleState({
    this.classes = const [],
    this.isLoading = false,
    this.error,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  ScheduleState copyWith({
    List<GymClass>? classes,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    bool clearError = false,
  }) {
    return ScheduleState(
      classes: classes ?? this.classes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

// ---------------------------------------------------------------------------
// Mock class schedule — 20+ classes for the current month
// ---------------------------------------------------------------------------

List<GymClass> _buildMockClasses() {
  final now = DateTime.now();
  final gymId = 'gym_mock_001';
  final trainerId = 'user_trainer_001';
  final trainerName = 'María García';

  // Helper to create a class on a specific day of this month
  GymClass mkClass({
    required String id,
    required int day,
    required int hour,
    required int minutes,
    required int durationMin,
    required String name,
    required ClassCategory cat,
    required int maxPax,
    List<String> booked = const [],
    String? desc,
    String location = 'Sala Principal',
  }) {
    final start = DateTime(now.year, now.month, day, hour, minutes);
    return GymClass(
      id: id,
      gymId: gymId,
      name: name,
      trainerId: trainerId,
      trainerName: trainerName,
      category: cat,
      startTime: start,
      endTime: start.add(Duration(minutes: durationMin)),
      maxParticipants: maxPax,
      bookedMemberIds: booked,
      description: desc,
      location: location,
    );
  }

  return [
    mkClass(
      id: 'cls_001', day: 1, hour: 7, minutes: 0,
      durationMin: 45, name: 'Spinning Matutino',
      cat: ClassCategory.spinning, maxPax: 20,
      booked: ['mem_001', 'mem_003', 'mem_005'],
      desc: 'Clase de spinning de alta intensidad para empezar el día.',
      location: 'Sala de Spinning',
    ),
    mkClass(
      id: 'cls_002', day: 1, hour: 9, minutes: 30,
      durationMin: 60, name: 'Yoga Flow',
      cat: ClassCategory.yoga, maxPax: 15,
      booked: ['mem_002', 'mem_006', 'mem_008', 'mem_010'],
      desc: 'Yoga fluido para todos los niveles.',
      location: 'Yoga Studio',
    ),
    mkClass(
      id: 'cls_003', day: 2, hour: 6, minutes: 30,
      durationMin: 60, name: 'CrossFit WOD',
      cat: ClassCategory.crossfit, maxPax: 12,
      booked: ['mem_003', 'mem_005', 'mem_007', 'mem_011'],
      desc: 'Workout of the Day. Alta intensidad funcional.',
    ),
    mkClass(
      id: 'cls_004', day: 2, hour: 18, minutes: 0,
      durationMin: 55, name: 'Zumba Fitness',
      cat: ClassCategory.zumba, maxPax: 25,
      booked: ['mem_002', 'mem_004', 'mem_006', 'mem_008', 'mem_012', 'mem_014'],
      desc: 'Baila y quema calorías con ritmos latinos.',
    ),
    mkClass(
      id: 'cls_005', day: 3, hour: 7, minutes: 0,
      durationMin: 45, name: 'HIIT Express',
      cat: ClassCategory.hiit, maxPax: 18,
      booked: ['mem_001', 'mem_005', 'mem_009', 'mem_013'],
      desc: 'Intervalos de alta intensidad. Máxima quema de grasa.',
    ),
    mkClass(
      id: 'cls_006', day: 3, hour: 10, minutes: 0,
      durationMin: 50, name: 'Pilates Core',
      cat: ClassCategory.pilates, maxPax: 12,
      booked: ['mem_002', 'mem_006', 'mem_010'],
      desc: 'Fortalece el core con técnica Pilates.',
      location: 'Sala Pilates',
    ),
    mkClass(
      id: 'cls_007', day: 3, hour: 19, minutes: 0,
      durationMin: 60, name: 'Body Pump',
      cat: ClassCategory.bodyPump, maxPax: 20,
      booked: ['mem_003', 'mem_005', 'mem_007', 'mem_011', 'mem_013'],
      desc: 'Entrenamiento con barra para tono y fuerza muscular.',
    ),
    mkClass(
      id: 'cls_008', day: 4, hour: 7, minutes: 0,
      durationMin: 45, name: 'Spinning Matutino',
      cat: ClassCategory.spinning, maxPax: 20,
      booked: ['mem_001', 'mem_003', 'mem_011'],
      location: 'Sala de Spinning',
    ),
    mkClass(
      id: 'cls_009', day: 4, hour: 18, minutes: 30,
      durationMin: 60, name: 'Boxeo Fitness',
      cat: ClassCategory.boxing, maxPax: 16,
      booked: ['mem_005', 'mem_007', 'mem_009', 'mem_013', 'mem_015'],
      desc: 'Técnica de boxeo aplicada al fitness. No requiere experiencia.',
      location: 'Sala de Boxeo',
    ),
    mkClass(
      id: 'cls_010', day: 5, hour: 6, minutes: 30,
      durationMin: 60, name: 'CrossFit WOD',
      cat: ClassCategory.crossfit, maxPax: 12,
      booked: ['mem_003', 'mem_005', 'mem_007'],
      desc: 'Workout del viernes. Terminamos la semana fuerte.',
    ),
    mkClass(
      id: 'cls_011', day: 5, hour: 9, minutes: 0,
      durationMin: 60, name: 'Yoga Restaurativo',
      cat: ClassCategory.yoga, maxPax: 15,
      booked: ['mem_002', 'mem_006', 'mem_008', 'mem_010', 'mem_014'],
      desc: 'Yoga suave y reparador. Ideal para recuperación.',
      location: 'Yoga Studio',
    ),
    mkClass(
      id: 'cls_012', day: 5, hour: 19, minutes: 0,
      durationMin: 55, name: 'Zumba Party',
      cat: ClassCategory.zumba, maxPax: 30,
      booked: ['mem_002', 'mem_004', 'mem_006', 'mem_008', 'mem_010', 'mem_012', 'mem_014'],
      desc: 'Clase especial de viernes. ¡A bailar!',
    ),
    mkClass(
      id: 'cls_013', day: 6, hour: 8, minutes: 0,
      durationMin: 75, name: 'CrossFit Sábado',
      cat: ClassCategory.crossfit, maxPax: 15,
      booked: ['mem_001', 'mem_003', 'mem_005', 'mem_007', 'mem_011', 'mem_013', 'mem_015'],
      desc: 'La sesión más intensa de la semana. ¡Prepárate!',
    ),
    mkClass(
      id: 'cls_014', day: 6, hour: 10, minutes: 0,
      durationMin: 60, name: 'Spinning Grupal',
      cat: ClassCategory.spinning, maxPax: 20,
      booked: ['mem_001', 'mem_003', 'mem_009', 'mem_011'],
      location: 'Sala de Spinning',
    ),
    mkClass(
      id: 'cls_015', day: 6, hour: 11, minutes: 30,
      durationMin: 60, name: 'Pilates Avanzado',
      cat: ClassCategory.pilates, maxPax: 10,
      booked: ['mem_002', 'mem_008', 'mem_014'],
      desc: 'Pilates para nivel intermedio-avanzado.',
      location: 'Sala Pilates',
    ),
    mkClass(
      id: 'cls_016', day: now.day, hour: 7, minutes: 0,
      durationMin: 45, name: 'HIIT Matutino',
      cat: ClassCategory.hiit, maxPax: 18,
      booked: ['mem_001', 'mem_005', 'mem_011'],
      desc: 'Empieza hoy con máxima energía.',
    ),
    mkClass(
      id: 'cls_017', day: now.day, hour: 9, minutes: 30,
      durationMin: 60, name: 'Yoga Flow',
      cat: ClassCategory.yoga, maxPax: 15,
      booked: ['mem_002', 'mem_008', 'mem_010'],
      location: 'Yoga Studio',
    ),
    mkClass(
      id: 'cls_018', day: now.day, hour: 18, minutes: 0,
      durationMin: 60, name: 'Entrenamiento Funcional',
      cat: ClassCategory.functional, maxPax: 15,
      booked: ['mem_003', 'mem_005', 'mem_007', 'mem_013'],
      desc: 'Movimientos funcionales con kettlebells y TRX.',
    ),
    mkClass(
      id: 'cls_019', day: now.day, hour: 19, minutes: 30,
      durationMin: 55, name: 'Body Pump Nocturno',
      cat: ClassCategory.bodyPump, maxPax: 20,
      booked: ['mem_001', 'mem_003', 'mem_009', 'mem_011', 'mem_013'],
    ),
    mkClass(
      id: 'cls_020', day: now.day + 1 <= 28 ? now.day + 1 : now.day,
      hour: 7, minutes: 0, durationMin: 45,
      name: 'Spinning Matutino',
      cat: ClassCategory.spinning, maxPax: 20,
      booked: [],
      location: 'Sala de Spinning',
    ),
    mkClass(
      id: 'cls_021', day: now.day + 1 <= 28 ? now.day + 1 : now.day,
      hour: 18, minutes: 0, durationMin: 60,
      name: 'Boxeo Fitness',
      cat: ClassCategory.boxing, maxPax: 16,
      booked: ['mem_005', 'mem_007'],
      location: 'Sala de Boxeo',
    ),
    mkClass(
      id: 'cls_022', day: now.day + 2 <= 28 ? now.day + 2 : now.day,
      hour: 10, minutes: 0, durationMin: 50,
      name: 'Estiramiento y Movilidad',
      cat: ClassCategory.stretching, maxPax: 20,
      booked: ['mem_002', 'mem_006', 'mem_008', 'mem_010', 'mem_012'],
      desc: 'Sesión de movilidad y estiramiento para mejorar la flexibilidad.',
    ),
  ];
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier() : super(ScheduleState(classes: _buildMockClasses()));

  /// Loads classes for a given gym and month (simulated).
  Future<void> loadClasses(String gymId, DateTime month) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false, clearError: true);
  }

  /// Adds a new class to the schedule.
  Future<void> addClass(GymClass gymClass) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      isLoading: false,
      classes: [...state.classes, gymClass],
    );
  }

  /// Updates an existing class.
  Future<void> updateClass(GymClass updated) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    final classes =
        state.classes.map((c) => c.id == updated.id ? updated : c).toList();
    state = state.copyWith(isLoading: false, classes: classes);
  }

  /// Marks a class as cancelled.
  Future<void> cancelClass(String classId, {String? reason}) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    final classes = state.classes
        .map((c) => c.id == classId
            ? c.copyWith(isCancelled: true, cancelReason: reason)
            : c)
        .toList();
    state = state.copyWith(isLoading: false, classes: classes);
  }

  /// Books a spot in a class for a member.
  Future<bool> bookClass(String classId, String memberId) async {
    final gymClass =
        state.classes.where((c) => c.id == classId).firstOrNull;
    if (gymClass == null || gymClass.isFull || gymClass.isCancelled) {
      return false;
    }
    if (gymClass.bookedMemberIds.contains(memberId)) return false;

    final updated = gymClass.copyWith(
      bookedMemberIds: [...gymClass.bookedMemberIds, memberId],
    );
    await updateClass(updated);
    return true;
  }

  /// Removes a member's booking from a class.
  Future<void> unBookClass(String classId, String memberId) async {
    final gymClass =
        state.classes.where((c) => c.id == classId).firstOrNull;
    if (gymClass == null) return;
    final updated = gymClass.copyWith(
      bookedMemberIds:
          gymClass.bookedMemberIds.where((id) => id != memberId).toList(),
    );
    await updateClass(updated);
  }

  /// Sets the currently selected date in the calendar view.
  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) => ScheduleNotifier(),
);

/// Returns classes scheduled for the currently selected date.
final classesForSelectedDateProvider = Provider<List<GymClass>>((ref) {
  final state = ref.watch(scheduleProvider);
  final selected = state.selectedDate;
  return state.classes.where((c) {
    final d = c.startTime;
    return d.year == selected.year &&
        d.month == selected.month &&
        d.day == selected.day &&
        !c.isCancelled;
  }).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
});

/// Returns non-cancelled classes starting within the next 7 days.
final upcomingClassesProvider = Provider<List<GymClass>>((ref) {
  final now = DateTime.now();
  final limit = now.add(const Duration(days: 7));
  return ref
      .watch(scheduleProvider)
      .classes
      .where((c) =>
          !c.isCancelled &&
          c.startTime.isAfter(now) &&
          c.startTime.isBefore(limit))
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
});
