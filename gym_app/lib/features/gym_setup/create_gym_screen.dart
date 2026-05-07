import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/models/gym_model.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/core/providers/gym_provider.dart';
import 'package:gym_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Amenity data
// ---------------------------------------------------------------------------

class _AmenityOption {
  const _AmenityOption({
    required this.name,
    required this.icon,
  });
  final String name;
  final IconData icon;
}

const _amenityOptions = [
  _AmenityOption(name: 'Estacionamiento', icon: Icons.local_parking),
  _AmenityOption(name: 'Piscina', icon: Icons.pool),
  _AmenityOption(name: 'Sauna', icon: Icons.hot_tub),
  _AmenityOption(name: 'WiFi', icon: Icons.wifi),
  _AmenityOption(name: 'Cafetería', icon: Icons.coffee),
  _AmenityOption(name: 'Vestuarios', icon: Icons.checkroom),
  _AmenityOption(name: 'Tienda', icon: Icons.shopping_bag_outlined),
  _AmenityOption(name: 'Taquillas', icon: Icons.lock_outline),
  _AmenityOption(name: 'TV', icon: Icons.tv),
  _AmenityOption(name: 'Duchas', icon: Icons.shower),
  _AmenityOption(name: 'Solario', icon: Icons.wb_sunny_outlined),
  _AmenityOption(name: 'Zona Cardio', icon: Icons.directions_run),
];

const _gymCategories = [
  'Musculación',
  'CrossFit',
  'Yoga',
  'Funcional',
  'Artes Marciales',
  'Natación',
  'Mixto',
];

