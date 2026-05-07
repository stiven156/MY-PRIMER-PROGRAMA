import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum PostType { text, image, achievement, workout, challenge }

@immutable
class PostComment {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostComment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class SocialPost {
  final String id;
  final String gymId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final PostType type;
  final String content;
  final String? imageUrl;
  final List<String> likedByUserIds;
  final List<PostComment> comments;
  final DateTime createdAt;
  final bool isPinned;

  const SocialPost({
    required this.id,
    required this.gymId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.type,
    required this.content,
    this.imageUrl,
    this.likedByUserIds = const [],
    this.comments = const [],
    required this.createdAt,
    this.isPinned = false,
  });

  int get likesCount => likedByUserIds.length;

  SocialPost copyWith({
    String? id,
    String? gymId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    PostType? type,
    String? content,
    String? imageUrl,
    List<String>? likedByUserIds,
    List<PostComment>? comments,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return SocialPost(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      type: type ?? this.type,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPost &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum ChallengeType { steps, weight, calories, workouts, distance, pushups }

@immutable
class Challenge {
  final String id;
  final String gymId;
  final String name;
  final String description;
  final ChallengeType type;
  final double goal;
  final String unit;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participantIds;
  final Map<String, double> progress; // userId -> current value
  final String? imageUrl;
  final bool isActive;

  const Challenge({
    required this.id,
    required this.gymId,
    required this.name,
    required this.description,
    required this.type,
    required this.goal,
    required this.unit,
    required this.startDate,
    required this.endDate,
    this.participantIds = const [],
    this.progress = const {},
    this.imageUrl,
    this.isActive = true,
  });

  bool get hasEnded => DateTime.now().isAfter(endDate);
  int get participantsCount => participantIds.length;

  String? leaderUserId() {
    if (progress.isEmpty) return null;
    return progress.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  Challenge copyWith({
    String? id,
    String? gymId,
    String? name,
    String? description,
    ChallengeType? type,
    double? goal,
    String? unit,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? participantIds,
    Map<String, double>? progress,
    String? imageUrl,
    bool? isActive,
  }) {
    return Challenge(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      goal: goal ?? this.goal,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participantIds: participantIds ?? this.participantIds,
      progress: progress ?? this.progress,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Challenge &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum AchievementCategory {
  workout,
  nutrition,
  social,
  milestone,
  consistency,
  strength,
}

@immutable
class Achievement {
  final String id;
  final String memberId;
  final String name;
  final String description;
  final String emoji;
  final AchievementCategory category;
  final DateTime unlockedAt;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.memberId,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.unlockedAt,
    this.xpReward = 50,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class SocialState {
  final List<SocialPost> posts;
  final List<Challenge> challenges;
  final List<Achievement> userAchievements;
  final bool isLoading;
  final String? error;

  const SocialState({
    this.posts = const [],
    this.challenges = const [],
    this.userAchievements = const [],
    this.isLoading = false,
    this.error,
  });

  SocialState copyWith({
    List<SocialPost>? posts,
    List<Challenge>? challenges,
    List<Achievement>? userAchievements,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SocialState(
      posts: posts ?? this.posts,
      challenges: challenges ?? this.challenges,
      userAchievements: userAchievements ?? this.userAchievements,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

List<SocialPost> _buildMockPosts() {
  final now = DateTime.now();
  return [
    SocialPost(
      id: 'post_001',
      gymId: 'gym_mock_001',
      userId: 'user_admin_001',
      userName: 'Carlos Rodríguez',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=33',
      type: PostType.text,
      content:
          '¡Bienvenidos a FitPro Elite! Este mes lanzamos nuevas clases de CrossFit y Yoga Avanzado. ¡A ponerse las pilas! 💪',
      createdAt: now.subtract(const Duration(days: 5)),
      likedByUserIds: ['mem_001', 'mem_002', 'mem_003', 'mem_005', 'mem_008'],
      isPinned: true,
      comments: [
        PostComment(
          id: 'cmt_001', userId: 'mem_001', userName: 'Juan López',
          userPhotoUrl: 'https://i.pravatar.cc/150?img=12',
          text: '¡Genial! ¿A qué hora serán las clases de CrossFit?',
          createdAt: now.subtract(const Duration(days: 4, hours: 22)),
        ),
        PostComment(
          id: 'cmt_002', userId: 'user_admin_001', userName: 'Carlos Rodríguez',
          userPhotoUrl: 'https://i.pravatar.cc/150?img=33',
          text: '@Juan ¡A las 6:30 AM y 7 PM! Disponibles en el calendario.',
          createdAt: now.subtract(const Duration(days: 4, hours: 20)),
        ),
      ],
    ),
    SocialPost(
      id: 'post_002',
      gymId: 'gym_mock_001',
      userId: 'user_trainer_001',
      userName: 'María García',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=47',
      type: PostType.workout,
      content:
          '¡Sesión épica hoy! Mis alumnos de Body Pump rompieron sus marcas personales. Muy orgullosa del progreso de todos 🏆',
      imageUrl: 'https://picsum.photos/seed/workout1/400/300',
      createdAt: now.subtract(const Duration(days: 3)),
      likedByUserIds: ['mem_002', 'mem_003', 'mem_007', 'mem_008', 'mem_011', 'mem_014'],
      comments: [
        PostComment(
          id: 'cmt_003', userId: 'mem_003', userName: 'Andrés Pérez',
          userPhotoUrl: 'https://i.pravatar.cc/150?img=5',
          text: '¡Gracias Profe María! Sin su motivación no lo hubiera logrado.',
          createdAt: now.subtract(const Duration(days: 2, hours: 23)),
        ),
      ],
    ),
    SocialPost(
      id: 'post_003',
      gymId: 'gym_mock_001',
      userId: 'mem_005',
      userName: 'Diego Ramírez',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=8',
      type: PostType.achievement,
      content:
          '¡500 check-ins en el gimnasio! Un hito increíble. 5 años entrenando sin parar. ¡Nunca paren! 🔥',
      createdAt: now.subtract(const Duration(days: 2)),
      likedByUserIds: [
        'user_admin_001', 'user_trainer_001', 'mem_001', 'mem_002',
        'mem_003', 'mem_007', 'mem_008', 'mem_011', 'mem_013', 'mem_014'
      ],
      comments: [
        PostComment(
          id: 'cmt_004', userId: 'user_trainer_001', userName: 'María García',
          userPhotoUrl: 'https://i.pravatar.cc/150?img=47',
          text: '¡INCREÍBLE Diego! Eres una inspiración para todos. ¡Felicidades!',
          createdAt: now.subtract(const Duration(days: 1, hours: 23)),
        ),
        PostComment(
          id: 'cmt_005', userId: 'mem_011', userName: 'Felipe Morales',
          userPhotoUrl: 'https://i.pravatar.cc/150?img=18',
          text: '¡Así se hace hermano! A por los 1000 ahora!',
          createdAt: now.subtract(const Duration(days: 1, hours: 20)),
        ),
      ],
    ),
    SocialPost(
      id: 'post_004',
      gymId: 'gym_mock_001',
      userId: 'mem_002',
      userName: 'Sofía Martínez',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=47',
      type: PostType.image,
      content: 'Clase de yoga favorita del mes. La paz mental también es parte del fitness 🧘‍♀️',
      imageUrl: 'https://picsum.photos/seed/yoga1/400/300',
      createdAt: now.subtract(const Duration(days: 1, hours: 12)),
      likedByUserIds: ['mem_006', 'mem_008', 'mem_010', 'mem_014', 'user_trainer_001'],
      comments: [],
    ),
    SocialPost(
      id: 'post_005',
      gymId: 'gym_mock_001',
      userId: 'user_trainer_001',
      userName: 'María García',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=47',
      type: PostType.text,
      content:
          '💡 Tip del día: La consistencia supera a la intensidad. No importa cuánto hagas hoy, importa que VUELVAS mañana.',
      createdAt: now.subtract(const Duration(hours: 18)),
      likedByUserIds: ['mem_001', 'mem_003', 'mem_005', 'mem_007', 'mem_011', 'mem_013'],
      comments: [
        PostComment(
          id: 'cmt_006', userId: 'mem_001', userName: 'Juan López',
          userPhotoUrl: 'https://i.pravatar.cc/150?img=12',
          text: '¡Necesitaba leer esto hoy! Gracias Profe.',
          createdAt: now.subtract(const Duration(hours: 17)),
        ),
      ],
    ),
    SocialPost(
      id: 'post_006',
      gymId: 'gym_mock_001',
      userId: 'mem_011',
      userName: 'Felipe Morales',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=18',
      type: PostType.workout,
      content: 'Nuevo PR en sentadilla: 150 kg x 5 repeticiones. Después de 4 años entrenando, todavía hay margen de mejora 🦵',
      createdAt: now.subtract(const Duration(hours: 8)),
      likedByUserIds: [
        'user_trainer_001', 'mem_003', 'mem_005', 'mem_007', 'mem_009', 'mem_013'
      ],
      comments: [],
    ),
    SocialPost(
      id: 'post_007',
      gymId: 'gym_mock_001',
      userId: 'user_admin_001',
      userName: 'Carlos Rodríguez',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=33',
      type: PostType.text,
      content:
          '🎉 ¡RETO DEL MES ACTIVO! Únete al Challenge "30 Días de Movimiento". ¡Premios para los 3 primeros! Inscríbete desde la sección de Retos.',
      createdAt: now.subtract(const Duration(hours: 4)),
      likedByUserIds: ['mem_001', 'mem_002', 'mem_003', 'mem_004', 'mem_005'],
      isPinned: false,
      comments: [
        PostComment(
          id: 'cmt_007', userId: 'mem_002', userName: 'Sofía Martínez',
          userPhotoUrl: 'https://i.pravatar.cc/150?img=47',
          text: '¡Me apunto! 💪',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        PostComment(
          id: 'cmt_008', userId: 'mem_005', userName: 'Diego Ramírez',
          userPhotoUrl: 'https://i.pravatar.cc/150?img=8',
          text: '¡Listo para ganar! 🏆',
          createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        ),
      ],
    ),
    SocialPost(
      id: 'post_008',
      gymId: 'gym_mock_001',
      userId: 'mem_014',
      userName: 'Daniela Ortiz',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=49',
      type: PostType.image,
      content: 'Progreso de 6 meses. -13 kg y sintiéndome más fuerte que nunca. ¡No se rindan! 💪✨',
      imageUrl: 'https://picsum.photos/seed/progress1/400/300',
      createdAt: now.subtract(const Duration(hours: 2)),
      likedByUserIds: [
        'user_admin_001', 'user_trainer_001', 'mem_001', 'mem_002',
        'mem_003', 'mem_008', 'mem_010', 'mem_011'
      ],
      comments: [
        PostComment(
          id: 'cmt_009', userId: 'user_trainer_001', userName: 'María García',
          userPhotoUrl: 'https://i.pravatar.cc/150?img=47',
          text: '¡Daniela, qué orgullo! Tu dedicación es un ejemplo para todos. ¡Sigue así!',
          createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
        ),
      ],
    ),
    SocialPost(
      id: 'post_009',
      gymId: 'gym_mock_001',
      userId: 'mem_008',
      userName: 'Isabella Gómez',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=44',
      type: PostType.text,
      content: 'Primera vez haciendo Spinning y ya estoy enganchada. ¡Gracias Profe María por la motivación! 🚴‍♀️🔥',
      createdAt: now.subtract(const Duration(minutes: 45)),
      likedByUserIds: ['user_trainer_001', 'mem_002', 'mem_006'],
      comments: [],
    ),
    SocialPost(
      id: 'post_010',
      gymId: 'gym_mock_001',
      userId: 'user_trainer_001',
      userName: 'María García',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=47',
      type: PostType.text,
      content: '¡Mañana clase de HIIT a las 7 AM! Solo quedan 3 lugares. ¡No se queden sin el suyo! 🔥',
      createdAt: now.subtract(const Duration(minutes: 20)),
      likedByUserIds: ['mem_001', 'mem_005', 'mem_007'],
      comments: [],
    ),
  ];
}

List<Challenge> _buildMockChallenges() {
  final now = DateTime.now();
  return [
    Challenge(
      id: 'chl_001',
      gymId: 'gym_mock_001',
      name: '30 Días de Movimiento',
      description:
          'Completa al menos 30 minutos de ejercicio durante 30 días consecutivos. '
          'Registra tus entrenamientos diariamente y compite por el primer lugar.',
      type: ChallengeType.workouts,
      goal: 30,
      unit: 'días',
      startDate: now.subtract(const Duration(days: 5)),
      endDate: now.add(const Duration(days: 25)),
      participantIds: ['mem_001', 'mem_002', 'mem_003', 'mem_005', 'mem_007', 'mem_011'],
      progress: {
        'mem_001': 5, 'mem_002': 4, 'mem_003': 5,
        'mem_005': 5, 'mem_007': 3, 'mem_011': 5,
      },
      isActive: true,
    ),
    Challenge(
      id: 'chl_002',
      gymId: 'gym_mock_001',
      name: 'Reto 10.000 Pasos',
      description:
          'Alcanza 10.000 pasos diarios durante 2 semanas. '
          'Un desafío para moverse fuera del gimnasio también.',
      type: ChallengeType.steps,
      goal: 140000,
      unit: 'pasos',
      startDate: now.subtract(const Duration(days: 3)),
      endDate: now.add(const Duration(days: 11)),
      participantIds: ['mem_002', 'mem_004', 'mem_006', 'mem_008', 'mem_010', 'mem_012'],
      progress: {
        'mem_002': 32000, 'mem_004': 28500, 'mem_006': 15000,
        'mem_008': 41000, 'mem_010': 25000, 'mem_012': 19800,
      },
      isActive: true,
    ),
    Challenge(
      id: 'chl_003',
      gymId: 'gym_mock_001',
      name: 'King of Push-Ups',
      description:
          'Acumula la mayor cantidad de flexiones en 30 días. '
          'Regístralas después de cada sesión. ¡El campeón gana una membresía gratuita!',
      type: ChallengeType.pushups,
      goal: 1000,
      unit: 'flexiones',
      startDate: now.subtract(const Duration(days: 10)),
      endDate: now.add(const Duration(days: 20)),
      participantIds: [
        'mem_001', 'mem_003', 'mem_005', 'mem_007', 'mem_009', 'mem_011', 'mem_013', 'mem_015'
      ],
      progress: {
        'mem_001': 320, 'mem_003': 480, 'mem_005': 620,
        'mem_007': 410, 'mem_009': 150, 'mem_011': 750,
        'mem_013': 390, 'mem_015': 80,
      },
      isActive: true,
    ),
  ];
}

List<Achievement> _buildMockAchievements(String memberId) {
  final now = DateTime.now();
  return [
    Achievement(
      id: 'ach_001', memberId: memberId,
      name: '¡Primer Entrenamiento!',
      description: 'Completaste tu primera sesión de entrenamiento.',
      emoji: '🎉',
      category: AchievementCategory.milestone,
      unlockedAt: now.subtract(const Duration(days: 90)),
      xpReward: 100,
    ),
    Achievement(
      id: 'ach_002', memberId: memberId,
      name: 'Semana Completa',
      description: 'Entrenaste 5 días seguidos.',
      emoji: '🔥',
      category: AchievementCategory.consistency,
      unlockedAt: now.subtract(const Duration(days: 75)),
      xpReward: 150,
    ),
    Achievement(
      id: 'ach_003', memberId: memberId,
      name: 'Fuerza Inicial',
      description: 'Alcanzaste un PR en Press de Banca.',
      emoji: '💪',
      category: AchievementCategory.strength,
      unlockedAt: now.subtract(const Duration(days: 60)),
      xpReward: 200,
    ),
    Achievement(
      id: 'ach_004', memberId: memberId,
      name: 'Nutrición Perfecta',
      description: 'Registraste tus comidas durante 7 días consecutivos.',
      emoji: '🥗',
      category: AchievementCategory.nutrition,
      unlockedAt: now.subtract(const Duration(days: 45)),
      xpReward: 150,
    ),
    Achievement(
      id: 'ach_005', memberId: memberId,
      name: 'Social Butterfly',
      description: 'Te uniste a tu primer reto grupal.',
      emoji: '🦋',
      category: AchievementCategory.social,
      unlockedAt: now.subtract(const Duration(days: 20)),
      xpReward: 100,
    ),
    Achievement(
      id: 'ach_006', memberId: memberId,
      name: '50 Check-Ins',
      description: 'Visitaste el gimnasio 50 veces.',
      emoji: '🏅',
      category: AchievementCategory.milestone,
      unlockedAt: now.subtract(const Duration(days: 10)),
      xpReward: 300,
    ),
  ];
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SocialNotifier extends StateNotifier<SocialState> {
  SocialNotifier()
      : super(SocialState(
          posts: _buildMockPosts(),
          challenges: _buildMockChallenges(),
        ));

  /// Loads posts for a gym (simulated).
  Future<void> loadPosts(String gymId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isLoading: false, clearError: true);
  }

  /// Prepends a new post to the feed.
  Future<void> createPost(SocialPost post) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      isLoading: false,
      posts: [post, ...state.posts],
    );
  }

  /// Toggles a like on a post.
  void likePost(String postId, String userId) {
    final posts = state.posts.map((p) {
      if (p.id != postId) return p;
      final liked = List<String>.from(p.likedByUserIds);
      if (liked.contains(userId)) {
        liked.remove(userId);
      } else {
        liked.add(userId);
      }
      return p.copyWith(likedByUserIds: liked);
    }).toList();
    state = state.copyWith(posts: posts);
  }

  /// Adds a comment to a post.
  void addComment(String postId, PostComment comment) {
    final posts = state.posts.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(comments: [...p.comments, comment]);
    }).toList();
    state = state.copyWith(posts: posts);
  }

  /// Removes a post from the feed.
  Future<void> deletePost(String postId) async {
    final posts = state.posts.where((p) => p.id != postId).toList();
    state = state.copyWith(posts: posts);
  }

  /// Loads challenges for a gym (simulated).
  Future<void> loadChallenges(String gymId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false, clearError: true);
  }

  /// Adds a member to a challenge and initialises their progress at 0.
  Future<void> joinChallenge(String challengeId, String memberId) async {
    final challenges = state.challenges.map((c) {
      if (c.id != challengeId) return c;
      if (c.participantIds.contains(memberId)) return c;
      return c.copyWith(
        participantIds: [...c.participantIds, memberId],
        progress: {...c.progress, memberId: 0.0},
      );
    }).toList();
    state = state.copyWith(challenges: challenges);
  }

  /// Loads achievements for a member.
  Future<void> loadAchievements(String memberId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(
      isLoading: false,
      userAchievements: _buildMockAchievements(memberId),
      clearError: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final socialProvider = StateNotifierProvider<SocialNotifier, SocialState>(
  (ref) => SocialNotifier(),
);

/// Returns the list of active challenges.
final challengesProvider = Provider<List<Challenge>>(
  (ref) => ref
      .watch(socialProvider)
      .challenges
      .where((c) => c.isActive && !c.hasEnded)
      .toList(),
);

/// Returns the current user's unlocked achievements.
final userAchievementsProvider = Provider<List<Achievement>>(
  (ref) => ref.watch(socialProvider).userAchievements,
);
