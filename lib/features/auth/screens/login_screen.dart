import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/core/theme/app_theme.dart';
import 'package:mercados/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _logoController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
    // El router redirige automáticamente según el rol al detectar el cambio de estado
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= AppConstants.sidebarBreakpoint;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: isWide
            ? _buildDesktopLayout(authState, colorScheme, textTheme)
            : _buildMobileLayout(authState, colorScheme, textTheme),
      ),
    );
  }

  // ── Desktop: two-column layout ──────────────────────────────────────────

  Widget _buildDesktopLayout(
    AuthState authState,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        // Left hero panel
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00695C), Color(0xFF004D40)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: _buildLogo(onDark: true),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Gestiona tu\nsupermercado\ncon inteligencia.',
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appTagline,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildFeatureRow(
                    icon: Icons.point_of_sale_rounded,
                    label: 'Punto de venta rápido',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureRow(
                    icon: Icons.inventory_2_rounded,
                    label: 'Control de inventario en tiempo real',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureRow(
                    icon: Icons.bar_chart_rounded,
                    label: 'Reportes y análisis detallados',
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
        // Right form panel
        SizedBox(
          width: 460,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: _buildFormCard(authState, colorScheme, textTheme,
                  showLogo: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  // ── Mobile: single-column layout ────────────────────────────────────────

  Widget _buildMobileLayout(
    AuthState authState,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF00695C), Color(0xFF004D40)],
              ),
            ),
            child: FadeTransition(
              opacity: _logoFade,
              child: SlideTransition(
                position: _logoSlide,
                child: _buildLogo(onDark: true),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildFormCard(authState, colorScheme, textTheme,
                showLogo: false),
          ),
        ],
      ),
    );
  }

  // ── Logo ────────────────────────────────────────────────────────────────

  Widget _buildLogo({required bool onDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: onDark ? Colors.white : const Color(0xFF00695C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.store_rounded,
            size: 32,
            color: onDark ? const Color(0xFF00695C) : Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.appName.toUpperCase(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            color: onDark ? Colors.white : const Color(0xFF00695C),
          ),
        ),
        Text(
          'Sistema de Gestión',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: onDark
                ? Colors.white60
                : const Color(0xFF00695C).withAlpha(178),
          ),
        ),
      ],
    );
  }

  // ── Form card ───────────────────────────────────────────────────────────

  Widget _buildFormCard(
    AuthState authState,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required bool showLogo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLogo) ...[
          Center(child: _buildLogo(onDark: false)),
          const SizedBox(height: 40),
        ],
        Text(
          'Bienvenido de vuelta',
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Inicia sesión para continuar',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),

        // Error banner
        if (authState.error != null) ...[
          _ErrorBanner(message: authState.error!),
          const SizedBox(height: 20),
        ],

        Form(
          key: _formKey,
          child: Column(
            children: [
              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enabled: !authState.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'usuario@mercados.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu correo electrónico';
                  }
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !authState.isLoading,
                onFieldSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    tooltip: _obscurePassword
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, size: 20),
                            SizedBox(width: 10),
                            Text('Iniciar sesión'),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Demo mode button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: authState.isLoading
                ? null
                : () {
                    _emailController.text = 'admin@demo.com';
                    _passwordController.text = 'demo123';
                  },
            icon: const Icon(Icons.developer_mode, size: 18),
            label: const Text('Probar en modo demo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Register link for new customers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tienes cuenta?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppConstants.routeRegister),
              child: const Text('Crear cuenta de cliente'),
            ),
          ],
        ),

        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 12),

        // Footer
        Text(
          'v${AppConstants.appVersion}  •  ${AppConstants.appName}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant.withAlpha(128),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error banner widget
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
