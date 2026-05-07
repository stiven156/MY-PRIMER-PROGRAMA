import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/core/models/gym_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class GymState {
  final GymModel? currentGym;
  final List<GymModel> userGyms;
  final bool isLoading;
  final String? error;

  const GymState({
    this.currentGym,
    this.userGyms = const [],
    this.isLoading = false,
    this.error,
  });

  GymState copyWith({
    GymModel? currentGym,
    List<GymModel>? userGyms,
    bool? isLoading,
    String? error,
    bool clearCurrentGym = false,
    bool clearError = false,
  }) {
    return GymState(
      currentGym:
          clearCurrentGym ? null : (currentGym ?? this.currentGym),
      userGyms: userGyms ?? this.userGyms,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockGyms = <GymModel>[
  GymModel(
    id: 'gym_mock_001',
    name: 'FitPro Elite Gym',
    address: '1234 Fitness Ave, Suite 100',
    city: 'Miami',
    country: 'USA',
    phone: '+1 305-555-0100',
    email: 'info@fitproelite.com',
    logoUrl: 'https://picsum.photos/seed/gym1/200',
    website: 'https://fitproelite.com',
    instagram: '@fitproelite',
    openTime: '06:00',
    closeTime: '23:00',
    ownerId: 'user_admin_001',
    primaryColor: '#FF6B35',
    secondaryColor: '#1A1A2E',
    plan: GymPlan.pro,
    membersCount: 248,
    maxMembers: 500,
    amenities: [
      'Estacionamiento',
      'Vestuarios',
      'Duchas',
      'Taquillas',
      'WiFi',
      'TV',
      'Zona Cardio',
      'Pesas Libres',
      'Máquinas',
      'Zona Funcional',
      'Spinning',
      'Sauna',
    ],
    isActive: true,
    createdAt: DateTime(2023, 1, 10),
    description:
        'State-of-the-art fitness facility with world-class equipment and professional trainers. '
        'Your journey to a healthier life starts here.',
    workingDays: {
      'monday': true,
      'tuesday': true,
      'wednesday': true,
      'thursday': true,
      'friday': true,
      'saturday': true,
      'sunday': false,
    },
  ),
  GymModel(
    id: 'gym_mock_002',
    name: 'PowerHouse Training Center',
    address: '789 Muscle Street',
    city: 'Los Angeles',
    country: 'USA',
    phone: '+1 310-555-0200',
    email: 'contact@powerhousetc.com',
    logoUrl: 'https://picsum.photos/seed/gym2/200',
    website: 'https://powerhousetc.com',
    instagram: '@powerhousetc',
    openTime: '05:30',
    closeTime: '22:00',
    ownerId: 'user_admin_001',
    primaryColor: '#2196F3',
    secondaryColor: '#0D0D0D',
    plan: GymPlan.enterprise,
    membersCount: 610,
    maxMembers: 1000,
    amenities: [
      'Estacionamiento',
      'Piscina',
      'Sauna',
      'Vestuarios',
      'Cafetería',
      'Tienda',
      'WiFi',
      'TV',
      'Duchas',
      'Taquillas',
      'Zona Cardio',
      'Pesas Libres',
      'Máquinas',
      'Zona Funcional',
      'Crossfit Box',
      'Yoga Studio',
    ],
    isActive: true,
    createdAt: DateTime(2022, 6, 20),
    description:
        'Los Angeles premier strength and conditioning facility. '
        'Home to competitive athletes and everyday warriors alike.',
    workingDays: {
      'monday': true,
      'tuesday': true,
      'wednesday': true,
      'thursday': true,
      'friday': true,
      'saturday': true,
      'sunday': true,
    },
  ),
];

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class GymNotifier extends StateNotifier<GymState> {
  GymNotifier()
      : super(GymState(
          userGyms: _mockGyms,
          currentGym: _mockGyms.first,
        ));

  /// Loads a gym by id and sets it as the current gym.
  Future<void> loadGym(String gymId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 400));

    final gym = state.userGyms.where((g) => g.id == gymId).firstOrNull;
    if (gym == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gimnasio no encontrado.',
      );
      return;
    }
    state = state.copyWith(isLoading: false, currentGym: gym, clearError: true);
  }

  /// Adds a new gym to the list and sets it as current.
  Future<void> createGym(GymModel gym) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isLoading: false,
      userGyms: [...state.userGyms, gym],
      currentGym: gym,
      clearError: true,
    );
  }

  /// Replaces an existing gym with updated data.
  Future<void> updateGym(GymModel updated) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 400));
    final gyms = state.userGyms
        .map((g) => g.id == updated.id ? updated : g)
        .toList();
    state = state.copyWith(
      isLoading: false,
      userGyms: gyms,
      currentGym: state.currentGym?.id == updated.id
          ? updated
          : state.currentGym,
      clearError: true,
    );
  }

  /// Removes a gym from the list.
  Future<void> deleteGym(String gymId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 400));
    final gyms = state.userGyms.where((g) => g.id != gymId).toList();
    state = state.copyWith(
      isLoading: false,
      userGyms: gyms,
      currentGym:
          state.currentGym?.id == gymId ? gyms.firstOrNull : state.currentGym,
      clearError: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final gymProvider = StateNotifierProvider<GymNotifier, GymState>(
  (ref) => GymNotifier(),
);

/// Convenient access to the currently selected [GymModel].
final currentGymProvider = Provider<GymModel?>(
  (ref) => ref.watch(gymProvider).currentGym,
);
