import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/social_provider.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/core/models/social_post_model.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});
  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: const Text('Comunidad', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
            bottom: TabBar(controller: _tabCtrl,
                tabs: const [Tab(text: '🏠 Feed'), Tab(text: '🎯 Retos'), Tab(text: '🏆 Ranking')]),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _FeedTab(),
            _ChallengesTab(),
            _LeaderboardTab(),
          ],
        ),
      ),
    );
  }
}

class _FeedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(socialProvider);
    final user = ref.watch(currentUserProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Create post
        GestureDetector(
          onTap: () => _showCreatePost(context, ref, user?.id ?? ''),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(user?.name.isNotEmpty == true ? user!.name[0] : 'U',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
              const Gap(12),
              const Expanded(child: Text('¿Qué quieres compartir?', style: TextStyle(color: AppColors.textMuted))),
              const Icon(Icons.photo_camera, color: AppColors.textMuted, size: 20),
            ]),
          ),
        ),
        const Gap(12),
        if (state.isLoading)
          ...List.generate(3, (_) => _PostCardSkeleton())
        else
          ...state.posts.asMap().entries.map((e) =>
              _PostCard(post: e.value, currentUserId: user?.id ?? '')
                  .animate(delay: (e.key * 50).ms).fadeIn()),
      ],
    );
  }

  void _showCreatePost(BuildContext context, WidgetRef ref, String userId) {
    final content = TextEditingController();
    PostCategory category = PostCategory.general;
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Crear Publicación', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
          const Gap(16),
          TextField(controller: content, maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Comparte tu progreso, tips, motivación...')),
          const Gap(12),
          Wrap(spacing: 8, children: PostCategory.values.map((c) {
            const labels = {
              PostCategory.achievement: '🏆 Logro', PostCategory.progress: '📊 Progreso',
              PostCategory.tip: '💡 Tip', PostCategory.motivation: '🔥 Motivación',
              PostCategory.workout: '💪 Entreno', PostCategory.general: '💬 General',
              PostCategory.announcement: '📢 Anuncio', PostCategory.challenge: '🎯 Reto',
            };
            final sel = category == c;
            return GestureDetector(
              onTap: () => ss(() => category = c),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary.withOpacity(0.2) : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                ),
                child: Text(labels[c] ?? c.name, style: TextStyle(
                    color: sel ? AppColors.primary : AppColors.textSecondary, fontSize: 12)),
              ),
            );
          }).toList()),
          const Gap(12),
          ElevatedButton(onPressed: () {
            if (content.text.trim().isEmpty) return;
            final gymId = ref.read(authProvider).currentGymId ?? '';
            final user = ref.read(currentUserProvider);
            ref.read(socialProvider.notifier).createPost(SocialPost(
              id: const Uuid().v4(), authorId: userId,
              authorName: user?.name ?? 'Usuario', authorPhotoUrl: null,
              gymId: gymId, content: content.text.trim(),
              imageUrl: null, likedByIds: [], comments: [],
              category: category, createdAt: DateTime.now(), isPinned: false,
            ));
            Navigator.pop(ctx);
          }, child: const Text('Publicar')),
        ])),
      )),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final SocialPost post; final String currentUserId;
  const _PostCard({required this.post, required this.currentUserId});

  String get _catIcon => switch(post.category) {
    PostCategory.achievement => '🏆', PostCategory.progress => '📊',
    PostCategory.tip => '💡', PostCategory.motivation => '🔥',
    PostCategory.workout => '💪', PostCategory.general => '💬',
    PostCategory.announcement => '📢', PostCategory.challenge => '🎯',
  };

  String get _timeAgo {
    final diff = DateTime.now().difference(post.createdAt);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = post.isLikedBy(currentUserId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: post.isPinned ? AppColors.primary.withOpacity(0.3) : AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (post.isPinned) Padding(padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            const Icon(Icons.push_pin, color: AppColors.primary, size: 14),
            const Gap(4),
            const Text('Fijado', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
          ])),
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: AppColors.secondary.withOpacity(0.2),
              child: Text(post.authorName.isNotEmpty ? post.authorName[0] : 'U',
                  style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700))),
          const Gap(10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post.authorName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            Text(_timeAgo, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
          Text(_catIcon, style: const TextStyle(fontSize: 18)),
        ]),
        const Gap(10),
        Text(post.content, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        const Gap(12),
        Row(children: [
          GestureDetector(
            onTap: () => ref.read(socialProvider.notifier).likePost(post.id, currentUserId),
            child: Row(children: [
              Icon(liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? AppColors.error : AppColors.textMuted, size: 20),
              const Gap(4),
              Text('${post.likesCount}', style: TextStyle(color: liked ? AppColors.error : AppColors.textMuted, fontSize: 13)),
            ]),
          ),
          const Gap(16),
          Row(children: [
            const Icon(Icons.chat_bubble_outline, color: AppColors.textMuted, size: 18),
            const Gap(4),
            Text('${post.commentsCount}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ]),
        ]),
      ]),
    );
  }
}

