import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';

import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/core/providers/gym_provider.dart';
import 'package:gym_app/core/providers/workout_provider.dart';
import 'package:gym_app/core/providers/members_provider.dart';

// ---------------------------------------------------------------------------
// Dashboard Screen
// ---------------------------------------------------------------------------

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final gymState = ref.watch(gymProvider);
    final workoutState = ref.watch(workoutProvider);
    final isLoading = gymState.isLoading;

    final firstName = user?.name.split(' ').first ?? 'Atleta';
    final gymName = gymState.currentGym?.name ?? 'FitPro Elite';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? _buildShimmerLoading()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(firstName, gymName),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Gap(8),
                      _buildStatsRow(),
                      const Gap(20),
                      _buildTodayWorkoutCard(workoutState),
                      const Gap(20),
                      _buildMacroProgressSection(),
                      const Gap(20),
                      _buildUpcomingClassesSection(context),
                      const Gap(20),
                      _buildRecentAchievements(),
                      const Gap(20),
                      _buildQuickActionsGrid(context),
                      const Gap(32),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sliver App Bar
  // ---------------------------------------------------------------------------

  Widget _buildSliverAppBar(String firstName, String gymName) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      expandedHeight: 120,
      floating: true,
      pinned: false,
      snap: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: Container(
                    color: AppColors.cardElevated,
                    child: const Icon(Icons.person,
                        color: AppColors.textSecondary, size: 30),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
              const Gap(12),
              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_getGreeting()}, $firstName 💪',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                    Text(
                      gymName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
              // Notification bell
              badges.Badge(
                badgeContent: Text(
                  '3',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: AppColors.error,
                  padding: EdgeInsets.all(4),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.textSecondary, size: 24),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stats Row
  // ---------------------------------------------------------------------------

  Widget _buildStatsRow() {
    final stats = [
      _StatCard(
        icon: FontAwesomeIcons.fire,
        iconColor: AppColors.primary,
        gradient: AppColors.primaryGradient,
        label: 'Racha',
        value: '12',
        unit: 'días',
        trend: '+2',
        trendPositive: true,
      ),
      _StatCard(
        icon: FontAwesomeIcons.dumbbell,
        iconColor: AppColors.secondary,
        gradient: AppColors.secondaryGradient,
        label: 'Entrenos',
        value: '48',
        unit: 'este mes',
        trend: '+5%',
        trendPositive: true,
      ),
      _StatCard(
        icon: FontAwesomeIcons.bolt,
        iconColor: AppColors.warning,
        gradient: AppColors.goldGradient,
        label: 'Calorías',
        value: '2,340',
        unit: 'hoy',
        trend: '+120',
        trendPositive: true,
      ),
      _StatCard(
        icon: FontAwesomeIcons.star,
        iconColor: AppColors.accent,
        gradient: AppColors.greenGradient,
        label: 'Puntos XP',
        value: '1,250',
        unit: 'puntos',
        trend: '+80',
        trendPositive: true,
      ),
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: stats.length,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (context, index) {
          return _buildStatCard(stats[index], index);
        },
      ),
    );
  }

  Widget _buildStatCard(_StatCard stat, int index) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Gradient accent bar at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: stat.gradient,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: stat.iconColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FaIcon(stat.icon,
                            color: stat.iconColor, size: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (stat.trendPositive
                                  ? AppColors.success
                                  : AppColors.error)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stat.trend,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: stat.trendPositive
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    stat.value,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    stat.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    stat.unit,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }

  // ---------------------------------------------------------------------------
  // Today's Workout Card
  // ---------------------------------------------------------------------------

  Widget _buildTodayWorkoutCard(WorkoutState workoutState) {
    final hasWorkout = workoutState.plans.isNotEmpty;
    final plan = hasWorkout ? workoutState.plans.first : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  FontAwesomeIcons.dumbbell,
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Entrenamiento de Hoy',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'HOY',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    hasWorkout
                        ? (plan?.name ?? 'Press + Hombros')
                        : 'Sin rutina programada',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (hasWorkout) ...[
                    const Gap(12),
                    Row(
                      children: [
                        _workoutInfoChip(
                          FontAwesomeIcons.layerGroup,
                          '${plan?.exercises.length ?? 5} ejercicios',
                        ),
                        const Gap(12),
                        _workoutInfoChip(
                          FontAwesomeIcons.clock,
                          '${plan?.estimatedMinutes ?? 60} min',
                        ),
                        const Gap(12),
                        _workoutInfoChip(
                          FontAwesomeIcons.fire,
                          '380 kcal',
                        ),
                      ],
                    ),
                    const Gap(16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Iniciar Entrenamiento',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Gap(16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Crear Rutina',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _workoutInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, color: Colors.white.withOpacity(0.8), size: 11),
        const Gap(4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Macro Progress Section
  // ---------------------------------------------------------------------------

  Widget _buildMacroProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Nutrición de Hoy', onTap: () {}),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              // Circular Progress Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCircularMacro(
                    label: 'Calorías',
                    current: 1840,
                    total: 2500,
                    unit: 'kcal',
                    color: AppColors.primary,
                  ),
                  _buildCircularMacro(
                    label: 'Proteína',
                    current: 120,
                    total: 150,
                    unit: 'g',
                    color: AppColors.secondary,
                  ),
                  _buildCircularMacro(
                    label: 'Carbos',
                    current: 200,
                    total: 300,
                    unit: 'g',
                    color: AppColors.accent,
                  ),
                  _buildCircularMacro(
                    label: 'Grasa',
                    current: 55,
                    total: 80,
                    unit: 'g',
                    color: AppColors.warning,
                  ),
                ],
              ),
              const Gap(16),
              // Water intake
              _buildWaterTracker(),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }

  Widget _buildCircularMacro({
    required String label,
    required int current,
    required int total,
    required String unit,
    required Color color,
  }) {
    final percent = (current / total).clamp(0.0, 1.0);
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 35,
          lineWidth: 5,
          percent: percent,
          backgroundColor: color.withOpacity(0.1),
          progressColor: color,
          circularStrokeCap: CircularStrokeCap.round,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$current',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const Gap(6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '/$total$unit',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterTracker() {
    const totalCups = 8;
    const filledCups = 6; // 1.8L out of 3L at ~250ml/cup

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.droplet,
              color: AppColors.accent, size: 16),
          const Gap(8),
          Text(
            'Agua',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(4),
          Text(
            '1.8L / 3L',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(totalCups, (index) {
              final isFilled = index < filledCups;
              return Padding(
                padding: const EdgeInsets.only(left: 2),
                child: FaIcon(
                  FontAwesomeIcons.droplet,
                  size: 14,
                  color: isFilled
                      ? AppColors.accent
                      : AppColors.textMuted.withOpacity(0.3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Upcoming Classes Section
  // ---------------------------------------------------------------------------

  Widget _buildUpcomingClassesSection(BuildContext context) {
    final classes = [
      _UpcomingClass(
        name: 'Yoga Flow',
        instructor: 'María García',
        time: '09:00 AM',
        spotsLeft: 5,
        color: AppColors.secondary,
        category: 'Yoga',
      ),
      _UpcomingClass(
        name: 'HIIT Blast',
        instructor: 'Carlos López',
        time: '11:30 AM',
        spotsLeft: 2,
        color: AppColors.primary,
        category: 'Cardio',
      ),
      _UpcomingClass(
        name: 'Spinning',
        instructor: 'Ana Torres',
        time: '06:00 PM',
        spotsLeft: 10,
        color: AppColors.accent,
        category: 'Cycling',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Próximas Clases', onTap: () {}, actionLabel: 'Ver todas'),
        const Gap(12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: classes.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (context, index) {
              final cls = classes[index];
              return _buildClassCard(cls, index);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _buildClassCard(_UpcomingClass cls, int index) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cls.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cls.color,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(6),
              Text(
                cls.category,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: cls.color,
                ),
              ),
            ],
          ),
          const Gap(6),
          Text(
            cls.name,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            cls.instructor,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 11, color: AppColors.textMuted),
                  const Gap(3),
                  Text(
                    cls.time,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (cls.spotsLeft <= 3
                          ? AppColors.warning
                          : AppColors.success)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cls.spotsLeft} lugares',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: cls.spotsLeft <= 3
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 80 * index)).fadeIn().slideX(begin: 0.2);
  }

  // ---------------------------------------------------------------------------
  // Recent Achievements
  // ---------------------------------------------------------------------------

  Widget _buildRecentAchievements() {
    final achievements = [
      _Achievement(
        icon: FontAwesomeIcons.fire,
        name: 'En Llamas',
        description: '10 días seguidos',
        color: AppColors.primary,
        date: 'Hace 2 días',
      ),
      _Achievement(
        icon: FontAwesomeIcons.trophy,
        name: 'Primer Mes',
        description: '30 días activo',
        color: AppColors.warning,
        date: 'Hace 5 días',
      ),
      _Achievement(
        icon: FontAwesomeIcons.bolt,
        name: 'Power User',
        description: '50 entrenamientos',
        color: AppColors.secondary,
        date: 'Hace 1 semana',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Últimos Logros', onTap: () {}),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            children: achievements.asMap().entries.map((entry) {
              final index = entry.key;
              final ach = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index < achievements.length - 1 ? 10 : 0),
                child: _buildAchievementRow(ach, index),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }

  Widget _buildAchievementRow(_Achievement ach, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ach.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ach.color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ach.color.withOpacity(0.15),
            ),
            child: Center(
              child: FaIcon(ach.icon, color: ach.color, size: 16),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ach.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  ach.description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            ach.date,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  // ---------------------------------------------------------------------------
  // Quick Actions Grid
  // ---------------------------------------------------------------------------

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: FontAwesomeIcons.qrcode,
        label: 'Check-in QR',
        color: AppColors.accent,
        gradient: AppColors.greenGradient,
        onTap: () {},
      ),
      _QuickAction(
        icon: FontAwesomeIcons.weightScale,
        label: 'Registrar Peso',
        color: AppColors.secondary,
        gradient: AppColors.secondaryGradient,
        onTap: () {},
      ),
      _QuickAction(
        icon: FontAwesomeIcons.utensils,
        label: 'Log Comida',
        color: AppColors.warning,
        gradient: AppColors.goldGradient,
        onTap: () {},
      ),
      _QuickAction(
        icon: FontAwesomeIcons.clockRotateLeft,
        label: 'Ver Historial',
        color: AppColors.primary,
        gradient: AppColors.primaryGradient,
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Acciones Rápidas', onTap: null),
        const Gap(12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: actions.asMap().entries.map((e) {
            final index = e.key;
            final action = e.value;
            return _buildQuickActionItem(action, index);
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 500.ms);
  }

  Widget _buildQuickActionItem(_QuickAction action, int index) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: action.color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: action.gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: action.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: FaIcon(action.icon, color: Colors.white, size: 16),
              ),
            ),
            const Gap(6),
            Text(
              action.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.85, 0.85));
  }

  // ---------------------------------------------------------------------------
  // Shimmer Loading
  // ---------------------------------------------------------------------------

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.cardElevated,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(60),
            _shimmerBox(height: 60, borderRadius: 12),
            const Gap(20),
            Row(
              children: List.generate(
                  4,
                  (_) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _shimmerBox(height: 120, borderRadius: 16),
                        ),
                      )),
            ),
            const Gap(20),
            _shimmerBox(height: 160, borderRadius: 20),
            const Gap(20),
            _shimmerBox(height: 180, borderRadius: 16),
            const Gap(20),
            _shimmerBox(height: 120, borderRadius: 16),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double height, required double borderRadius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section Header Helper
  // ---------------------------------------------------------------------------

  Widget _sectionHeader(
    String title, {
    VoidCallback? onTap,
    String? actionLabel,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionLabel ?? 'Ver más',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data models (local)
// ---------------------------------------------------------------------------

class _StatCard {
  final IconData icon;
  final Color iconColor;
  final LinearGradient gradient;
  final String label;
  final String value;
  final String unit;
  final String trend;
  final bool trendPositive;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.gradient,
    required this.label,
    required this.value,
    required this.unit,
    required this.trend,
    required this.trendPositive,
  });
}

class _UpcomingClass {
  final String name;
  final String instructor;
  final String time;
  final int spotsLeft;
  final Color color;
  final String category;

  const _UpcomingClass({
    required this.name,
    required this.instructor,
    required this.time,
    required this.spotsLeft,
    required this.color,
    required this.category,
  });
}

class _Achievement {
  final IconData icon;
  final String name;
  final String description;
  final Color color;
  final String date;

  const _Achievement({
    required this.icon,
    required this.name,
    required this.description,
    required this.color,
    required this.date,
  });
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onTap,
  });
}
