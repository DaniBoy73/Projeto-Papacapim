// lib/models/user_model.dart
class UserModel {
  final String id;
  String name;
  String login;
  String password;
  String? bio;
  String? avatarUrl;
  String? localAvatarPath; // Para foto local (image_picker)
  int followersCount;
  int followingCount;
  bool isFollowing; // Se o usuário logado segue este usuário

  UserModel({
    required this.id,
    required this.name,
    required this.login,
    required this.password,
    this.bio,
    this.avatarUrl,
    this.localAvatarPath,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  /// Copia com campos opcionais alterados (útil para edição de perfil)
  UserModel copyWith({
    String? name,
    String? login,
    String? password,
    String? bio,
    String? avatarUrl,
    String? localAvatarPath,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      login: login ?? this.login,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  /// Para futura integração com API (fromJson/toJson)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      login: json['login'] ?? '',
      password: json['password'] ?? '',
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'login': login,
      'password': password,
      'bio': bio,
      'avatar_url': avatarUrl,
      'followers_count': followersCount,
      'following_count': followingCount,
    };
  }
}
