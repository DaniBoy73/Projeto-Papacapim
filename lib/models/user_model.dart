/// ============================================================================
/// MODELO DE DADOS: USER
/// ============================================================================
/// Representa as informações de um usuário na rede social Papacapim.
/// 
/// DICA PARA SABATINA:
/// Mantemos este modelo imutável com métodos como `copyWith`. Na Parte 2,
/// adicionaremos `factory UserModel.fromJson(Map<String, dynamic> json)` e 
/// `Map<String, dynamic> toJson()` para desserializar as respostas da API REST.
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
