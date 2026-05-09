import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mercados/core/constants/app_constants.dart';

// ---------------------------------------------------------------------------
// RegisterScreen – customer self-registration
// ---------------------------------------------------------------------------

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // UI state
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Registration logic ───────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool supabaseAvailable = false;
      try { Supabase.instance.client; supabaseAvailable = true; } catch (_) {}

      if (!supabaseAvailable) {
        // Demo mode: show success message and go to client app
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada en modo demo. Conecta Supabase para persistir datos.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppConstants.routeClientApp);
        return;
      }

      final supabase = Supabase.instance.client;
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {'full_name': _nameCtrl.text.trim(), 'role': 'customer'},
      );

      if (response.user == null) {
        setState(() { _isLoading = false; _errorMessage = 'No se pudo crear la cuenta. Inténtalo de nuevo.'; });
        return;
      }

      final userId = response.user!.id;
      await supabase.from('customers').insert({
        'auth_id': userId,
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'role': 'customer',
        'is_active': true,
        'points': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      context.go(AppConstants.routeClientApp);
    } on AuthException catch (e) {
      setState(() { _isLoading = false; _errorMessage = _mapAuthError(e.message); });
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = 'Error: ${e.toString()}'; });
    }
  }

  String _mapAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('already registered') || m.contains('already exists')) {
      return 'Este correo ya está registrado. Inicia sesión.';
    }
    if (m.contains('invalid email')) {
      return 'El correo ingresado no es válido.';
    }
    if (m.contains('password')) {
      return 'La contraseña no cumple con los requisitos mínimos.';
    }
    if (m.contains('network') || m.contains('connection')) {
      return 'Sin conexión a internet. Revisa tu red.';
    }
    return message;
  }

  // ── Validators ───────────────────────────────────────────────────────────

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'El nombre es requerido';
    if (v.trim().length < 3) return 'Ingresa tu nombre completo';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'El teléfono es requerido';
    if (v.trim().length < 7) return 'Ingresa un número válido';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'El correo es requerido';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Ingresa un correo válido';
    return null;
  }

  String? _validateAddress(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'La dirección es requerida para entregas';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña es requerida';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Confirma tu contraseña';
    if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Top bar with back button ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppConstants.routeLogin);
                        }
                      },
                      tooltip: 'Volver',
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // ── Logo ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00695C),
                            Color(0xFF004D40),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00695C).withAlpha(77),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'MERCADOS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: Color(0xFF00695C),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form card ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crear cuenta',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Empieza a pedir desde casa',
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error banner
                    if (_errorMessage != null) ...[
                      _ErrorBanner(message: _errorMessage!),
                      const SizedBox(height: 20),
                    ],

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full name
                          TextFormField(
                            controller: _nameCtrl,
                            enabled: !_isLoading,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo',
                              hintText: 'Juan Pérez',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: _validateName,
                          ),
                          const SizedBox(height: 14),

                          // Phone
                          TextFormField(
                            controller: _phoneCtrl,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              hintText: '0999123456',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: _validatePhone,
                          ),
                          const SizedBox(height: 14),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              hintText: 'tu@correo.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),

                          // Address
                          TextFormField(
                            controller: _addressCtrl,
                            enabled: !_isLoading,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Dirección de entrega',
                              hintText:
                                  'Calle, número, barrio, referencia...',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: _validateAddress,
                          ),
                          const SizedBox(height: 14),

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            enabled: !_isLoading,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Mínimo 6 caracteres',
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                tooltip: _obscurePassword
                                    ? 'Mostrar contraseña'
                                    : 'Ocultar contraseña',
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 14),

                          // Confirm password
                          TextFormField(
                            controller: _confirmPassCtrl,
                            enabled: !_isLoading,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleRegister(),
                            decoration: InputDecoration(
                              labelText: 'Confirmar contraseña',
                              hintText: 'Repite tu contraseña',
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                tooltip: _obscureConfirm
                                    ? 'Mostrar contraseña'
                                    : 'Ocultar contraseña',
                              ),
                            ),
                            validator: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 28),

                          // Register button
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF00695C),
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            Icons.person_add_rounded,
                                            size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          'Registrarse',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Already have account
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => context.go(AppConstants.routeLogin),
                            child: const Text(
                              'Inicia sesión',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00695C),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF00695C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Terms note
                    Text(
                      'Al registrarte, aceptas nuestros Términos de Servicio '
                      'y Política de Privacidad.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant.withAlpha(153),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error banner
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: cs.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: cs.onErrorContainer,
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