const _weekdays = [
  ('monday', 'L'),
  ('tuesday', 'M'),
  ('wednesday', 'X'),
  ('thursday', 'J'),
  ('friday', 'V'),
  ('saturday', 'S'),
  ('sunday', 'D'),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CreateGymScreen extends ConsumerStatefulWidget {
  const CreateGymScreen({super.key});

  @override
  ConsumerState<CreateGymScreen> createState() => _CreateGymScreenState();
}

class _CreateGymScreenState extends ConsumerState<CreateGymScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  static const int _totalSteps = 4;

  late AnimationController _successController;
  bool _showSuccess = false;

  // Step 1 - Basic info
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Musculación';

  // Step 2 - Location & Contact
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();

  // Step 3 - Schedule & Amenities
  Map<String, bool> _workingDays = {
    'monday': true,
    'tuesday': true,
    'wednesday': true,
    'thursday': true,
    'friday': true,
    'saturday': true,
    'sunday': false,
  };
  TimeOfDay _openTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 22, minute: 0);
  final Set<String> _selectedAmenities = {};

  // Step 4 - Plan
  GymPlan _selectedPlan = GymPlan.pro;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentStep == 0 && !(_step1Key.currentState?.validate() ?? false)) {
      return;
    }
    if (_currentStep == 1 && !(_step2Key.currentState?.validate() ?? false)) {
      return;
    }
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _createGym() async {
    final authState = ref.read(authProvider);
    final userId = authState.user?.id ?? 'unknown';

    final gym = GymModel(
      id: 'gym_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      instagram: _instagramController.text.trim().isEmpty
          ? null
          : _instagramController.text.trim(),
      openTime:
          '${_openTime.hour.toString().padLeft(2, '0')}:${_openTime.minute.toString().padLeft(2, '0')}',
      closeTime:
          '${_closeTime.hour.toString().padLeft(2, '0')}:${_closeTime.minute.toString().padLeft(2, '0')}',
      ownerId: userId,
      plan: _selectedPlan,
      amenities: _selectedAmenities.toList(),
      workingDays: _workingDays,
      maxMembers: _selectedPlan.planMaxMembers,
      createdAt: DateTime.now(),
    );

    await ref.read(gymProvider.notifier).createGym(gym);

    if (!mounted) return;

    final gymState = ref.read(gymProvider);
    if (gymState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(gymState.error!,
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show success animation
    setState(() => _showSuccess = true);
    _successController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    context.go('/home/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(gymProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.12),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(),

                // Step indicator
                _StepIndicator(
                  current: _currentStep,
                  total: _totalSteps,
                ),

                const Gap(24),

                // Step content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        )),
                        child: FadeTransition(opacity: anim, child: child),
                      );
                    },
                    child: _buildStepContent(),
                  ),
                ),

                // Navigation buttons
                _buildNavButtons(isLoading),
                const Gap(24),
              ],
            ),
          ),

          // Success overlay
          if (_showSuccess) _SuccessOverlay(controller: _successController),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    const stepTitles = [
      'Información Básica',
      'Ubicación y Contacto',
      'Horarios y Amenidades',
      'Plan y Finalizar',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (_currentStep > 0)
            GestureDetector(
              onTap: _goBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: AppColors.textSecondary, size: 16),
              ),
            )
          else
            const SizedBox(width: 40),
          const Spacer(),
          Column(
            children: [
              Text(
                stepTitles[_currentStep],
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Paso ${_currentStep + 1} de $_totalSteps',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _Step1BasicInfo(
          key: const ValueKey(0),
          formKey: _step1Key,
          nameController: _nameController,
          descriptionController: _descriptionController,
          selectedCategory: _selectedCategory,
          onCategoryChanged: (cat) =>
              setState(() => _selectedCategory = cat),
        );
      case 1:
        return _Step2LocationContact(
          key: const ValueKey(1),
          formKey: _step2Key,
          addressController: _addressController,
          cityController: _cityController,
          countryController: _countryController,
          phoneController: _phoneController,
          emailController: _emailController,
          websiteController: _websiteController,
          instagramController: _instagramController,
        );
      case 2:
        return _Step3ScheduleAmenities(
          key: const ValueKey(2),
          workingDays: _workingDays,
          openTime: _openTime,
          closeTime: _closeTime,
          selectedAmenities: _selectedAmenities,
          onDayToggled: (day, val) {
            setState(() => _workingDays[day] = val);
          },
          onOpenTimeChanged: (t) => setState(() => _openTime = t),
          onCloseTimeChanged: (t) => setState(() => _closeTime = t),
          onAmenityToggled: (name) {
            setState(() {
              if (_selectedAmenities.contains(name)) {
                _selectedAmenities.remove(name);
              } else {
                _selectedAmenities.add(name);
              }
            });
          },
        );
      case 3:
        return _Step4Plan(
          key: const ValueKey(3),
          selectedPlan: _selectedPlan,
          onPlanChanged: (plan) => setState(() => _selectedPlan = plan),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavButtons(bool isLoading) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: isLoading ? null : (isLastStep ? _createGym : _goNext),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 1,
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
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLastStep ? 'Crear mi Gimnasio' : 'Siguiente',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLastStep
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step Indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: List.generate(total * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < current;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 2,
                color: isCompleted ? AppColors.primary : AppColors.border,
              ),
            );
          } else {
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < current;
            final isCurrent = stepIndex == current;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primary
                    : isCurrent
                        ? AppColors.card
                        : AppColors.surface,
                border: Border.all(
                  color: isCompleted || isCurrent
                      ? AppColors.primary
                      : AppColors.border,
                  width: isCurrent ? 2 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '${stepIndex + 1}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
              ),
            );
          }
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 - Basic Info
// ---------------------------------------------------------------------------

