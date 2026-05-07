import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/schedule_provider.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/core/models/gym_class_model.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});
  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleProvider);
    final user = ref.watch(currentUserProvider);
    final isAdmin = user?.role == UserRole.gymAdmin || user?.role == UserRole.superAdmin || user?.role == UserRole.trainer;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: const Text('Clases', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
            actions: [
              if (isAdmin)
                IconButton(icon: const Icon(Icons.add, color: AppColors.primary),
                    onPressed: () => context.push('/schedule/add-class')),
            ],
            bottom: TabBar(controller: _tabCtrl,
                tabs: const [Tab(text: 'Calendario'), Tab(text: 'Mis Clases')]),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _CalendarTab(state: state),
            _MyClassesTab(state: state),
          ],
        ),
      ),
    );
  }
}

class _CalendarTab extends ConsumerWidget {
  final ScheduleState state;
  const _CalendarTab({required this.state});

  Color _categoryColor(ClassCategory cat) {
    switch (cat) {
      case ClassCategory.yoga: return AppColors.secondary;
      case ClassCategory.spinning: return AppColors.primary;
      case ClassCategory.crossfit: return AppColors.error;
      case ClassCategory.hiit: return AppColors.warning;
      case ClassCategory.pilates: return AppColors.success;
      case ClassCategory.boxing: return AppColors.chest;
      case ClassCategory.zumba: return AppColors.accent;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayClasses = ref.watch(classesForSelectedDateProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Calendar
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 90)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: state.selectedDate,
          selectedDayPredicate: (d) => isSameDay(d, state.selectedDate),
          onDaySelected: (sel, _) => ref.read(scheduleProvider.notifier).selectDate(sel),
          calendarFormat: CalendarFormat.week,
          calendarStyle: const CalendarStyle(
            defaultTextStyle: TextStyle(color: AppColors.textPrimary),
            weekendTextStyle: TextStyle(color: AppColors.textSecondary),
            selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            todayTextStyle: TextStyle(color: Colors.white),
            selectedTextStyle: TextStyle(color: Colors.white),
            outsideTextStyle: TextStyle(color: AppColors.textMuted),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
            leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textSecondary),
            rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
          eventLoader: (day) => state.classes.where((c) => isSameDay(c.startTime, day)).toList(),
        ),
        const Gap(8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            todayClasses.isEmpty ? 'Sin clases este día' : '${todayClasses.length} clases',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        const Gap(8),
        if (todayClasses.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Column(children: [
              Text('📅', style: TextStyle(fontSize: 48)),
              Gap(12),
              Text('Sin clases programadas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
              Gap(4),
              Text('Selecciona otro día o crea una clase', style: TextStyle(color: AppColors.textSecondary)),
            ])),
          )
        else
          ...todayClasses.asMap().entries.map((e) =>
              _ClassCard(gymClass: e.value, color: _categoryColor(e.value.category))
                  .animate(delay: (e.key * 60).ms).fadeIn().slideX(begin: 0.05)),
        const Gap(16),
      ],
    );
  }
}

class _ClassCard extends ConsumerWidget {
  final GymClass gymClass; final Color color;
  const _ClassCard({required this.gymClass, required this.color});

  String get _catName => switch(gymClass.category) {
    ClassCategory.yoga => 'Yoga', ClassCategory.spinning => 'Spinning',
    ClassCategory.crossfit => 'CrossFit', ClassCategory.hiit => 'HIIT',
    ClassCategory.pilates => 'Pilates', ClassCategory.boxing => 'Boxeo',
    ClassCategory.zumba => 'Zumba', ClassCategory.aerobics => 'Aeróbics',
    ClassCategory.bodyPump => 'Body Pump', ClassCategory.calisthenics => 'Calistenia',
    ClassCategory.dance => 'Baile', ClassCategory.stretching => 'Estiramiento',
    ClassCategory.kickboxing => 'Kickboxing', ClassCategory.trx => 'TRX',
    ClassCategory.swimming => 'Natación',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isEnrolled = user != null && gymClass.enrolledMemberIds.contains(user.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${gymClass.startTime.hour.toString().padLeft(2,'0')}:${gymClass.startTime.minute.toString().padLeft(2,'0')}',
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
            Text('${gymClass.durationMinutes}min', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
          const Gap(12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(gymClass.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
            const Gap(4),
            Row(children: [
              const Icon(Icons.person_outline, color: AppColors.textMuted, size: 14),
              const Gap(4),
              Text(gymClass.instructorName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Gap(8),
              const Icon(Icons.room, color: AppColors.textMuted, size: 14),
              const Gap(4),
              Text(gymClass.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
            const Gap(6),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(_catName, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const Gap(6),
              Text('${gymClass.enrolledMemberIds.length}/${gymClass.maxCapacity}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Gap(6),
              if (gymClass.calorieBurn != null)
                Text('🔥 ${gymClass.calorieBurn} kcal', style: const TextStyle(color: AppColors.warning, fontSize: 11)),
            ]),
          ])),
          const Gap(8),
          gymClass.isFull && !isEnrolled
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Llena', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)))
              : ElevatedButton(
                  onPressed: () {
                    if (user == null) return;
                    if (isEnrolled) {
                      ref.read(scheduleProvider.notifier).unBookClass(gymClass.id, user.id);
                    } else {
                      ref.read(scheduleProvider.notifier).bookClass(gymClass.id, user.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnrolled ? AppColors.card : AppColors.primary,
                    foregroundColor: isEnrolled ? AppColors.error : Colors.white,
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    side: isEnrolled ? const BorderSide(color: AppColors.error) : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isEnrolled ? 'Cancelar' : 'Reservar', style: const TextStyle(fontSize: 12)),
                ),
        ]),
      ),
    );
  }
}

class _MyClassesTab extends ConsumerWidget {
  final ScheduleState state;
  const _MyClassesTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final upcoming = state.classes.where((c) =>
        user != null && c.enrolledMemberIds.contains(user.id) &&
        c.startTime.isAfter(DateTime.now())).toList();

    if (upcoming.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('📅', style: TextStyle(fontSize: 52)),
        Gap(16),
        Text('Sin clases reservadas', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        Gap(8),
        Text('Ve al calendario y reserva tus clases', style: TextStyle(color: AppColors.textSecondary, textAlign: TextAlign.center)),
      ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: upcoming.length,
      separatorBuilder: (_, __) => const Gap(8),
      itemBuilder: (context, i) => _ClassCard(gymClass: upcoming[i], color: AppColors.success),
    );
  }
}
