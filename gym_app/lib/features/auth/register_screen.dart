import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/models/user_model.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/core/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  UserRole _selectedRole = UserRole.gymAdmin;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debes aceptar los términos y condiciones',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _selectedRole,
        );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  authState.error!,
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (authState.user != null) {
      if (_selectedRole == UserRole.gymAdmin) {
        context.go('/create-gym');
      } else {
        context.go('/home/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -120,
            left: -80,
            child: _GlowBlob(
              color: AppColors.secondary.withOpacity(0.15),
              size: 340,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: _GlowBlob(
              color: AppColors.primary.withOpacity(0.12),
              size: 300,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _BackButton(onTap: () => context.go('/login')),
                      const Spacer(),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(8),

                          // Header
                          _buildHeader()
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .slideY(
                                begin: -0.2,
                                end: 0,
                                duration: 500.ms,
                              ),

                          const Gap(32),

                          // Role selector
                          _buildSectionTitle('¿Cuál es tu rol?'),
                          const Gap(12),
                          _RoleSelector(
                            selected: _selectedRole,
                            onChanged: (role) =>
                                setState(() => _selectedRole = role),
                          )
                              .animate(delay: 100.ms)
                              .fadeIn(duration: 500.ms),

                          const Gap(28),

                          // Full Name
                          _buildSectionTitle('Nombre completo'),
                          const Gap(8),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'Carlos Rodríguez',
                            icon: Icons.person_outline,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Ingresa tu nombre completo';
                              }
                              if (val.trim().length < 3) {
                                return 'Nombre muy corto';
                              }
                              return null;
                            },
                          )
                              .animate(delay: 150.ms)
                              .fadeIn(duration: 500.ms)
                              .slideX(begin: -0.08, end: 0, duration: 400.ms),

                          const Gap(20),

                          // Email
                          _buildSectionTitle('Correo electrónico'),
                          const Gap(8),
                          _buildTextField(
                            controller: _emailController,
                            hint: 'tu@email.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Ingresa tu correo electrónico';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(val.trim())) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                          )
                              .animate(delay: 200.ms)
                              .fadeIn(duration: 500.ms)
                              .slideX(begin: -0.08, end: 0, duration: 400.ms),

                          const Gap(20),

                          // Password
                          _buildSectionTitle('Contraseña'),
                          const Gap(8),
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'Mínimo 8 caracteres',
                            icon: Icons.lock_outline,
                            obscure: _obscurePassword,
                            onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Ingresa una contraseña';
                              }
                              if (val.length < 8) {
                                return 'La contraseña debe tener al menos 8 caracteres';
                              }
                              return null;
                            },
                          )
                              .animate(delay: 250.ms)
                              .fadeIn(duration: 500.ms)
                              .slideX(begin: -0.08, end: 0, duration: 400.ms),

                          const Gap(20),

                          // Confirm Password
                          _buildSectionTitle('Confirmar contraseña'),
                          const Gap(8),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hint: 'Repite tu contraseña',
                            icon: Icons.lock_outline,
                            obscure: _obscureConfirm,
                            onToggleObscure: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Confirma tu contraseña';
                              }
                              if (val != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          )
                              .animate(delay: 300.ms)
                              .fadeIn(duration: 500.ms)
                              .slideX(begin: -0.08, end: 0, duration: 400.ms),

                          const Gap(20),

                          // Phone (optional)
                          _buildSectionTitle('Teléfono (opcional)'),
                          const Gap(8),
                          _buildTextField(
                            controller: _phoneController,
                            hint: '+1 555-0000',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          )
                              .animate(delay: 350.ms)
                              .fadeIn(duration: 500.ms)
                              .slideX(begin: -0.08, end: 0, duration: 400.ms),

                          const Gap(28),

                          // Terms and conditions
                          _TermsCheckbox(
                            accepted: _acceptedTerms,
                            onChanged: (val) =>
                                setState(() => _acceptedTerms = val ?? false),
                          ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

                          const Gap(32),

                          // Create Account button
                          _GradientButton(
                            label: 'Crear Cuenta',
                            isLoading: isLoading,
                            onTap: _handleRegister,
                          )
                              .animate(delay: 450.ms)
                              .fadeIn(duration: 500.ms)
                              .slideY(begin: 0.2, end: 0, duration: 400.ms),

                          const Gap(28),

                          // Already have account
                          Center(
                            child: GestureDetector(
                              onTap: () => context.go('/login'),
                              child: RichText(
                                text: TextSpan(
                                  text: '¿Ya tienes cuenta? ',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Inicia sesión',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate(delay: 500.ms).fadeIn(duration: 500.ms),

                          const Gap(40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crear Cuenta',
          style: GoogleFonts.rajdhani(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.1,
            letterSpacing: 0.5,
          ),
        ),
        const Gap(8),
        Text(
          'Únete a la plataforma de gestión\nfitness más avanzada',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.inputFill,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(icon, color: AppColors.textMuted, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
        suffixIcon: onToggleObscure != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle:
            GoogleFonts.inter(color: AppColors.error, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Role Selector
// ---------------------------------------------------------------------------

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            role: UserRole.gymAdmin,
            selected: selected == UserRole.gymAdmin,
            title: 'Soy dueño /\nadmin de gimnasio',
            icon: Icons.admin_panel_settings_outlined,
            color: AppColors.primary,
            onTap: () => onChanged(UserRole.gymAdmin),
          ),
        ),
        const Gap(12),
        Expanded(
          child: _RoleCard(
            role: UserRole.member,
            selected: selected == UserRole.member,
            title: 'Soy miembro\ndel gimnasio',
            icon: Icons.fitness_center,
            color: AppColors.secondary,
            onTap: () => onChanged(UserRole.member),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final UserRole role;
  final bool selected;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(0.2) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? color : AppColors.textMuted,
                size: 22,
              ),
            ),
            const Gap(12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const Gap(8),
            if (selected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Terms Checkbox
// ---------------------------------------------------------------------------

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.accepted,
    required this.onChanged,
  });

  final bool accepted;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: accepted,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!accepted),
            child: RichText(
              text: TextSpan(
                text: 'Acepto los ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Términos y Condiciones',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      height: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: ' y la ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Política de Privacidad',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Gradient Button
// ---------------------------------------------------------------------------

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: isLoading
              ? LinearGradient(colors: [
                  AppColors.secondary.withOpacity(0.5),
                  AppColors.accent.withOpacity(0.3),
                ])
              : AppColors.secondaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Back Button
// ---------------------------------------------------------------------------

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.textSecondary,
          size: 18,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glow Blob
// ---------------------------------------------------------------------------

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
