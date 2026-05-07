import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/core/providers/gym_provider.dart';
import 'package:gym_app/core/providers/workout_provider.dart';
import 'package:gym_app/core/models/achievement_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final gym = ref.watch(currentGymProvider);
    final workouts = ref.watch(workoutProvider);

    if (user == null) return const SizedBox();

    final xpProgress = (user.xpPoints % 2000) / 2000.0;
    final xpToNext = 2000 - (user.xpPoints % 2000);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white24,
                    child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32)),
                  ),
                  Column(children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => context.push('/profile/edit')),
                    IconButton(icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => context.push('/settings')),
                  ]),
                ]),
                const Gap(12),
                Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                const Gap(4),
                Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                  child: Text('⚡ Nivel ${user.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const Gap(16),
                // XP bar
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Nivel ${user.level} → Nivel ${user.level + 1}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('${user.xpPoints % 2000} / 2000 XP',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  ]),
                  const Gap(6),
                  LinearProgressIndicator(
                    value: xpProgress, backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 8, borderRadius: BorderRadius.circular(4),
                  ),
                  const Gap(4),
                  Text('$xpToNext XP para el siguiente nivel', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                ]),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats grid
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    _StatCard(icon: '🏃', label: 'Check-ins', value: '142').animate().fadeIn(delay: 50.ms),
                    const Gap(8),
                    _StatCard(icon: '💪', label: 'Entrenos', value: '${workouts.sessionHistory.length}').animate().fadeIn(delay: 100.ms),
                    const Gap(8),
                    _StatCard(icon: '🔥', label: 'Racha', value: '12d').animate().fadeIn(delay: 150.ms),
                    const Gap(8),
                    _StatCard(icon: '⭐', label: 'Puntos', value: '${user.xpPoints}').animate().fadeIn(delay: 200.ms),
                  ]),
                ),

                // Membership card
                if (gym != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.secondaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(gym.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Plan Pro', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                        const Gap(8),
                        const Text('Miembro desde: Enero 2024', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const Gap(4),
                        const Text('Válido hasta: 31 Dic 2024', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const Gap(12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          ElevatedButton(
                            onPressed: () => context.push('/qr-checkin'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, foregroundColor: AppColors.secondary,
                              minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('Ver QR', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                          const Text('Vence en 45 días', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ]),
                      ]),
                    ).animate().fadeIn(delay: 200.ms),
                  ),

                const Gap(16),

                // Weekly activity chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Actividad Semanal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    const Gap(12),
                    SizedBox(
                      height: 120,
                      child: BarChart(BarChartData(
                        barGroups: List.generate(7, (i) => BarChartGroupData(
                          x: i,
                          barRods: [BarChartRodData(
                            toY: [0.4, 1.0, 0, 0.8, 1.0, 0.6, 0].map((v) => v * 60).toList()[i],
                            color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4),
                          )],
                        )),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text(['L','M','X','J','V','S','D'][v.toInt()],
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          )),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                      )),
                    ),
                  ]),
                ),

                const Gap(16),

                // Achievements preview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Logros Recientes', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    TextButton(onPressed: () => context.push('/achievements'), child: const Text('Ver todos')),
                  ]),
                ),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: Achievement.allAchievements()
                        .where((a) => a.unlocked).take(5).map((a) =>
                      Container(
                        width: 72, margin: const EdgeInsets.only(right: 12),
                        child: Column(children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: _tierColor(a.tier).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _tierColor(a.tier).withOpacity(0.5)),
                            ),
                            child: Center(child: Text(a.icon, style: const TextStyle(fontSize: 24))),
                          ),
                          const Gap(4),
                          Text(a.title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    ).toList(),
                  ),
                ),

                const Gap(16),

                // Menu options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    _MenuTile(icon: Icons.history, label: 'Historial de Pagos', onTap: () {}),
                    _MenuTile(icon: Icons.document_scanner, label: 'Mis Documentos', onTap: () {}),
                    _MenuTile(icon: Icons.share, label: 'Compartir Perfil', onTap: () {}),
                    _MenuTile(icon: Icons.help_outline, label: 'Centro de Ayuda', onTap: () {}),
                    _MenuTile(icon: Icons.settings, label: 'Configuración', onTap: () => context.push('/settings')),
                  ]),
                ),

                const Gap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton.icon(
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
                const Gap(80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _tierColor(AchievementTier t) => switch(t) {
    AchievementTier.bronze => AppColors.bronzeTier,
    AchievementTier.silver => AppColors.silverTier,
    AchievementTier.gold => AppColors.goldTier,
    AchievementTier.platinum => AppColors.platinumTier,
    AchievementTier.legendary => AppColors.primary,
  };
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
  const _StatCard({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const Gap(4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ]),
    ),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: AppColors.textSecondary, size: 18),
    ),
    title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
    onTap: onTap,
  );
}
