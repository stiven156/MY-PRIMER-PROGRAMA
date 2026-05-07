import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/models/achievement_model.dart';
import 'package:gym_app/core/providers/social_provider.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});
  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  AchievementCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final allAchievements = Achievement.allAchievements();
    final filtered = _filter == null
        ? allAchievements
        : allAchievements.where((a) => a.category == _filter).toList();
    final unlocked = allAchievements.where((a) => a.unlocked).length;
    final totalXp = allAchievements.where((a) => a.unlocked).fold(0, (s, a) => s + a.xpReward);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Logros', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // XP progress
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              CircularPercentIndicator(
                radius: 40, lineWidth: 8,
                percent: unlocked / allAchievements.length,
                backgroundColor: Colors.white30,
                progressColor: Colors.white,
                center: Text('$unlocked', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              const Gap(16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$unlocked / ${allAchievements.length} Logros', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const Gap(4),
                Text('$totalXp XP ganados', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const Gap(8),
                LinearProgressIndicator(
                  value: unlocked / allAchievements.length,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 6, borderRadius: BorderRadius.circular(3),
                ),
              ])),
            ]),
          ),

          // Category filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _Cat(label: 'Todos', selected: _filter == null, color: AppColors.primary,
                    onTap: () => setState(() => _filter = null)),
                _Cat(label: '🏃 Asistencia', selected: _filter == AchievementCategory.attendance,
                    color: AppColors.success, onTap: () => setState(() => _filter = AchievementCategory.attendance)),
                _Cat(label: '💪 Entreno', selected: _filter == AchievementCategory.workout,
                    color: AppColors.primary, onTap: () => setState(() => _filter = AchievementCategory.workout)),
                _Cat(label: '🥗 Nutrición', selected: _filter == AchievementCategory.nutrition,
                    color: AppColors.success, onTap: () => setState(() => _filter = AchievementCategory.nutrition)),
                _Cat(label: '📏 Medidas', selected: _filter == AchievementCategory.measurements,
                    color: AppColors.accent, onTap: () => setState(() => _filter = AchievementCategory.measurements)),
                _Cat(label: '🌟 Social', selected: _filter == AchievementCategory.social,
                    color: AppColors.secondary, onTap: () => setState(() => _filter = AchievementCategory.social)),
                _Cat(label: '⭐ Especial', selected: _filter == AchievementCategory.special,
                    color: AppColors.warning, onTap: () => setState(() => _filter = AchievementCategory.special)),
              ],
            ),
          ),
          const Gap(8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('${filtered.where((a) => a.unlocked).length} desbloqueados · ${filtered.length - filtered.where((a) => a.unlocked).length} por desbloquear',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          const Gap(8),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final a = filtered[i];
                return _AchCard(achievement: a)
                    .animate(delay: (i * 30).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Cat extends StatelessWidget {
  final String label; final bool selected; final Color color; final VoidCallback onTap;
  const _Cat({required this.label, required this.selected, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.2) : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? color : AppColors.border),
      ),
      child: Text(label, style: TextStyle(color: selected ? color : AppColors.textSecondary, fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
    ),
  );
}

class _AchCard extends StatelessWidget {
  final Achievement achievement;
  const _AchCard({required this.achievement});

  Color get _tierColor => switch(achievement.tier) {
    AchievementTier.bronze => AppColors.bronzeTier,
    AchievementTier.silver => AppColors.silverTier,
    AchievementTier.gold => AppColors.goldTier,
    AchievementTier.platinum => AppColors.platinumTier,
    AchievementTier.legendary => AppColors.primary,
  };

  String get _tierLabel => switch(achievement.tier) {
    AchievementTier.bronze => 'Bronce',
    AchievementTier.silver => 'Plata',
    AchievementTier.gold => 'Oro',
    AchievementTier.platinum => 'Platino',
    AchievementTier.legendary => 'Legendario',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achievement.unlocked ? _tierColor.withOpacity(0.08) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: achievement.unlocked ? _tierColor.withOpacity(0.4) : AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(achievement.icon, style: TextStyle(fontSize: 30, color: achievement.unlocked ? null : null)).animate(
              target: achievement.unlocked ? 1 : 0).tint(color: AppColors.textMuted, begin: 0, end: achievement.unlocked ? 0 : 1)),
          if (achievement.unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: _tierColor.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: Text(_tierLabel, style: TextStyle(color: _tierColor, fontSize: 9, fontWeight: FontWeight.w700)),
            )
          else
            const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 16),
        ]),
        const Gap(8),
        Text(achievement.title, style: TextStyle(
          color: achievement.unlocked ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.w700, fontSize: 13),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const Gap(4),
        Text(achievement.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const Spacer(),
        if (!achievement.unlocked && achievement.requirement > 0) ...[
          LinearProgressIndicator(
            value: achievement.progressPercentage,
            backgroundColor: AppColors.inputFill,
            valueColor: AlwaysStoppedAnimation(_tierColor),
            minHeight: 5, borderRadius: BorderRadius.circular(3),
          ),
          const Gap(4),
          Text('${achievement.currentProgress} / ${achievement.requirement}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ] else if (achievement.unlocked) ...[
          Text('+${achievement.xpReward} XP', style: TextStyle(color: _tierColor, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ]),
    );
  }
}
