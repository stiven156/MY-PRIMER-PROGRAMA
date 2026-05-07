import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/workout_provider.dart';
import 'package:gym_app/core/models/workout_model.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            title: const Text('Entrenamiento',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 24)),
            actions: [
              IconButton(
                icon: const Icon(Icons.fitness_center,
                    color: AppColors.textSecondary),
                onPressed: () => context.push('/workout/library'),
              ),
              IconButton(
                icon: const Icon(Icons.history, color: AppColors.textSecondary),
                onPressed: () => context.push('/workout/history'),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Mis Rutinas'),
                Tab(text: 'Explorar'),
                Tab(text: 'Historial'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _MyRoutinesTab(),
            _ExploreTab(),
            _HistoryTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/workout/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Crear Plan',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MY ROUTINES TAB
// ─────────────────────────────────────────────
class _MyRoutinesTab extends ConsumerWidget {
  const _MyRoutinesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick start card
        _QuickStartCard(),
        const Gap(20),

        if (state.isLoading)
          ...List.generate(3, (_) => _WorkoutPlanCardSkeleton())
        else if (state.plans.isEmpty)
          _EmptyPlansState()
        else ...[
          Text('Mis Planes (${state.plans.length})',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          const Gap(12),
          ...state.plans.asMap().entries.map((e) =>
              _WorkoutPlanCard(plan: e.value, index: e.key)
                  .animate(delay: (e.key * 80).ms)
                  .fadeIn()
                  .slideX(begin: 0.1)),
        ],
      ],
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Entrenamiento Rápido',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const Gap(6),
                const Text('Selecciona músculos y empieza',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
                const Gap(16),
                ElevatedButton(
                  onPressed: () => context.push('/workout/active'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Empezar ⚡',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const FaIcon(FontAwesomeIcons.dumbbell,
              color: Colors.white54, size: 60),
        ],
      ),
    );
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final int index;

  const _WorkoutPlanCard({required this.plan, required this.index});

  Color get _goalColor {
    switch (plan.goal) {
      case WorkoutGoal.strength:
        return AppColors.primary;
      case WorkoutGoal.weightLoss:
        return AppColors.success;
      case WorkoutGoal.muscleMass:
        return AppColors.secondary;
      case WorkoutGoal.endurance:
        return AppColors.accent;
      default:
        return AppColors.warning;
    }
  }

  String get _goalLabel {
    switch (plan.goal) {
      case WorkoutGoal.strength:
        return 'Fuerza';
      case WorkoutGoal.weightLoss:
        return 'Pérdida de peso';
      case WorkoutGoal.muscleMass:
        return 'Masa muscular';
      case WorkoutGoal.endurance:
        return 'Resistencia';
      default:
        return 'Fitness General';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDays = plan.days.where((d) => !d.isRestDay).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _goalColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(FontAwesomeIcons.dumbbell,
                color: _goalColor, size: 20),
          ),
          title: Text(plan.name,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          subtitle: Row(
            children: [
              _PillBadge(label: _goalLabel, color: _goalColor),
              const Gap(6),
              _PillBadge(
                  label: '${plan.durationWeeks}sem',
                  color: AppColors.textMuted),
              const Gap(6),
              _PillBadge(
                  label: '$activeDays días/sem',
                  color: AppColors.textMuted),
            ],
          ),
          children: [
            ...plan.days.map((day) => _DayRow(day: day, plan: plan)),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final WorkoutDay day;
  final WorkoutPlan plan;
  const _DayRow({required this.day, required this.plan});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: day.isRestDay
          ? null
          : () => context.push('/workout/active',
              extra: {'plan': plan, 'day': day}),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: day.isRestDay
                    ? AppColors.textMuted.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                day.isRestDay ? Icons.hotel : Icons.fitness_center,
                color:
                    day.isRestDay ? AppColors.textMuted : AppColors.primary,
                size: 16,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.name,
                      style: TextStyle(
                          color: day.isRestDay
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  if (!day.isRestDay)
                    Text(
                        '${day.exercises.length} ejercicios',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            if (!day.isRestDay)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Iniciar',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutPlanCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
        color: AppColors.cardElevated, duration: 1200.ms);
  }
}

class _EmptyPlansState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Gap(40),
          const FaIcon(FontAwesomeIcons.clipboardList,
              color: AppColors.textMuted, size: 60),
          const Gap(16),
          const Text('Sin planes de entrenamiento',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          const Gap(8),
          const Text('Crea tu primer plan personalizado',
              style: TextStyle(color: AppColors.textSecondary)),
          const Gap(20),
          ElevatedButton(
            onPressed: () => context.push('/workout/create'),
            child: const Text('Crear Plan'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EXPLORE TAB
// ─────────────────────────────────────────────
class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  static const List<_TemplatePlan> _templates = [
    _TemplatePlan('Push / Pull / Legs', '6 días', 'Intermedio',
        FontAwesomeIcons.dumbbell, AppColors.primary, 'Fuerza + Masa'),
    _TemplatePlan('Full Body 3x', '3 días', 'Principiante',
        FontAwesomeIcons.personRunning, AppColors.success, 'Fitness General'),
    _TemplatePlan('Arnold Split', '6 días', 'Avanzado',
        FontAwesomeIcons.trophy, AppColors.warning, 'Masa Muscular'),
    _TemplatePlan('HIIT Cardio', '4 días', 'Todos los niveles',
        FontAwesomeIcons.fire, AppColors.error, 'Quemar grasa'),
    _TemplatePlan('Calistenia Total', '5 días', 'Intermedio',
        FontAwesomeIcons.handFist, AppColors.secondary, 'Fuerza funcional'),
    _TemplatePlan('Stronglifts 5×5', '3 días', 'Principiante',
        FontAwesomeIcons.weightHanging, AppColors.accent, 'Fuerza'),
    _TemplatePlan('CrossFit WOD', '5 días', 'Avanzado',
        FontAwesomeIcons.bolt, AppColors.warning, 'Rendimiento'),
    _TemplatePlan('Yoga & Movilidad', '7 días', 'Principiante',
        FontAwesomeIcons.spa, AppColors.success, 'Flexibilidad'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: _templates.length,
      itemBuilder: (context, i) => _TemplateCard(template: _templates[i])
          .animate(delay: (i * 60).ms)
          .fadeIn()
          .scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

class _TemplatePlan {
  final String name;
  final String days;
  final String level;
  final IconData icon;
  final Color color;
  final String goal;
  const _TemplatePlan(
      this.name, this.days, this.level, this.icon, this.color, this.goal);
}

class _TemplateCard extends StatelessWidget {
  final _TemplatePlan template;
  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  template.color.withOpacity(0.3),
                  template.color.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
                child: FaIcon(template.icon,
                    color: template.color, size: 36)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                    maxLines: 2),
                const Gap(4),
                Text(template.goal,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const Gap(8),
                Row(
                  children: [
                    _PillBadge(label: template.days, color: template.color),
                    const Gap(4),
                  ],
                ),
                const Gap(8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: template.color,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Usar Plan',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HISTORY TAB
// ─────────────────────────────────────────────
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutProvider);
    final sessions = state.sessionHistory;

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.clockRotateLeft,
                color: AppColors.textMuted, size: 52),
            const Gap(16),
            const Text('Sin historial aún',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
            const Gap(8),
            const Text('Completa tu primer entrenamiento',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const Gap(8),
      itemBuilder: (context, i) {
        final s = sessions[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center,
                    color: AppColors.primary, size: 22),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        s.workoutPlanId != null
                            ? 'Entrenamiento'
                            : 'Sesión libre',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    Text(
                        '${s.exercises.length} ejercicios · '
                        '${(s.totalVolume).toStringAsFixed(0)} kg',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      s.endTime != null
                          ? '${s.endTime!.difference(s.startTime).inMinutes} min'
                          : '-',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  Text(
                      '${s.startTime.day}/${s.startTime.month}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────
class _PillBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PillBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
