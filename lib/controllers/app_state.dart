import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../mock_data/mock_database.dart';

/// GERENCIADOR DE ESTADO CENTRAL (APP STATE / CONTROLLER):
/// Implementa a regra de negócio local utilizando `ChangeNotifier`.
/// Todos os dados são alterados em memória reativamente, disparando `notifyListeners()`
/// para recalcular a interface do Flutter instantaneamente.


class AppState extends ChangeNotifier {
  late UserModel _currentUser;
  late List<UserModel> _users;
  late List<PostModel> _posts;

  AppState() {
    _initData();
  }

  // Getters do Estado
  UserModel get currentUser => _currentUser;
  List<UserModel> get users => List.unmodifiable(_users);
  List<PostModel> get posts => List.unmodifiable(_posts);

  // Inicializa com os dados mockados
  void _initData() {
    _currentUser = MockDatabase.loggedUser;
    _users = MockDatabase.getInitialUsers();
    _posts = MockDatabase.getInitialPosts();
  }

  // ==========================================================================
  // AUTENTICAÇÃO SIMULADA
  // ==========================================================================

  /// Simula o Login do Usuário no Papacapim
  bool login(String loginInput, String passwordInput) {
    if (loginInput.trim().isEmpty || passwordInput.trim().isEmpty) return false;
    
    // Procura usuário pelo login/handle
    final existingUser = _users.firstWhere(
      (u) => u.login.toLowerCase() == loginInput.toLowerCase().replaceAll('@', ''),
      orElse: () => _currentUser,
    );

    _currentUser = existingUser;
    notifyListeners();
    return true;
  }

