// lib/models/post_model.dart
import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  String content;
  int likesCount;
  bool isLiked;
  DateTime createdAt;
  List<PostModel> replies;
  String? replyToId; // ID do post pai, se for resposta

  // Dados do usuário denormalizados para exibição offline
  // Na Parte 2, virão do join com a API
  String authorName;
  String authorLogin;
  String? authorAvatarUrl;
  String? authorLocalAvatarPath;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.authorName,
    required this.authorLogin,
    this.authorAvatarUrl,
    this.authorLocalAvatarPath,
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.replies = const [],
    this.replyToId,
  });

  PostModel copyWith({
    String? content,
    int? likesCount,
    bool? isLiked,
    List<PostModel>? replies,
    String? authorAvatarUrl,
    String? authorLocalAvatarPath,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      content: content ?? this.content,
      authorName: authorName,
      authorLogin: authorLogin,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      authorLocalAvatarPath:
          authorLocalAvatarPath ?? this.authorLocalAvatarPath,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
      replies: replies ?? this.replies,
      replyToId: replyToId,
    );
  }

  /// Para futura integração com API
  factory PostModel.fromJson(Map<String, dynamic> json, UserModel author) {
    return PostModel(
      id: json['id'].toString(),
      userId: author.id,
      content: json['content'] ?? '',
      authorName: author.name,
      authorLogin: author.login,
      authorAvatarUrl: author.avatarUrl,
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
