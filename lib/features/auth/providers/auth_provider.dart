import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mercados/features/auth/models/user_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AuthState {
  final UserModel? currentUser;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => currentUser != null;

  AuthState copyWith({
    UserModel? currentUser,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() =>
      'AuthState(user: ${currentUser?.email}, isLoading: $isLoading, error: $error)';
}

// ---------------------------------------------------------------------------
// Demo users
// ---------------------------------------------------------------------------

class _DemoUser {
  final String email;
  final String password;
  final UserRole role;
  final String name;

  const _DemoUser({
    required this.email,
    required this.password,
    required this.role,
    required this.name,
  });
}

const _demoUsers = [
  _DemoUser(
    email: 'admin@demo.com',
    password: 'demo123',
    role: UserRole.admin,
    name: 'Admin Demo',
  ),
  _DemoUser(
    email: 'gerente@demo.com',
    password: 'demo123',
    role: UserRole.manager,
    name: 'Gerente Demo',
  ),
  _DemoUser(
    email: 'cajero@demo.com',
    password: 'demo123',
    role: UserRole.cashier,
    name: 'Cajero Demo',
  ),
  _DemoUser(
    email: 'cliente@demo.com',
    password: 'demo123',
    role: UserRole.customer,
    name: 'Cliente Demo',
  ),
];

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  SupabaseClient get _client => Supabase.instance.client;

  /// Returns true when Supabase is initialised and reachable.
  static bool _isSupabaseAvailable() {
    try {
      // Accessing the client throws if Supabase was never initialised or was
      // initialised with a placeholder URL.
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Session check ─────────────────────────────────────────────────────────

  /// Call this at app start to restore an existing session.
  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true, clearError: true);

    if (!_isSupabaseAvailable()) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        state = state.copyWith(isLoading: false, clearUser: true);
        return;
      }
      final user = await _fetchUserProfile(session.user.id);
      state = state.copyWith(currentUser: user, isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        error: 'Error al verificar la sesión: ${e.toString()}',
      );
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    if (!_isSupabaseAvailable()) {
      final normalised = email.trim().toLowerCase();
      final match = _demoUsers.where(
        (u) => u.email == normalised && u.password == password,
      );

      if (match.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Usuario demo no encontrado. Usa admin@demo.com / demo123',
        );
        return;
      }

      final demo = match.first;
      final demoUser = UserModel(
        id: 'demo-${demo.role.name}',
        name: demo.name,
        email: demo.email,
        role: demo.role,
        isActive: true,
        createdAt: DateTime(2024),
        lastLogin: DateTime.now(),
      );
      state = state.copyWith(currentUser: demoUser, isLoading: false);
      return;
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se pudo iniciar sesión. Verifica tus credenciales.',
        );
        return;
      }

      final user = await _fetchUserProfile(response.user!.id);
      if (!user.isActive) {
        await _client.auth.signOut();
        state = state.copyWith(
          isLoading: false,
          clearUser: true,
          error: 'Tu cuenta está desactivada. Contacta al administrador.',
        );
        return;
      }

      state = state.copyWith(currentUser: user, isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _mapAuthError(e.message),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error de conexión. Intenta de nuevo.',
      );
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    if (!_isSupabaseAvailable()) {
      state = const AuthState();
      return;
    }

    try {
      await _client.auth.signOut();
    } catch (_) {
      // Sign out locally even if the server call fails.
    } finally {
      state = const AuthState();
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Fetches the user profile. Checks employees first, then customers.
  Future<UserModel> _fetchUserProfile(String userId) async {
    final authUser = _client.auth.currentUser;
    final email = authUser?.email ?? '';

    // Check employees table first
    try {
      final data = await _client
          .from('employees')
          .select()
          .eq('auth_id', userId)
          .single();
      return UserModel(
        id: userId,
        name: data['name'] as String? ?? 'Usuario',
        email: data['email'] as String? ?? email,
        role: data['role'] != null
            ? UserRoleExtension.fromString(data['role'] as String)
            : UserRole.cashier,
        isActive: data['is_active'] as bool? ?? true,
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'] as String)
            : DateTime.now(),
        lastLogin: DateTime.now(),
      );
    } catch (_) {}

    // Check customers table
    try {
      final data = await _client
          .from('customers')
          .select()
          .eq('auth_id', userId)
          .single();
      return UserModel(
        id: userId,
        name: data['name'] as String? ?? email.split('@').first,
        email: data['email'] as String? ?? email,
        role: UserRole.customer,
        isActive: data['is_active'] as bool? ?? true,
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'] as String)
            : DateTime.now(),
        lastLogin: DateTime.now(),
      );
    } catch (_) {}

    // Fallback: treat as customer (self-registered)
    return UserModel(
      id: userId,
      name: authUser?.userMetadata?['name'] as String? ??
          email.split('@').first,
      email: email,
      role: UserRole.customer,
      isActive: true,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  String _mapAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials') ||
        m.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (m.contains('email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión.';
    }
    if (m.contains('too many requests')) {
      return 'Demasiados intentos. Espera un momento.';
    }
    if (m.contains('network')) {
      return 'Sin conexión a internet. Revisa tu red.';
    }
    return message;
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Main auth provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Convenience provider: current logged-in user (nullable).
final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authProvider).currentUser,
);

/// Convenience provider: whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isAuthenticated,
);