class _PostCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12), height: 100,
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
  ).animate(onPlay: (c) => c.repeat()).shimmer(color: AppColors.cardElevated);
}

class _ChallengesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesProvider);
    final user = ref.watch(currentUserProvider);
    if (challenges.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('🎯', style: TextStyle(fontSize: 52)),
        Gap(16),
        Text('Sin retos activos', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        Gap(8),
        Text('Los retos del gimnasio aparecerán aquí', style: TextStyle(color: AppColors.textSecondary, textAlign: TextAlign.center)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, i) {
        final c = challenges[i];
        final joined = user != null && c.participants.any((p) => p.memberId == user.id);
        final daysLeft = c.endDate.difference(DateTime.now()).inDays;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🎯', style: TextStyle(fontSize: 28)),
              const Gap(12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                Text('${c.participants.length} participantes · $daysLeft días restantes',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ])),
              if (c.prize != null)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('🏅 Premio', style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600))),
            ]),
            const Gap(10),
            Text(c.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const Gap(12),
            LinearProgressIndicator(
              value: 1 - (daysLeft / c.endDate.difference(c.startDate).inDays).clamp(0.0, 1.0),
              backgroundColor: AppColors.inputFill,
              valueColor: const AlwaysStoppedAnimation(AppColors.warning),
              minHeight: 8, borderRadius: BorderRadius.circular(4),
            ),
            const Gap(12),
            if (c.topParticipants.isNotEmpty) ...[
              const Text('Top 3:', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const Gap(6),
              Row(children: c.topParticipants.take(3).map((p) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: [AppColors.goldTier, AppColors.silverTier, AppColors.bronzeTier][c.participants.indexOf(p) % 3].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${['🥇','🥈','🥉'][c.participants.indexOf(p) % 3]} ${p.memberName}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 11)),
              )).toList()),
              const Gap(12),
            ],
            ElevatedButton(
              onPressed: joined ? null : () => ref.read(socialProvider.notifier).joinChallenge(c.id, user?.id ?? ''),
              style: joined ? ElevatedButton.styleFrom(backgroundColor: AppColors.success) : null,
              child: Text(joined ? '✓ Participando' : 'Unirme al Reto'),
            ),
          ]),
        );
      },
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(membersProvider).members;
    final sorted = [...members]..sort((a, b) => b.totalCheckIns.compareTo(a.totalCheckIns));
    final user = ref.watch(currentUserProvider);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length + 1,
      separatorBuilder: (_, __) => const Gap(6),
      itemBuilder: (context, i) {
        if (i == 0) return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const SizedBox(width: 32),
            const Gap(12),
            const Expanded(child: Text('Miembro', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
            const Text('Check-ins', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        );
        final m = sorted[i - 1];
        final rank = i;
        final isUser = m.id == user?.id;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary.withOpacity(0.08) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isUser ? AppColors.primary.withOpacity(0.3) : AppColors.border),
          ),
          child: Row(children: [
            SizedBox(width: 32, child: Center(child: rank <= 3
                ? Text(['🥇','🥈','🥉'][rank - 1], style: const TextStyle(fontSize: 20))
                : Text('#$rank', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)))),
            const Gap(12),
            CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(m.name.isNotEmpty ? m.name[0] : 'M', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
            const Gap(10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(m.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                if (isUser) Padding(padding: const EdgeInsets.only(left: 6),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Tú', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)))),
              ]),
            ])),
            Text('${m.totalCheckIns}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
          ]),
        );
      },
    );
  }
}
