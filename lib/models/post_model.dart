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

  /// Construtor de fábrica para mapear o JSON vindo da API Papacapim
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : null;
    final authorLogin = (userMap?['login'] ?? json['authorLogin'] ?? '').toString();
    final authorName = (userMap?['name'] ?? json['authorName'] ?? authorLogin).toString();
    final cleanAuthor = authorName.trim().isNotEmpty ? authorName.trim() : authorLogin.trim();
    final rawProfileImage = userMap?['profile_image'] ?? json['authorAvatarUrl'];
    final authorAvatar = (rawProfileImage != null && rawProfileImage.toString().isNotEmpty)
        ? rawProfileImage.toString()
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(cleanAuthor)}&background=10B981&color=fff&size=150&bold=true';

    DateTime parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    } else if (json['createdAt'] is DateTime) {
      parsedDate = json['createdAt'] as DateTime;
    } else {
      parsedDate = DateTime.now();
    }

    final rawPostId = json['post_id'] ?? json['parentPostId'];
    final parentId = rawPostId?.toString();

    return PostModel(
      id: json['id'].toString(),
      authorId: authorLogin,
      authorName: authorName,
      authorLogin: authorLogin,
      authorAvatarUrl: authorAvatar,
      content: (json['message'] ?? json['content'] ?? '').toString(),
      createdAt: parsedDate,
      likesCount: (json['likes_number'] ?? json['likesCount'] ?? 0) as int,
      commentsCount: (json['replies_number'] ?? json['commentsCount'] ?? 0) as int,
      isLikedByCurrentUser: (json['you_liked'] ?? json['isLikedByCurrentUser'] ?? false) as bool,
      parentPostId: parentId,
      parentAuthorLogin: json['parentAuthorLogin']?.toString(),
      parentContentPreview: json['parentContentPreview']?.toString(),
    );
  }

  /// Converte o modelo de volta para formato Map/JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': parentPostId,
      'message': content,
      'created_at': createdAt.toIso8601String(),
      'likes_number': likesCount,
      'replies_number': commentsCount,
      'you_liked': isLikedByCurrentUser,
      'user': {
        'login': authorLogin,
        'name': authorName,
        'profile_image': authorAvatarUrl,
      },
    };
  }

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
