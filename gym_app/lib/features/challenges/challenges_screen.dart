import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gym_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Local UI model (decoupled from the server Challenge model)
// ---------------------------------------------------------------------------

enum _ChallengeCategory { fitness, nutrition, attendance, strength, cardio, social }

class _Challenge {
  final String id, title, description, emoji;
  final _ChallengeCategory category;
  final DateTime startDate, endDate;
  final int participantsCount, pointsReward;
  final double userProgress;
  final Color color;
  final bool isActive, isCompleted, hasJoined;

  const _Challenge({
    required this.id, required this.title, required this.description, required this.emoji,
    required this.category, required this.startDate, required this.endDate,
    required this.participantsCount, required this.pointsReward,
    this.userProgress = 0, required this.color,
    this.isActive = true, this.isCompleted = false, this.hasJoined = false,
  });

  _Challenge copyWith({int? participantsCount, bool? hasJoined, double? userProgress, bool? isCompleted}) =>
      _Challenge(
        id: id, title: title, description: description, emoji: emoji, category: category,
        startDate: startDate, endDate: endDate,
        participantsCount: participantsCount ?? this.participantsCount,
        pointsReward: pointsReward, userProgress: userProgress ?? this.userProgress,
        color: color, isActive: isActive, isCompleted: isCompleted ?? this.isCompleted,
        hasJoined: hasJoined ?? this.hasJoined,
      );
}

