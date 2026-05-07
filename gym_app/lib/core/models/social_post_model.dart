import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum PostCategory {
  achievement,
  progress,
  tip,
  motivation,
  announcement,
  workout,
  challenge,
  general;

  String get displayName {
    switch (this) {
      case PostCategory.achievement:
        return 'Achievement';
      case PostCategory.progress:
        return 'Progress';
      case PostCategory.tip:
        return 'Tip';
      case PostCategory.motivation:
        return 'Motivation';
      case PostCategory.announcement:
        return 'Announcement';
      case PostCategory.workout:
        return 'Workout';
      case PostCategory.challenge:
        return 'Challenge';
      case PostCategory.general:
        return 'General';
    }
  }

  static PostCategory fromString(String value) {
    return PostCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PostCategory.general,
    );
  }
}

// ---------------------------------------------------------------------------
// PostComment
// ---------------------------------------------------------------------------

@immutable
class PostComment {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final DateTime createdAt;
  final List<String> likedByIds;

  const PostComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    required this.createdAt,
    this.likedByIds = const [],
  });

  int get likesCount => likedByIds.length;

  bool isLikedBy(String userId) => likedByIds.contains(userId);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likedByIds': likedByIds,
    };
  }

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likedByIds: (json['likedByIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  PostComment copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    DateTime? createdAt,
    List<String>? likedByIds,
    bool clearAuthorPhotoUrl = false,
  }) {
    return PostComment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: clearAuthorPhotoUrl
          ? null
          : (authorPhotoUrl ?? this.authorPhotoUrl),
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likedByIds: likedByIds ?? this.likedByIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostComment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// SocialPost
// ---------------------------------------------------------------------------

@immutable
class SocialPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String gymId;
  final String content;
  final String? imageUrl;
  final List<String> likedByIds;
  final List<PostComment> comments;
  final PostCategory category;
  final DateTime createdAt;
  final bool isPinned;
  final List<String> tags;

  const SocialPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.gymId,
    required this.content,
    this.imageUrl,
    this.likedByIds = const [],
    this.comments = const [],
    this.category = PostCategory.general,
    required this.createdAt,
    this.isPinned = false,
    this.tags = const [],
  });

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  int get likesCount => likedByIds.length;

  int get commentsCount => comments.length;

  bool isLikedBy(String userId) => likedByIds.contains(userId);

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'gymId': gymId,
      'content': content,
      'imageUrl': imageUrl,
      'likedByIds': likedByIds,
      'comments': comments.map((c) => c.toJson()).toList(),
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'isPinned': isPinned,
      'tags': tags,
    };
  }

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      gymId: json['gymId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      likedByIds: (json['likedByIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => PostComment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      category:
          PostCategory.fromString(json['category'] as String? ?? 'general'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  SocialPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? gymId,
    String? content,
    String? imageUrl,
    List<String>? likedByIds,
    List<PostComment>? comments,
    PostCategory? category,
    DateTime? createdAt,
    bool? isPinned,
    List<String>? tags,
    bool clearAuthorPhotoUrl = false,
    bool clearImageUrl = false,
  }) {
    return SocialPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: clearAuthorPhotoUrl
          ? null
          : (authorPhotoUrl ?? this.authorPhotoUrl),
      gymId: gymId ?? this.gymId,
      content: content ?? this.content,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      likedByIds: likedByIds ?? this.likedByIds,
      comments: comments ?? this.comments,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPost &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SocialPost(id: $id, author: $authorName, likes: $likesCount)';
}
