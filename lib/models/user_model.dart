// MODELO DE DADOS: USER:
// Representa as informações de um usuário na rede social Papacapim.


class UserModel {
  final String id;
  final String name;
  final String login; // @handle no Papacapim
  final String avatarUrl;
  final int followersCount;
  final int followingCount;
  final bool isFollowedByCurrentUser;
  final bool isCurrentUser;

  UserModel({
    required this.id,
    required this.name,
    required this.login,
    required this.avatarUrl,
    required this.followersCount,
    required this.followingCount,
    this.isFollowedByCurrentUser = false,
    this.isCurrentUser = false,
  });

  /// Construtor de fábrica para desserializar JSON vindo da API Papacapim
  factory UserModel.fromJson(Map<String, dynamic> json, {bool isCurrentUser = false}) {
    final login = (json['login'] ?? '').toString();
    final profileImage = json['profile_image'] ?? json['avatarUrl'];
    final fallbackAvatar = 'https://i.pravatar.cc/150?u=$login';

    return UserModel(
      id: json['id']?.toString() ?? login,
      name: (json['name'] ?? login).toString(),
      login: login,
      avatarUrl: (profileImage != null && profileImage.toString().isNotEmpty)
          ? profileImage.toString()
          : fallbackAvatar,
      followersCount: (json['followers_number'] ?? json['followersCount'] ?? 0) as int,
      followingCount: (json['following_number'] ?? json['followingCount'] ?? 0) as int,
      isFollowedByCurrentUser: (json['you_follow'] ?? json['isFollowedByCurrentUser'] ?? false) as bool,
      isCurrentUser: isCurrentUser || (json['isCurrentUser'] ?? false) as bool,
    );
  }

  /// Converte o modelo de volta para formato Map/JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'name': name,
      'profile_image': avatarUrl,
      'followers_number': followersCount,
      'following_number': followingCount,
      'you_follow': isFollowedByCurrentUser,
      'isCurrentUser': isCurrentUser,
    };
  }

  /// Método helper para clonar o objeto aplicando pequenas alterações de estado
  UserModel copyWith({
    String? id,
    String? name,
    String? login,
    String? avatarUrl,
    int? followersCount,
    int? followingCount,
    bool? isFollowedByCurrentUser,
    bool? isCurrentUser,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      login: login ?? this.login,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowedByCurrentUser: isFollowedByCurrentUser ?? this.isFollowedByCurrentUser,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