  /// Simula o Cadastro de Novo Usuário
  bool register(String name, String loginInput, String password) {
    if (name.trim().isEmpty || loginInput.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    final handle = loginInput.trim().replaceAll('@', '').toLowerCase();
    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      login: handle,
      avatarUrl: 'https://i.pravatar.cc/150?img=${(_users.length % 70) + 1}',
      followersCount: 0,
      followingCount: 0,
      isCurrentUser: true,
    );

    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  /// Simula Logout
  void logout() {
    _initData();
    notifyListeners();
  }

  // ==========================================================================
  // INTERAÇÃO COM POSTAGENS (LIKE, REPOST, DELETE, CREATE)
  // ==========================================================================

  /// Alterna o estado de Curtida (Like/Dislike) em tempo real
  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newIsLiked = !post.isLikedByCurrentUser;
      final newLikesCount = newIsLiked ? post.likesCount + 1 : post.likesCount - 1;

      _posts[index] = post.copyWith(
        isLikedByCurrentUser: newIsLiked,
        likesCount: newLikesCount < 0 ? 0 : newLikesCount,
      );
      notifyListeners();
    }
  }

  /// Cria uma nova postagem ou resposta localmente
  void addPost(String content, {PostModel? replyToPost}) {
    if (content.trim().isEmpty) return;

    final newPost = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: _currentUser.id,
      authorName: _currentUser.name,
      authorLogin: _currentUser.login,
      authorAvatarUrl: _currentUser.avatarUrl,
      content: content.trim(),
      createdAt: DateTime.now(),
      likesCount: 0,
      commentsCount: 0,
      isLikedByCurrentUser: false,
      parentPostId: replyToPost?.id,
      parentAuthorLogin: replyToPost?.authorLogin,
      parentContentPreview: replyToPost != null
          ? (replyToPost.content.length > 40
              ? '${replyToPost.content.substring(0, 40)}...'
              : replyToPost.content)
          : null,
    );

    // Se for uma resposta, incrementa a contagem de comentários do post original
    if (replyToPost != null) {
      final parentIndex = _posts.indexWhere((p) => p.id == replyToPost.id);
      if (parentIndex != -1) {
        _posts[parentIndex] = _posts[parentIndex].copyWith(
          commentsCount: _posts[parentIndex].commentsCount + 1,
        );
      }
    }

    _posts.insert(0, newPost);
    notifyListeners();
  }

  /// Exclui uma postagem (Permitido apenas para o autor do post)
  bool deletePost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1 && _posts[index].authorId == _currentUser.id) {
      _posts.removeAt(index);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ==========================================================================
  // INTERAÇÃO DE PERFIL E SEGUIR/DEIXAR DE SEGUIR
  // ==========================================================================

  /// Alterna o estado de seguir/deixar de seguir um usuário
  void toggleFollow(String userId) {
    final uIndex = _users.indexWhere((u) => u.id == userId);
    if (uIndex != -1 && userId != _currentUser.id) {
      final targetUser = _users[uIndex];
      final newFollowState = !targetUser.isFollowedByCurrentUser;
      final newFollowersCount = newFollowState
          ? targetUser.followersCount + 1
          : targetUser.followersCount - 1;

      _users[uIndex] = targetUser.copyWith(
        isFollowedByCurrentUser: newFollowState,
        followersCount: newFollowersCount < 0 ? 0 : newFollowersCount,
      );

      // Atualiza o contador de 'seguindo' do usuário logado
      final newFollowingCount = newFollowState
          ? _currentUser.followingCount + 1
          : _currentUser.followingCount - 1;

      _currentUser = _currentUser.copyWith(
        followingCount: newFollowingCount < 0 ? 0 : newFollowingCount,
      );

      notifyListeners();
    }
  }

  /// Atualiza os dados do perfil do usuário logado em memória
  void updateProfile({required String name, String? avatarUrl}) {
    _currentUser = _currentUser.copyWith(
      name: name.trim(),
      avatarUrl: avatarUrl ?? _currentUser.avatarUrl,
    );

    // Atualiza também na lista global de usuários
    final userIdx = _users.indexWhere((u) => u.id == _currentUser.id);
    if (userIdx != -1) {
      _users[userIdx] = _currentUser;
    }

    // Atualiza o nome e avatar em todas as postagens do usuário logado
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].authorId == _currentUser.id) {
        _posts[i] = _posts[i].copyWith(
          authorName: _currentUser.name,
          authorAvatarUrl: _currentUser.avatarUrl,
        );
      }
    }

    notifyListeners();
  }

  /// Atualiza o avatar a partir do simulador de fotos
  void updateAvatar(String newAvatarUrl) {
    updateProfile(name: _currentUser.name, avatarUrl: newAvatarUrl);
  }

  /// Exclui o perfil do usuário logado (Simulação com Reset)
  void deleteAccount() {
    _posts.removeWhere((p) => p.authorId == _currentUser.id);
    _users.removeWhere((u) => u.id == _currentUser.id);
    logout();
  }

  // ==========================================================================
  // MÉTODOS DE BUSCA E FILTROS DE FEED
  // ==========================================================================

  /// Retorna apenas as postagens de usuários seguidos
  List<PostModel> get followedUsersPosts {
    final followedLogins = _users
        .where((u) => u.isFollowedByCurrentUser)
        .map((u) => u.login)
        .toSet();
    
    // Inclui também os posts do próprio usuário
    followedLogins.add(_currentUser.login);

    return _posts.where((p) => followedLogins.contains(p.authorLogin)).toList();
  }

  /// Filtra postagens por termo de busca
  List<PostModel> searchPosts(String query) {
    if (query.trim().isEmpty) return _posts;
    final term = query.toLowerCase().trim();
    return _posts
        .where((p) =>
            p.content.toLowerCase().contains(term) ||
            p.authorName.toLowerCase().contains(term) ||
            p.authorLogin.toLowerCase().contains(term))
        .toList();
  }

  /// Filtra usuários por termo de busca
  List<UserModel> searchUsers(String query) {
    if (query.trim().isEmpty) return _users;
    final term = query.toLowerCase().trim();
    return _users
        .where((u) =>
            u.name.toLowerCase().contains(term) ||
            u.login.toLowerCase().contains(term))
        .toList();
  }

  /// Busca um usuário específico pelo seu ID (ou retorna currentUser se for ele)
  UserModel getUserById(String id) {
    if (id == _currentUser.id) return _currentUser;
    return _users.firstWhere(
      (u) => u.id == id,
      orElse: () => _currentUser,
    );
  }

  /// Busca um usuário específico pelo seu login
  UserModel getUserByLogin(String login) {
    final clean = login.replaceAll('@', '').toLowerCase();
    if (_currentUser.login.toLowerCase() == clean) return _currentUser;
    return _users.firstWhere(
      (u) => u.login.toLowerCase() == clean,
      orElse: () => _currentUser,
    );
  }
}
