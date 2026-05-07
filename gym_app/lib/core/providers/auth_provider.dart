import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/core/models/user_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final String? currentGymId;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.currentGymId,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    String? currentGymId,
    bool clearUser = false,
    bool clearError = false,
    bool clearGymId = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentGymId: clearGymId ? null : (currentGymId ?? this.currentGymId),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock users database
// ---------------------------------------------------------------------------

final _mockUsers = <Map<String, dynamic>>[
  {
    'email': 'admin@fitpro.com',
    'password': 'admin123',
    'user': UserModel(
      id: 'user_admin_001',
      email: 'admin@fitpro.com',
      name: 'Carlos Rodríguez',
      photoUrl: 'https://i.pravatar.cc/300?img=33',
      gymId: 'gym_mock_001',
      role: UserRole.gymAdmin,
      createdAt: DateTime(2023, 8, 1),
      xpPoints: 5000,
      level: 10,
      phoneNumber: '+1 555-9999',
      birthDate: DateTime(1985, 3, 10),
      gender: 'Male',
      bio: 'Gym owner and certified personal trainer with 15 years experience.',
    ),
  },
  {
    'email': 'trainer@fitpro.com',
    'password': 'trainer123',
    'user': UserModel(
      id: 'user_trainer_001',
      email: 'trainer@fitpro.com',
      name: 'María García',
      photoUrl: 'https://i.pravatar.cc/300?img=47',
      gymId: 'gym_mock_001',
      role: UserRole.trainer,
      createdAt: DateTime(2024, 1, 15),
      xpPoints: 2500,
      level: 5,
      phoneNumber: '+1 555-7777',
      birthDate: DateTime(1990, 7, 22),
      gender: 'Female',
      bio: 'Certified fitness coach specializing in strength and conditioning.',
    ),
  },
  {
    'email': 'member@fitpro.com',
    'password': 'member123',
    'user': UserModel(
      id: 'user_member_001',
      email: 'member@fitpro.com',
      name: 'Juan López',
      photoUrl: 'https://i.pravatar.cc/300?img=12',
      gymId: 'gym_mock_001',
      role: UserRole.member,
      createdAt: DateTime(2024, 3, 1),
      xpPoints: 750,
      level: 2,
      phoneNumber: '+1 555-4444',
      birthDate: DateTime(1995, 11, 5),
      gender: 'Male',
      bio: 'Fitness enthusiast working towards a healthier lifestyle.',
    ),
  },
];

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // Registered users during this session (starts with mock users)
  final List<Map<String, dynamic>> _users = List.from(_mockUsers);

  /// Attempts login against the mock users list.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 800));

    final match = _users.where(
      (u) =>
          u['email'] == email.trim().toLowerCase() &&
          u['password'] == password,
    );

    if (match.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Credenciales incorrectas. Verifica tu email y contraseña.',
      );
      return;
    }

    final user = match.first['user'] as UserModel;
    state = state.copyWith(
      isLoading: false,
      user: user,
      currentGymId: user.gymId,
      clearError: true,
    );
  }

  /// Registers a new user and logs them in.
  Future<void> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 800));

    final emailNormalized = email.trim().toLowerCase();
    final exists = _users.any((u) => u['email'] == emailNormalized);
    if (exists) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ya existe una cuenta con ese email.',
      );
      return;
    }

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: emailNormalized,
      name: name.trim(),
      role: role,
      createdAt: DateTime.now(),
    );

    _users.add({
      'email': emailNormalized,
      'password': password,
      'user': newUser,
    });

    state = state.copyWith(
      isLoading: false,
      user: newUser,
      currentGymId: newUser.gymId,
      clearError: true,
    );
  }

  /// Clears the current session.
  void logout() {
    state = const AuthState();
  }

  /// Replaces the current user with updated data.
  void updateUser(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser);

    // Also update the mock store so re-login returns fresh data.
    final idx = _users.indexWhere((u) => u['email'] == updatedUser.email);
    if (idx != -1) {
      _users[idx] = {..._users[idx], 'user': updatedUser};
    }
  }

  /// Sets the active gym context.
  void selectGym(String gymId) {
    state = state.copyWith(currentGymId: gymId);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Returns the currently logged-in [UserModel], or `null` if not authenticated.
final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authProvider).user,
);

/// Returns `true` when a user is authenticated.
final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).user != null,
);
