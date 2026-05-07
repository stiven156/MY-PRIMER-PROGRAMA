import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/core/models/body_measurement_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class BodyTrackingState {
  final List<BodyMeasurement> measurements;
  final bool isLoading;
  final String? error;

  const BodyTrackingState({
    this.measurements = const [],
    this.isLoading = false,
    this.error,
  });

  BodyTrackingState copyWith({
    List<BodyMeasurement>? measurements,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BodyTrackingState(
      measurements: measurements ?? this.measurements,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock data — 6 months of measurements
// ---------------------------------------------------------------------------

List<BodyMeasurement> _buildMockMeasurements(String memberId) {
  final now = DateTime.now();
  // One measurement roughly every 2.5 weeks going back 6 months (~10 entries)
  final entries = <BodyMeasurement>[];

  final weights = [
    98.0, 96.5, 95.0, 93.2, 91.8, 90.5, 89.0, 87.5, 86.0, 85.0
  ];
  final bodyFats = [
    24.0, 23.5, 23.0, 22.3, 21.8, 21.0, 20.5, 19.8, 19.2, 18.5
  ];
  final muscleMasses = [
    72.0, 72.5, 73.0, 73.2, 73.8, 74.0, 74.5, 75.0, 75.5, 76.0
  ];
  final waists = [
    92.0, 91.0, 90.0, 89.0, 88.0, 87.0, 86.5, 85.5, 84.5, 83.5
  ];
  final chests = [
    103.0, 103.5, 104.0, 104.0, 104.5, 105.0, 105.5, 106.0, 106.5, 107.0
  ];
  final arms = [
    38.0, 38.5, 38.5, 39.0, 39.5, 39.5, 40.0, 40.5, 40.5, 41.0
  ];
  final hips = [
    102.0, 101.5, 101.0, 100.5, 100.0, 99.5, 99.0, 98.5, 98.0, 97.5
  ];
  final thighs = [
    62.0, 61.5, 61.0, 60.5, 60.0, 59.5, 59.0, 58.5, 58.0, 57.5
  ];
  final shoulders = [
    122.0, 122.5, 123.0, 123.5, 124.0, 124.5, 125.0, 125.5, 126.0, 126.5
  ];

  for (int i = 0; i < 10; i++) {
    final date = now.subtract(Duration(days: (9 - i) * 18));
    entries.add(BodyMeasurement(
      id: 'bm_${memberId}_$i',
      memberId: memberId,
      date: date,
      weight: weights[i],
      bodyFat: bodyFats[i],
      muscleMass: muscleMasses[i],
      waist: waists[i],
      chest: chests[i],
      arms: arms[i],
      hips: hips[i],
      thighs: thighs[i],
      shoulders: shoulders[i],
      notes: i == 0
          ? 'Medición inicial al comenzar el programa.'
          : i == 9
              ? 'Excelente progreso en 6 meses!'
              : null,
    ));
  }

  return entries;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class BodyTrackingNotifier extends StateNotifier<BodyTrackingState> {
  BodyTrackingNotifier() : super(const BodyTrackingState());

  /// Loads measurements for a member (simulated).
  Future<void> loadMeasurements(String memberId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isLoading: false,
      measurements: _buildMockMeasurements(memberId),
      clearError: true,
    );
  }

  /// Adds a new body measurement.
  Future<void> addMeasurement(BodyMeasurement measurement) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    final sorted = [...state.measurements, measurement]
      ..sort((a, b) => a.date.compareTo(b.date));
    state = state.copyWith(isLoading: false, measurements: sorted);
  }

  /// Updates an existing measurement by id.
  Future<void> updateMeasurement(BodyMeasurement updated) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    final measurements = state.measurements
        .map((m) => m.id == updated.id ? updated : m)
        .toList();
    state = state.copyWith(isLoading: false, measurements: measurements);
  }

  /// Deletes a measurement by id.
  Future<void> deleteMeasurement(String id) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    final measurements =
        state.measurements.where((m) => m.id != id).toList();
    state = state.copyWith(isLoading: false, measurements: measurements);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final bodyTrackingProvider =
    StateNotifierProvider<BodyTrackingNotifier, BodyTrackingState>(
  (ref) => BodyTrackingNotifier(),
);

/// Returns the most recent measurement, or `null` if the list is empty.
final latestMeasurementProvider = Provider<BodyMeasurement?>((ref) {
  final measurements = ref.watch(bodyTrackingProvider).measurements;
  if (measurements.isEmpty) return null;
  return measurements.last;
});

/// Returns a [List<FlSpot>] where x = measurement index and y = weight in kg.
/// Suitable for passing directly to an fl_chart LineChartBarData.
final weightHistoryProvider = Provider<List<FlSpot>>((ref) {
  final measurements = ref.watch(bodyTrackingProvider).measurements;
  return measurements.asMap().entries.map((entry) {
    return FlSpot(entry.key.toDouble(), entry.value.weight);
  }).toList();
});
