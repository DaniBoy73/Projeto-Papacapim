import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../mock_data/mock_database.dart';
import '../services/api_service.dart';

/// GERENCIADOR DE ESTADO CENTRAL (APP STATE / CONTROLLER):
/// Implementa a regra de negócio e coordena a comunicação com o back-end via `ApiService`.
/// Notifica os widgets reativos através de `ChangeNotifier` para atualização instantânea.

class AppState extends ChangeNotifier {
  final ApiService api;

  late UserModel _currentUser;
  List<UserModel> _users = [];
  List<PostModel> _allPosts = [];
  List<PostModel> _followedPosts = [];
  bool _isLoading = false;
  String? _errorMessage;

  AppState({ApiService? apiService}) : api = apiService ?? ApiService() {
    _initData();
  }

  // ==========================================================================
  // GETTERS DO ESTADO
  // ==========================================================================

  UserModel get currentUser => _currentUser;
  List<UserModel> get users => List.unmodifiable(_users);
  List<PostModel> get posts => List.unmodifiable(_allPosts);
  List<PostModel> get followedUsersPosts => List.unmodifiable(_followedPosts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => api.isAuthenticated;

  // Inicializa com dados padrão locais (ou mockados antes de autenticar)
  void _initData() {
    _currentUser = MockDatabase.loggedUser;
    _users = MockDatabase.getInitialUsers();
    _allPosts = MockDatabase.getInitialPosts();
    _followedPosts = _allPosts.where((p) => p.authorLogin != _currentUser.login).toList();
  }

  // ==========================================================================
  // 1. AUTENTICAÇÃO E SESSÕES (API)
  // ==========================================================================

  /// Efetua o login na API e carrega os dados e feed do usuário
  Future<bool> login(String loginInput, String passwordInput) async {
    if (loginInput.trim().isEmpty || passwordInput.trim().isEmpty) {
      _errorMessage = 'Preencha o login e a senha.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Autentica na API e obtém o token de sessão
      await api.login(loginInput, passwordInput);

      // 2. Busca os dados reais do perfil logado (GET /users/me)
      try {
        final profile = await api.getMyProfile();
        _currentUser = profile.copyWith(isCurrentUser: true);
      } catch (_) {
        _currentUser = UserModel(
          id: api.currentUserLogin ?? loginInput.trim(),
          name: loginInput.trim(),
          login: api.currentUserLogin ?? loginInput.trim(),
          avatarUrl: 'https://i.pravatar.cc/150?u=${api.currentUserLogin}',
          followersCount: 0,
          followingCount: 0,
          isCurrentUser: true,
        );
      }

      // 3. Carrega o feed da API
      await refreshFeed();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cadastra um novo usuário na API e realiza o login automático em seguida
  Future<bool> register({
    required String name,
    required String loginInput,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (name.trim().isEmpty || loginInput.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Preencha todos os campos obrigatórios.';
      notifyListeners();
      return false;
    }

    if (password != passwordConfirmation) {
      _errorMessage = 'As senhas informadas não coincidem.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Cria o usuário no back-end (POST /users)
      await api.register(
        name: name,
        login: loginInput,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      // 2. Cria a sessão automaticamente (POST /sessions)
      final loginSuccess = await login(loginInput, password);
      return loginSuccess;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Encerra a sessão atual na API e reseta o estado local
  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {}
    _initData();
    notifyListeners();
  }

  // ==========================================================================
  // 2. POSTAGENS E FEED (API)
  // ==========================================================================

  /// Atualiza o feed buscando posts de quem o usuário segue e recomendados da API
  Future<void> refreshFeed() async {
    if (!api.isAuthenticated) return;

    try {
      // Busca posts de seguidos (feed=1) e recomendados (sem feed)
      final results = await Future.wait([
        api.getPosts(feedOnly: true),
        api.getPosts(feedOnly: false),
        api.getMyProfile().catchError((_) => _currentUser),
      ]);

      _followedPosts = results[0] as List<PostModel>;
      _allPosts = results[1] as List<PostModel>;
      _currentUser = (results[2] as UserModel).copyWith(isCurrentUser: true);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Cria uma nova postagem ou responde a um post existente
  Future<bool> addPost(String content, {PostModel? replyToPost}) async {
    if (content.trim().isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      if (api.isAuthenticated) {
        if (replyToPost != null) {
          final parentId = int.tryParse(replyToPost.id);
          if (parentId != null) {
            await api.replyPost(parentId, content.trim());
          } else {
            await api.createPost(content.trim());
          }
        } else {
          await api.createPost(content.trim());
        }

        // Atualiza os feeds após a criação no back-end
        await refreshFeed();
      } else {
        // Fallback local caso não esteja autenticado na API
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

        if (replyToPost != null) {
          final parentIndex = _allPosts.indexWhere((p) => p.id == replyToPost.id);
          if (parentIndex != -1) {
            _allPosts[parentIndex] = _allPosts[parentIndex].copyWith(
              commentsCount: _allPosts[parentIndex].commentsCount + 1,
            );
          }
        }
        _allPosts.insert(0, newPost);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Exclui uma postagem no back-end (DELETE /posts/{id})
  Future<bool> deletePost(String postId) async {
    try {
      final intId = int.tryParse(postId);
      if (api.isAuthenticated && intId != null) {
        await api.deletePost(intId);
      }

      _allPosts.removeWhere((p) => p.id == postId);
      _followedPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==========================================================================
  // 3. CURTIDAS (LIKE / UNLIKE NA API)
  // ==========================================================================

  /// Alterna o estado de Curtida (Like/Dislike) em tempo real e reflete no back-end
  Future<void> toggleLike(String postId) async {
    // Atualização otimista na memória para resposta imediata na interface
    int allIdx = _allPosts.indexWhere((p) => p.id == postId);
    int folIdx = _followedPosts.indexWhere((p) => p.id == postId);

    final currentPost = allIdx != -1
        ? _allPosts[allIdx]
        : (folIdx != -1 ? _followedPosts[folIdx] : null);

    if (currentPost == null) return;

    final newLikeState = !currentPost.isLikedByCurrentUser;
    final newCount = newLikeState ? currentPost.likesCount + 1 : currentPost.likesCount - 1;
    final updatedPost = currentPost.copyWith(
      isLikedByCurrentUser: newLikeState,
      likesCount: newCount < 0 ? 0 : newCount,
    );

    if (allIdx != -1) _allPosts[allIdx] = updatedPost;
    if (folIdx != -1) _followedPosts[folIdx] = updatedPost;
    notifyListeners();

    // Sincroniza com a API
    final intId = int.tryParse(postId);
    if (api.isAuthenticated && intId != null) {
      try {
        if (newLikeState) {
          await api.likePost(intId);
        } else {
          await api.unlikePost(intId);
        }
      } catch (e) {
        // Reverte se a chamada falhar
        if (allIdx != -1) _allPosts[allIdx] = currentPost;
        if (folIdx != -1) _followedPosts[folIdx] = currentPost;
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  // ==========================================================================
  // 4. SEGUIR / DEIXAR DE SEGUIR (API)
  // ==========================================================================

  /// Alterna o estado de seguir/deixar de seguir um usuário no back-end
  Future<void> toggleFollow(String userIdOrLogin) async {
    final uIndex = _users.indexWhere((u) => u.id == userIdOrLogin || u.login == userIdOrLogin);
    UserModel? targetUser = uIndex != -1 ? _users[uIndex] : null;

    if (targetUser == null) {
      try {
        targetUser = await api.getUser(userIdOrLogin);
      } catch (_) {}
    }

    if (targetUser == null || targetUser.login == _currentUser.login) return;

    final newFollowState = !targetUser.isFollowedByCurrentUser;
    final newFollowersCount = newFollowState
        ? targetUser.followersCount + 1
        : targetUser.followersCount - 1;

    final updatedTarget = targetUser.copyWith(
      isFollowedByCurrentUser: newFollowState,
      followersCount: newFollowersCount < 0 ? 0 : newFollowersCount,
    );

    if (uIndex != -1) {
      _users[uIndex] = updatedTarget;
    } else {
      _users.add(updatedTarget);
    }

    final newFollowingCount = newFollowState
        ? _currentUser.followingCount + 1
        : _currentUser.followingCount - 1;

    _currentUser = _currentUser.copyWith(
      followingCount: newFollowingCount < 0 ? 0 : newFollowingCount,
    );
    notifyListeners();

    // Sincroniza no back-end
    if (api.isAuthenticated) {
      try {
        if (newFollowState) {
          await api.followUser(targetUser.login);
        } else {
          await api.unfollowUser(targetUser.login);
        }
        // Atualiza a lista de posts de quem segue
        _followedPosts = await api.getPosts(feedOnly: true);
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  // ==========================================================================
  // 5. PERFIL E DADOS DO USUÁRIO (API)
  // ==========================================================================

  /// Altera os dados do perfil no back-end (PATCH /users/1)
  Future<bool> updateProfile({
    required String name,
    String? password,
    String? passwordConfirmation,
    String? avatarUrl,
    String? imageData,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (api.isAuthenticated) {
        final updatedUser = await api.updateProfile(
          name: name,
          password: password,
          passwordConfirmation: passwordConfirmation,
          imageData: imageData,
        );

        _currentUser = updatedUser.copyWith(
          isCurrentUser: true,
          avatarUrl: avatarUrl ?? updatedUser.avatarUrl,
        );

        // Se a senha foi alterada, a API encerra as sessões existentes; refazemos o login
        if (password != null && password.isNotEmpty) {
          await api.login(_currentUser.login, password);
        }
      } else {
        _currentUser = _currentUser.copyWith(
          name: name.trim(),
          avatarUrl: avatarUrl ?? _currentUser.avatarUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Atualiza o avatar local e na API
  Future<void> updateAvatar(String newAvatarUrl, {String? imageData}) async {
    await updateProfile(
      name: _currentUser.name,
      avatarUrl: newAvatarUrl,
      imageData: imageData,
    );
  }

  /// Exclui o perfil do usuário logado no back-end (DELETE /users/me)
  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (api.isAuthenticated) {
        await api.deleteAccount();
      }
      _initData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==========================================================================
  // 6. BUSCA E CONSULTAS
  // ==========================================================================

  /// Busca postagens na API por termo
  Future<List<PostModel>> searchPosts(String query) async {
    if (query.trim().isEmpty) return _allPosts;

    if (api.isAuthenticated) {
      try {
        return await api.getPosts(search: query.trim());
      } catch (_) {}
    }

    final term = query.toLowerCase().trim();
    return _allPosts
        .where((p) =>
            p.content.toLowerCase().contains(term) ||
            p.authorName.toLowerCase().contains(term) ||
            p.authorLogin.toLowerCase().contains(term))
        .toList();
  }

  /// Busca usuários na API por termo
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return _users;

    if (api.isAuthenticated) {
      try {
        final apiResults = await api.searchUsers(query.trim());
        if (apiResults.isNotEmpty) {
          // Atualiza o cache local de usuários
          for (final u in apiResults) {
            final idx = _users.indexWhere((existing) => existing.login == u.login);
            if (idx != -1) {
              _users[idx] = u;
            } else {
              _users.add(u);
            }
          }
          return apiResults;
        }
      } catch (_) {}
    }

    final term = query.toLowerCase().trim();
    return _users
        .where((u) =>
            u.name.toLowerCase().contains(term) ||
            u.login.toLowerCase().contains(term))
        .toList();
  }

  /// Busca postagens de um usuário específico via API
  Future<List<PostModel>> fetchUserPosts(String login) async {
    if (api.isAuthenticated) {
      try {
        return await api.getUserPosts(login);
      } catch (_) {}
    }
    return _allPosts.where((p) => p.authorLogin.toLowerCase() == login.toLowerCase()).toList();
  }

  /// Busca um usuário específico pelo seu ID (ou retorna currentUser se for ele)
  UserModel getUserById(String id) {
    if (id == _currentUser.id || id == _currentUser.login) return _currentUser;
    return _users.firstWhere(
      (u) => u.id == id || u.login == id,
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