class _Step1BasicInfo extends StatelessWidget {
  const _Step1BasicInfo({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo placeholder
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined,
                          color: AppColors.textMuted, size: 32),
                      const Gap(4),
                      Text(
                        'Subir Logo',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.elasticOut),

            const Gap(28),

            _FieldLabel('Nombre del gimnasio *'),
            const Gap(8),
            _StyledField(
              controller: nameController,
              hint: 'FitPro Elite Gym',
              icon: Icons.fitness_center,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

            const Gap(20),

            _FieldLabel('Descripción (opcional)'),
            const Gap(8),
            _StyledField(
              controller: descriptionController,
              hint:
                  'Describe tu gimnasio, su filosofía y lo que lo hace especial...',
              icon: Icons.description_outlined,
              maxLines: 4,
            ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

            const Gap(24),

            _FieldLabel('Categoría principal'),
            const Gap(12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _gymCategories.map((cat) {
                final isSelected = cat == selectedCategory;
                return GestureDetector(
                  onTap: () => onCategoryChanged(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

            const Gap(32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 - Location & Contact
// ---------------------------------------------------------------------------

class _Step2LocationContact extends StatelessWidget {
  const _Step2LocationContact({
    super.key,
    required this.formKey,
    required this.addressController,
    required this.cityController,
    required this.countryController,
    required this.phoneController,
    required this.emailController,
    required this.websiteController,
    required this.instagramController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController websiteController;
  final TextEditingController instagramController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(icon: Icons.location_on_outlined, title: 'Ubicación'),
            const Gap(16),

            _FieldLabel('Dirección *'),
            const Gap(8),
            _StyledField(
              controller: addressController,
              hint: '1234 Fitness Ave, Suite 100',
              icon: Icons.map_outlined,
              validator: (val) => val?.trim().isEmpty == true
                  ? 'La dirección es obligatoria'
                  : null,
            ).animate(delay: 50.ms).fadeIn(duration: 400.ms),

            const Gap(16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Ciudad *'),
                      const Gap(8),
                      _StyledField(
                        controller: cityController,
                        hint: 'Miami',
                        icon: Icons.location_city_outlined,
                        validator: (val) => val?.trim().isEmpty == true
                            ? 'Requerido'
                            : null,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('País *'),
                      const Gap(8),
                      _StyledField(
                        controller: countryController,
                        hint: 'USA',
                        icon: Icons.flag_outlined,
                        validator: (val) => val?.trim().isEmpty == true
                            ? 'Requerido'
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

            const Gap(24),

            _SectionHeader(icon: Icons.contact_phone_outlined, title: 'Contacto'),
            const Gap(16),

            _FieldLabel('Teléfono *'),
            const Gap(8),
            _StyledField(
              controller: phoneController,
              hint: '+1 305-555-0100',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (val) =>
                  val?.trim().isEmpty == true ? 'Requerido' : null,
            ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

            const Gap(16),

            _FieldLabel('Email *'),
            const Gap(8),
            _StyledField(
              controller: emailController,
              hint: 'info@migym.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val?.trim().isEmpty == true) return 'Requerido';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                    .hasMatch(val!.trim())) {
                  return 'Email inválido';
                }
                return null;
              },
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

            const Gap(16),

            _FieldLabel('Sitio web (opcional)'),
            const Gap(8),
            _StyledField(
              controller: websiteController,
              hint: 'https://migym.com',
              icon: Icons.language_outlined,
              keyboardType: TextInputType.url,
            ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

            const Gap(16),

            _FieldLabel('Instagram (opcional)'),
            const Gap(8),
            _StyledField(
              controller: instagramController,
              hint: '@migym',
              icon: Icons.camera_alt_outlined,
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

            const Gap(32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 - Schedule & Amenities
// ---------------------------------------------------------------------------

class _Step3ScheduleAmenities extends StatelessWidget {
  const _Step3ScheduleAmenities({
    super.key,
    required this.workingDays,
    required this.openTime,
    required this.closeTime,
    required this.selectedAmenities,
    required this.onDayToggled,
    required this.onOpenTimeChanged,
    required this.onCloseTimeChanged,
    required this.onAmenityToggled,
  });

  final Map<String, bool> workingDays;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final Set<String> selectedAmenities;
  final void Function(String day, bool val) onDayToggled;
  final ValueChanged<TimeOfDay> onOpenTimeChanged;
  final ValueChanged<TimeOfDay> onCloseTimeChanged;
  final ValueChanged<String> onAmenityToggled;

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.schedule_outlined, title: 'Días de apertura'),
          const Gap(16),

          // Weekday toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekdays.map((entry) {
              final key = entry.$1;
              final label = entry.$2;
              final isOpen = workingDays[key] ?? false;

              return GestureDetector(
                onTap: () => onDayToggled(key, !isOpen),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isOpen
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOpen ? AppColors.primary : AppColors.border,
                      width: isOpen ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isOpen
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate(delay: 50.ms).fadeIn(duration: 400.ms),

          const Gap(24),

          _SectionHeader(icon: Icons.access_time_outlined, title: 'Horario'),
          const Gap(16),

          Row(
            children: [
              Expanded(
                child: _TimePickerCard(
                  label: 'Apertura',
                  time: _formatTime(openTime),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: openTime,
                    );
                    if (picked != null) onOpenTimeChanged(picked);
                  },
                ),
              ),
              const Gap(12),
              Expanded(
                child: _TimePickerCard(
                  label: 'Cierre',
                  time: _formatTime(closeTime),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: closeTime,
                    );
                    if (picked != null) onCloseTimeChanged(picked);
                  },
                ),
              ),
            ],
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          const Gap(28),

          _SectionHeader(icon: Icons.star_outline, title: 'Amenidades'),
          const Gap(4),
          Text(
            'Selecciona los servicios que ofreces',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const Gap(16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: _amenityOptions.length,
            itemBuilder: (context, index) {
              final option = _amenityOptions[index];
              final isSelected = selectedAmenities.contains(option.name);

              return GestureDetector(
                onTap: () => onAmenityToggled(option.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withOpacity(0.12)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        option.icon,
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textMuted,
                        size: 26,
                      ),
                      const Gap(6),
                      Text(
                        option.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: 30 * index))
                  .fadeIn(duration: 300.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  );
            },
          ),

          const Gap(32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4 - Plan
// ---------------------------------------------------------------------------

class _Step4Plan extends StatelessWidget {
  const _Step4Plan({
    super.key,
    required this.selectedPlan,
    required this.onPlanChanged,
  });

  final GymPlan selectedPlan;
  final ValueChanged<GymPlan> onPlanChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              icon: Icons.workspace_premium_outlined,
              title: 'Elige tu plan'),
          const Gap(8),
          Text(
            'Puedes cambiar tu plan en cualquier momento',
            style:
                GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const Gap(20),

          _PlanCard(
            plan: GymPlan.basic,
            title: 'Básico',
            price: '\$29',
            features: const [
              'Hasta 50 miembros',
              '1 administrador',
              'Gestión básica',
              'Soporte por email',
            ],
            color: AppColors.success,
            isSelected: selectedPlan == GymPlan.basic,
            onTap: () => onPlanChanged(GymPlan.basic),
          ).animate(delay: 50.ms).fadeIn(duration: 400.ms).slideY(
                begin: 0.1,
                end: 0,
                duration: 400.ms,
              ),

          const Gap(12),

          _PlanCard(
            plan: GymPlan.pro,
            title: 'Pro',
            price: '\$79',
            features: const [
              'Hasta 500 miembros',
              '5 administradores',
              'Analytics avanzado',
              'Soporte prioritario',
            ],
            color: AppColors.secondary,
            isSelected: selectedPlan == GymPlan.pro,
            onTap: () => onPlanChanged(GymPlan.pro),
            isMostPopular: true,
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(
                begin: 0.1,
                end: 0,
                duration: 400.ms,
              ),

          const Gap(12),

          _PlanCard(
            plan: GymPlan.enterprise,
            title: 'Enterprise',
            price: '\$199',
            features: const [
              'Miembros ilimitados',
              'Admins ilimitados',
              'API & White-label',
              'Manager dedicado',
            ],
            color: AppColors.accent,
            isSelected: selectedPlan == GymPlan.enterprise,
            onTap: () => onPlanChanged(GymPlan.enterprise),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(
                begin: 0.1,
                end: 0,
                duration: 400.ms,
              ),

          const Gap(32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan Card
// ---------------------------------------------------------------------------

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.title,
    required this.price,
    required this.features,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.isMostPopular = false,
  });

  final GymPlan plan;
  final String title;
  final String price;
  final List<String> features;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMostPopular;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.rajdhani(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? color : AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isMostPopular) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Popular',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Gap(8),
                  ...features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: isSelected ? color : AppColors.textMuted,
                          ),
                          const Gap(6),
                          Text(
                            f,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isSelected
                                  ? AppColors.textSecondary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: GoogleFonts.rajdhani(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? color : AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '/mes',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Success Overlay
// ---------------------------------------------------------------------------

class _SuccessOverlay extends StatelessWidget {
  const _SuccessOverlay({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.85 * controller.value),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withOpacity(0.15),
                    border: Border.all(
                      color: AppColors.success,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 52),
                )
                    .animate(controller: controller)
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const Gap(24),
                Text(
                  '¡Gimnasio creado!',
                  style: GoogleFonts.rajdhani(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                )
                    .animate(controller: controller)
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 300.ms,
                        duration: 400.ms),
                const Gap(8),
                Text(
                  'Preparando tu panel de control...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                )
                    .animate(controller: controller)
                    .fadeIn(delay: 500.ms, duration: 400.ms),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Time Picker Card
// ---------------------------------------------------------------------------

class _TimePickerCard extends StatelessWidget {
  const _TimePickerCard({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.textMuted, size: 18),
            const Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const Gap(10),
        Text(
          title,
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.inputFill,
        prefixIcon: maxLines == 1
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(icon, color: AppColors.textMuted, size: 20),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
