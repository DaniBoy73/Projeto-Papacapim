// MODELO DE DADOS: POST:
// Representa uma postagem no feed do Papacapim, suportando curtidas e respostas.
 
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorLogin;
  final String authorAvatarUrl;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByCurrentUser;

  // Campos opcionais para quando o post for uma resposta
  final String? parentPostId;
  final String? parentAuthorLogin;
  final String? parentContentPreview;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorLogin,
    required this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    this.isLikedByCurrentUser = false,
    this.parentPostId,
    this.parentAuthorLogin,
    this.parentContentPreview,
  });

  /// Getter utilitário para formatar a data de publicação de forma legível
  String get formattedTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  /// Método de cópia imutável para atualização de estado local (ex: curtir, responder)
  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorLogin,
    String? authorAvatarUrl,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
    String? parentPostId,
    String? parentAuthorLogin,
    String? parentContentPreview,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorLogin: authorLogin ?? this.authorLogin,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      parentPostId: parentPostId ?? this.parentPostId,
      parentAuthorLogin: parentAuthorLogin ?? this.parentAuthorLogin,
      parentContentPreview: parentContentPreview ?? this.parentContentPreview,
    );
  }
}