List<_Challenge> _mockChallenges() {
  final now = DateTime.now();
  return [
    _Challenge(id: 'c1', title: '30 Días de Hierro', description: 'Completa 30 entrenamientos en 30 días y gana el badge de Guerrero de Hierro',
        emoji: '💪', category: _ChallengeCategory.fitness, color: AppColors.primary,
        startDate: now.subtract(const Duration(days: 5)), endDate: now.add(const Duration(days: 25)),
        participantsCount: 87, pointsReward: 1000, hasJoined: true, userProgress: 0.43),
    _Challenge(id: 'c2', title: 'Rey del Cardio', description: 'Quema más de 10,000 calorías en el mes y llévate la camiseta del campeón',
        emoji: '🔥', category: _ChallengeCategory.cardio, color: AppColors.error,
        startDate: now.subtract(const Duration(days: 10)), endDate: now.add(const Duration(days: 20)),
        participantsCount: 54, pointsReward: 800, hasJoined: true, userProgress: 0.65),
    _Challenge(id: 'c3', title: 'Asistencia Perfecta', description: 'Ven al gimnasio todos los días laborables durante 4 semanas seguidas',
        emoji: '🏅', category: _ChallengeCategory.attendance, color: AppColors.success,
        startDate: now.subtract(const Duration(days: 2)), endDate: now.add(const Duration(days: 26)),
        participantsCount: 123, pointsReward: 600, hasJoined: false),
    _Challenge(id: 'c4', title: 'Nutrición Consciente', description: 'Registra tus comidas diariamente durante 21 días consecutivos',
        emoji: '🥗', category: _ChallengeCategory.nutrition, color: AppColors.success,
        startDate: now.subtract(const Duration(days: 15)), endDate: now.add(const Duration(days: 6)),
        participantsCount: 41, pointsReward: 500, hasJoined: false),
    _Challenge(id: 'c5', title: '100kg Club', description: 'Alcanza los 100kg en sentadilla o peso muerto y únete al club',
        emoji: '🏋️', category: _ChallengeCategory.strength, color: AppColors.warning,
        startDate: now.subtract(const Duration(days: 30)), endDate: now.add(const Duration(days: 60)),
        participantsCount: 28, pointsReward: 1500, hasJoined: true, userProgress: 0.82),
    _Challenge(id: 'c6', title: 'Social Fitness', description: 'Publica 10 fotos de tus entrenamientos y etiqueta al gym',
        emoji: '📸', category: _ChallengeCategory.social, color: AppColors.accent,
        startDate: now.subtract(const Duration(days: 7)), endDate: now.add(const Duration(days: 21)),
        participantsCount: 67, pointsReward: 300, hasJoined: false),
    _Challenge(id: 'c7', title: 'Maratón de Clases', description: '¡Completado! Asististe a 20 clases grupales en el mes',
        emoji: '🎯', category: _ChallengeCategory.fitness, color: AppColors.primary,
        startDate: now.subtract(const Duration(days: 40)), endDate: now.subtract(const Duration(days: 10)),
        participantsCount: 95, pointsReward: 700, hasJoined: true, isCompleted: true, isActive: false, userProgress: 1.0),
    _Challenge(id: 'c8', title: 'Sprint de Enero', description: 'Nuevo año, nuevo tú — El reto más grande del año llega en enero',
        emoji: '🚀', category: _ChallengeCategory.cardio, color: const Color(0xFF7B2FF7),
        startDate: now.add(const Duration(days: 15)), endDate: now.add(const Duration(days: 46)),
        participantsCount: 0, pointsReward: 2000, hasJoined: false, isActive: false),
  ];
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final _challengesProvider = StateProvider<List<_Challenge>>((ref) => _mockChallenges());

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});
  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  String _filter = 'Todos';
  static const _filters = ['Todos', 'Activos', 'Mis Retos', 'Completados'];

  @override
  Widget build(BuildContext context) {
    final challenges = ref.watch(_challengesProvider);
    final active = challenges.where((c) => c.isActive && !c.isCompleted).toList();
    final mine = challenges.where((c) => c.hasJoined).toList();
    final completed = challenges.where((c) => c.isCompleted).toList();

    List<_Challenge> filtered;
    if (_filter == 'Activos') filtered = active;
    else if (_filter == 'Mis Retos') filtered = mine;
    else if (_filter == 'Completados') filtered = completed;
    else filtered = challenges;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: const Text('Retos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
            actions: [
              IconButton(icon: const Icon(Icons.leaderboard, color: AppColors.warning), onPressed: () => _showLeaderboard(context)),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(96),
              child: Column(children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: [
                      _StatCard('${active.length}', 'Activos', AppColors.primary),
                      const Gap(8),
                      _StatCard('${mine.length}', 'Mis Retos', AppColors.accent),
                      const Gap(8),
                      _StatCard('${completed.length}', 'Completados', AppColors.success),
                    ])),
                SizedBox(height: 36, child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const Gap(8),
                  itemBuilder: (_, i) {
                    final f = _filters[i];
                    final selected = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(f, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    );
                  },
                )),
                const Gap(8),
              ]),
            ),
          ),
        ],
        body: filtered.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.emoji_events_outlined, color: AppColors.textMuted, size: 64),
                const Gap(16),
                const Text('Sin retos disponibles', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18)),
                const Gap(8),
                Text('No hay retos en "$_filter" por ahora', style: const TextStyle(color: AppColors.textSecondary)),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (_, i) => _ChallengeCard(
                  challenge: filtered[i],
                  onJoin: () => _joinChallenge(filtered[i]),
                  onTap: () => _showDetail(context, filtered[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateChallenge(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Crear Reto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _joinChallenge(_Challenge c) {
    ref.read(_challengesProvider.notifier).state = ref.read(_challengesProvider)
        .map((ch) => ch.id == c.id ? ch.copyWith(participantsCount: ch.participantsCount + 1, hasJoined: true) : ch).toList();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('¡Te uniste a "${c.title}"!'), backgroundColor: AppColors.success));
  }

  void _showLeaderboard(BuildContext context) {
    final leaders = [
      ('Carlos L.', 4820, 1), ('Ana G.', 4100, 2), ('María R.', 3760, 3),
      ('Juan P.', 3200, 4), ('Sofía H.', 2980, 5), ('Roberto M.', 2650, 6),
      ('Tú', 2400, 7),
    ];
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(expand: false, initialChildSize: 0.65, maxChildSize: 0.9,
        builder: (_, ctrl) => ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
          const Text('🏆 Ranking Global', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
          const Gap(16),
          ...leaders.map((l) {
            const podiumColors = [AppColors.warning, Color(0xFFC0C0C0), AppColors.bronzeTier];
            final isTop3 = l.$3 <= 3;
            final podiumColor = isTop3 ? podiumColors[l.$3 - 1] : AppColors.textMuted;
            final isMe = l.$1 == 'Tú';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary.withOpacity(0.08) : (isTop3 ? podiumColor.withOpacity(0.08) : AppColors.surface),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isMe ? AppColors.primary.withOpacity(0.3) : (isTop3 ? podiumColor.withOpacity(0.3) : AppColors.border)),
              ),
              child: Row(children: [
                SizedBox(width: 32, child: isTop3
                    ? Text(['🥇', '🥈', '🥉'][l.$3 - 1], style: const TextStyle(fontSize: 20))
                    : Text('#${l.$3}', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
                CircleAvatar(radius: 18, backgroundColor: (isMe ? AppColors.primary : podiumColor).withOpacity(0.1),
                    child: Text(l.$1[0], style: TextStyle(color: isMe ? AppColors.primary : podiumColor, fontWeight: FontWeight.w700))),
                const Gap(12),
                Expanded(child: Text(l.$1, style: TextStyle(color: isMe ? AppColors.primary : AppColors.textPrimary, fontWeight: isMe ? FontWeight.w800 : FontWeight.w600, fontSize: 14))),
                Text('${l.$2} pts', style: TextStyle(color: isMe ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 14)),
              ]),
            );
          }),
        ])),
    );
  }

  void _showDetail(BuildContext context, _Challenge c) {
    final daysLeft = c.endDate.difference(DateTime.now()).inDays;
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(expand: false, initialChildSize: 0.75, maxChildSize: 0.95,
        builder: (_, ctrl) => ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
          Container(height: 100, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.color.withOpacity(0.3), c.color.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(16),
          ), child: Center(child: Text(c.emoji, style: const TextStyle(fontSize: 52)))),
          const Gap(16),
          Text(c.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
          const Gap(8),
          Text(c.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
          const Gap(20),
          _DetailRow(Icons.people, '${c.participantsCount} participantes'),
          _DetailRow(Icons.emoji_events, '${c.pointsReward} puntos de recompensa'),
          _DetailRow(Icons.calendar_today, c.isCompleted ? 'Completado' : (daysLeft >= 0 ? 'Termina en $daysLeft días' : 'Finalizado')),
          const Gap(20),
          if (c.hasJoined && !c.isCompleted) ...[
            const Text('Tu progreso', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
            const Gap(8),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
              value: c.userProgress, minHeight: 14,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(c.color),
            )),
            const Gap(6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${(c.userProgress * 100).toStringAsFixed(0)}% completado', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text('${(100 * (1 - c.userProgress)).toStringAsFixed(0)}% restante', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ]),
            const Gap(20),
          ],
          if (c.isCompleted)
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withOpacity(0.3))),
                child: const Row(children: [Icon(Icons.check_circle, color: AppColors.success), Gap(10), Text('¡Reto completado! +700 XP ganados', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600))])),
          if (!c.hasJoined && !c.isCompleted && c.isActive) ElevatedButton(
            onPressed: () { _joinChallenge(c); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: c.color, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('¡Unirme al Reto!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ])),
    );
  }

  void _showCreateChallenge(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    _ChallengeCategory category = _ChallengeCategory.fitness;

    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: StatefulBuilder(builder: (_, ss) => Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Crear Reto', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
          const Gap(16),
          TextField(controller: titleCtrl, style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Título del reto', filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted))),
          const Gap(12),
          TextField(controller: descCtrl, maxLines: 2, style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Descripción', filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted))),
          const Gap(12),
          DropdownButtonFormField<_ChallengeCategory>(
            value: category, dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(labelText: 'Categoría', filled: true, fillColor: AppColors.surface,
                border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.textMuted)),
            items: _ChallengeCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
            onChanged: (v) => ss(() => category = v!),
          ),
          const Gap(20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty) return;
              final newC = _Challenge(
                id: 'ch_${DateTime.now().millisecondsSinceEpoch}',
                title: titleCtrl.text, description: descCtrl.text, emoji: '🏆',
                category: category, color: AppColors.primary,
                startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 30)),
                participantsCount: 1, pointsReward: 500, hasJoined: true,
              );
              ref.read(_challengesProvider.notifier).state = [newC, ...ref.read(_challengesProvider)];
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reto creado'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Crear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          )),
        ])),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _ChallengeCard extends StatelessWidget {
  final _Challenge challenge; final VoidCallback onJoin, onTap;
  const _ChallengeCard({required this.challenge, required this.onJoin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = challenge;
    final daysLeft = c.endDate.difference(DateTime.now()).inDays;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.isCompleted ? AppColors.success.withOpacity(0.4) : c.color.withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 70, decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.color.withOpacity(0.25), c.color.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                Text(c.emoji, style: const TextStyle(fontSize: 32)),
                const Gap(12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(c.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                if (c.isCompleted)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: const Text('✓ Completado', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)))
                else if (c.isActive && daysLeft >= 0)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text('$daysLeft días', style: const TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w700)))
                else
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Próximo', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700))),
              ]))),
          Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            if (c.hasJoined && !c.isCompleted) ...[
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                value: c.userProgress, minHeight: 5, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(c.color))),
              const Gap(8),
            ],
            Row(children: [
              Icon(Icons.people, size: 13, color: AppColors.textMuted),
              const Gap(4),
              Text('${c.participantsCount} participantes', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: c.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('+${c.pointsReward} pts', style: TextStyle(color: c.color, fontSize: 10, fontWeight: FontWeight.w700))),
              const Gap(6),
              if (!c.hasJoined && !c.isCompleted && c.isActive)
                GestureDetector(onTap: onJoin,
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Unirse', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))))
              else if (c.hasJoined && !c.isCompleted)
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.success.withOpacity(0.3))),
                    child: const Text('Participando', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700))),
            ]),
          ])),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label; final Color color;
  const _StatCard(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ]),
  ));
}

class _DetailRow extends StatelessWidget {
  final IconData icon; final String text;
  const _DetailRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
    Icon(icon, size: 16, color: AppColors.textMuted),
    const Gap(10),
    Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
  ]));
}
