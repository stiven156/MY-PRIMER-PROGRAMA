import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/workout_provider.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutProvider);
    final sessions = state.sessionHistory;
    final prs = state.personalRecords;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Historial', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(tabs: [Tab(text: 'Sesiones'), Tab(text: 'Récords (PR)')]),
            Expanded(
              child: TabBarView(
                children: [
                  _SessionsTab(sessions: sessions),
                  _PRsTab(prs: prs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  final List<dynamic> sessions;
  const _SessionsTab({required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.history, color: AppColors.textMuted, size: 64),
          Gap(16),
          Text('Sin sesiones aún', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          Gap(8),
          Text('Completa tu primer entrenamiento', style: TextStyle(color: AppColors.textSecondary)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const Gap(8),
      itemBuilder: (context, i) {
        final s = sessions[i];
        final dur = s.endTime != null ? s.endTime!.difference(s.startTime).inMinutes : 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 22)),
            const Gap(12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${s.exercises.length} ejercicios', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              Text('${s.totalVolume.toStringAsFixed(0)} kg · $dur min',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${s.startTime.day}/${s.startTime.month}/${s.startTime.year}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              if (s.completed)
                const Text('✓ Completado', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ]),
        );
      },
    );
  }
}

class _PRsTab extends StatelessWidget {
  final List<dynamic> prs;
  const _PRsTab({required this.prs});

  @override
  Widget build(BuildContext context) {
    if (prs.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.emoji_events, color: AppColors.textMuted, size: 64),
          Gap(16),
          Text('Sin récords aún', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          Gap(8),
          Text('Completa entrenamientos para establecer PRs', style: TextStyle(color: AppColors.textSecondary, textAlign: TextAlign.center)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: prs.length,
      separatorBuilder: (_, __) => const Gap(8),
      itemBuilder: (context, i) {
        final pr = prs[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.goldTier.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 28)),
            const Gap(12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pr.exerciseName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              Text('${pr.date.day}/${pr.date.month}/${pr.date.year}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (pr.weight != null)
                Text('${pr.weight!.toStringAsFixed(1)} kg',
                    style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w800, fontSize: 18)),
              if (pr.reps != null)
                Text('${pr.reps} reps', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ]),
          ]),
        );
      },
    );
  }
}
