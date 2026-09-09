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
  final Map<String, String> _postAuthorCache = {};
  final Set<String> _pendingParentFetches = {};
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
  List<PostModel> get followedUsersPosts {
    // Retorna posts seguidos combinados com os posts do próprio usuário logado, ordenados por data
    final myPosts = _allPosts.where(
      (p) => p.authorLogin.toLowerCase() == _currentUser.login.toLowerCase(),
    );
    final allFollowed = <PostModel>[..._followedPosts];
    for (final post in myPosts) {
      if (!allFollowed.any((p) => p.id == post.id)) {
        allFollowed.add(post);
      }
    }
    allFollowed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(allFollowed);
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => api.isAuthenticated;

  // Inicializa com dados padrão locais (sem usuários mockados)
  void _initData() {
    _currentUser = MockDatabase.loggedUser;
    _users = [];
    _allPosts = MockDatabase.getInitialPosts();
    _followedPosts = _allPosts.where((p) => p.authorLogin != _currentUser.login).toList();
    _postAuthorCache.clear();
    _pendingParentFetches.clear();
  }

  /// Registra no cache interno os mapeamentos de postId -> authorLogin
  void _registerPostAuthors(Iterable<PostModel> posts) {
    for (final p in posts) {
      if (p.id.isNotEmpty && p.authorLogin.isNotEmpty) {
        _postAuthorCache[p.id] = p.authorLogin;
      }
      if (p.parentPostId != null &&
          p.parentAuthorLogin != null &&
          p.parentAuthorLogin!.isNotEmpty) {
        _postAuthorCache[p.parentPostId!] = p.parentAuthorLogin!;
      }
    }
  }

  /// Resolve o arroba (@login) do autor do post pai para respostas
  List<PostModel> _resolveParentAuthors(List<PostModel> posts) {
    return posts.map((post) {
      if (post.parentPostId == null || post.parentPostId!.isEmpty) {
        return post;
      }
      if (post.parentAuthorLogin != null && post.parentAuthorLogin!.isNotEmpty) {
        _postAuthorCache[post.parentPostId!] = post.parentAuthorLogin!;
        return post;
      }
      final cachedAuthor = _postAuthorCache[post.parentPostId];
      if (cachedAuthor != null && cachedAuthor.isNotEmpty) {
        return post.copyWith(parentAuthorLogin: cachedAuthor);
      }
      // Se ainda não estiver em cache, agenda a busca via API em segundo plano
      _fetchParentAuthorAsync(post.parentPostId!);
      return post;
    }).toList();
  }

  /// Busca em segundo plano o autor do post original através de GET /posts/{id}
  void _fetchParentAuthorAsync(String parentPostId) {
    if (_postAuthorCache.containsKey(parentPostId) || _pendingParentFetches.contains(parentPostId)) {
      return;
    }
    if (!api.isAuthenticated) return;

    _pendingParentFetches.add(parentPostId);
    api.getPostById(parentPostId).then((parentPost) {
      _pendingParentFetches.remove(parentPostId);
      if (parentPost.authorLogin.isNotEmpty) {
        _postAuthorCache[parentPostId] = parentPost.authorLogin;
        _allPosts = _allPosts.map((p) {
          if (p.parentPostId == parentPostId &&
              (p.parentAuthorLogin == null || p.parentAuthorLogin!.isEmpty)) {
            return p.copyWith(parentAuthorLogin: parentPost.authorLogin);
          }
          return p;
        }).toList();

        _followedPosts = _followedPosts.map((p) {
          if (p.parentPostId == parentPostId &&
              (p.parentAuthorLogin == null || p.parentAuthorLogin!.isEmpty)) {
            return p.copyWith(parentAuthorLogin: parentPost.authorLogin);
          }
          return p;
        }).toList();

        notifyListeners();
      }
    }).catchError((_) {
      _pendingParentFetches.remove(parentPostId);
    });
  }

  /// Retorna o @login do autor do post que está sendo respondido (ou null se ainda carregando)
  String? getParentAuthorLogin(String? parentPostId) {
    if (parentPostId == null || parentPostId.isEmpty) return null;
    if (_postAuthorCache.containsKey(parentPostId)) {
      return _postAuthorCache[parentPostId];
    }
    _fetchParentAuthorAsync(parentPostId);
    return null;
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
          avatarUrl: '',
          followersCount: 0,
          followingCount: 0,
          isCurrentUser: true,
        );
      }

      // 3. Carrega o feed da API e os usuários reais do sistema
      await Future.wait([
        refreshFeed(),
        fetchUsers(),
      ]);

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

  /// Atualiza o feed buscando posts e sincroniza os usuários reais da API
  Future<void> refreshFeed() async {
    if (!api.isAuthenticated) return;

    try {
      // Busca posts de seguidos (feed=1), recomendados (sem feed) e usuários reais
      final results = await Future.wait([
        api.getPosts(feedOnly: true),
        api.getPosts(feedOnly: false),
        api.getMyProfile().catchError((_) => _currentUser),
        api.searchUsers('').catchError((_) => <UserModel>[]),
      ]);

      _followedPosts = results[0] as List<PostModel>;
      _allPosts = results[1] as List<PostModel>;
      _registerPostAuthors(_allPosts);
      _registerPostAuthors(_followedPosts);
      _allPosts = _resolveParentAuthors(_allPosts);
      _followedPosts = _resolveParentAuthors(_followedPosts);

      _currentUser = (results[2] as UserModel).copyWith(isCurrentUser: true);
      final apiUsers = results[3] as List<UserModel>;
      if (apiUsers.isNotEmpty) {
        _users = apiUsers;
      }

      // Garante que o nome e avatar do autor estejam atualizados com o perfil mais recente
      _allPosts = _allPosts.map((p) {
        if (p.authorLogin.toLowerCase() == _currentUser.login.toLowerCase()) {
          return p.copyWith(
            authorName: _currentUser.name,
            authorAvatarUrl: _currentUser.avatarUrl.isNotEmpty ? _currentUser.avatarUrl : p.authorAvatarUrl,
          );
        }
        return p;
      }).toList();

      _followedPosts = _followedPosts.map((p) {
        if (p.authorLogin.toLowerCase() == _currentUser.login.toLowerCase()) {
          return p.copyWith(
            authorName: _currentUser.name,
            authorAvatarUrl: _currentUser.avatarUrl.isNotEmpty ? _currentUser.avatarUrl : p.authorAvatarUrl,
          );
        }
        return p;
      }).toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Cria uma nova postagem ou responde a um post existente
  Future<bool> addPost(String content, {PostModel? replyToPost}) async {
    if (content.trim().isEmpty) return false;

    if (replyToPost != null && replyToPost.authorLogin.isNotEmpty) {
      _postAuthorCache[replyToPost.id] = replyToPost.authorLogin;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (api.isAuthenticated) {
        final PostModel created;
        if (replyToPost != null) {
          final parentId = int.tryParse(replyToPost.id);
          if (parentId != null) {
            created = await api.replyPost(parentId, content.trim());
          } else {
            created = await api.createPost(content.trim());
          }
        } else {
          created = await api.createPost(content.trim());
        }

        // Insere imediatamente a postagem criada no topo de _allPosts
        // garantindo reatividade instantânea no Web/Mobile
        final fullCreated = created.copyWith(
            authorId: _currentUser.id,
            authorName: _currentUser.name,
            authorLogin: _currentUser.login,
            authorAvatarUrl: _currentUser.avatarUrl,
            parentPostId: replyToPost?.id,
            parentAuthorLogin: replyToPost?.authorLogin,
            parentContentPreview: replyToPost != null
                ? (replyToPost.content.length > 40
                    ? '${replyToPost.content.substring(0, 40)}...'
                    : replyToPost.content)
                : null,
          );
          _postAuthorCache[fullCreated.id] = fullCreated.authorLogin;
          _allPosts.removeWhere((p) => p.id == fullCreated.id);
          _allPosts.insert(0, fullCreated);

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
        _postAuthorCache[newPost.id] = newPost.authorLogin;
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
    final clean = userIdOrLogin.replaceAll('@', '').toLowerCase();
    final uIndex = _users.indexWhere((u) => u.id.toLowerCase() == clean || u.login.toLowerCase() == clean);
    UserModel? targetUser = uIndex != -1 ? _users[uIndex] : null;

    if (targetUser == null) {
      if (api.isAuthenticated) {
        try {
          targetUser = await api.getUser(clean);
        } catch (_) {}
      }
      targetUser ??= getUserByLogin(clean);
    }

    if (targetUser.login.toLowerCase() == _currentUser.login.toLowerCase()) return;

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

        final effectiveAvatar = updatedUser.avatarUrl.isNotEmpty
            ? updatedUser.avatarUrl
            : (avatarUrl ?? _currentUser.avatarUrl);

        final newName = updatedUser.name.isNotEmpty ? updatedUser.name : name.trim();

        _currentUser = updatedUser.copyWith(
          name: newName,
          isCurrentUser: true,
          avatarUrl: effectiveAvatar,
        );

        // Atualiza também o usuário no cache de usuários locais
        final userIndex = _users.indexWhere((u) => u.login.toLowerCase() == _currentUser.login.toLowerCase());
        if (userIndex != -1) {
          _users[userIndex] = _currentUser;
        } else {
          _users.add(_currentUser);
        }

        // Atualiza o nome e o avatar nas postagens do autor atual no feed
        _allPosts = _allPosts.map((p) {
          if (p.authorLogin.toLowerCase() == _currentUser.login.toLowerCase()) {
            return p.copyWith(
              authorName: newName,
              authorAvatarUrl: effectiveAvatar.isNotEmpty ? effectiveAvatar : p.authorAvatarUrl,
            );
          }
          return p;
        }).toList();

        _followedPosts = _followedPosts.map((p) {
          if (p.authorLogin.toLowerCase() == _currentUser.login.toLowerCase()) {
            return p.copyWith(
              authorName: newName,
              authorAvatarUrl: effectiveAvatar.isNotEmpty ? effectiveAvatar : p.authorAvatarUrl,
            );
          }
          return p;
        }).toList();

        // Se a senha foi alterada, a API encerra as sessões existentes; refazemos o login
        if (password != null && password.isNotEmpty) {
          await api.login(_currentUser.login, password);
        }
      } else {
        final offlineAvatar = (avatarUrl != null && avatarUrl.isNotEmpty)
            ? avatarUrl
            : (imageData != null ? 'data:image/jpeg;base64,$imageData' : _currentUser.avatarUrl);

        _currentUser = _currentUser.copyWith(
          name: name.trim(),
          avatarUrl: offlineAvatar,
        );

        final userIndex = _users.indexWhere((u) => u.login.toLowerCase() == _currentUser.login.toLowerCase());
        if (userIndex != -1) {
          _users[userIndex] = _currentUser;
        }

        _allPosts = _allPosts.map((p) {
          if (p.authorLogin.toLowerCase() == _currentUser.login.toLowerCase()) {
            return p.copyWith(
              authorName: name.trim(),
              authorAvatarUrl: offlineAvatar,
            );
          }
          return p;
        }).toList();

        _followedPosts = _followedPosts.map((p) {
          if (p.authorLogin.toLowerCase() == _currentUser.login.toLowerCase()) {
            return p.copyWith(
              authorName: name.trim(),
              authorAvatarUrl: offlineAvatar,
            );
          }
          return p;
        }).toList();
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
  Future<bool> updateAvatar(String newAvatarUrl, {String? imageData, String? name}) async {
    return await updateProfile(
      name: name ?? _currentUser.name,
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
        final apiResults = await api.getPosts(search: query.trim());
        _registerPostAuthors(apiResults);
        return _resolveParentAuthors(apiResults);
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

  /// Atualiza ou insere um usuário no cache em memória
  void cacheUser(UserModel user) {
    final clean = user.login.replaceAll('@', '').toLowerCase();
    final idx = _users.indexWhere((u) => u.login.toLowerCase() == clean || u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
    } else {
      _users.add(user);
    }
  }

  /// Carrega a lista completa de usuários reais do sistema diretamente da API
  Future<List<UserModel>> fetchUsers() async {
    if (api.isAuthenticated) {
      try {
        final realUsers = await api.searchUsers('');
        _users = realUsers;
        notifyListeners();
        return realUsers;
      } catch (_) {}
    }
    return _users;
  }

  /// Carrega os dados atualizados de um perfil na API
  Future<UserModel?> fetchUserProfile(String login) async {
    if (!api.isAuthenticated) return null;
    try {
      final user = await api.getUser(login);
      cacheUser(user);
      notifyListeners();
      return user;
    } catch (_) {
      return null;
    }
  }

  /// Busca usuários na API por termo (ou retorna todos os usuários reais se query vazia)
  Future<List<UserModel>> searchUsers(String query) async {
    if (api.isAuthenticated) {
      try {
        final apiResults = await api.searchUsers(query.trim());
        for (final u in apiResults) {
          cacheUser(u);
        }
        return apiResults;
      } catch (_) {}
    }

    if (query.trim().isEmpty) return _users;

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
        final userPosts = await api.getUserPosts(login);
        _registerPostAuthors(userPosts);
        return _resolveParentAuthors(userPosts);
      } catch (_) {}
    }
    return _allPosts.where((p) => p.authorLogin.toLowerCase() == login.toLowerCase()).toList();
  }

  /// Busca um usuário específico pelo seu ID (ou retorna fallback/currentUser)
  UserModel getUserById(String id, {UserModel? fallback}) {
    final clean = id.replaceAll('@', '').toLowerCase();
    if (clean == _currentUser.id.toLowerCase() || clean == _currentUser.login.toLowerCase()) {
      return _currentUser;
    }
    return _users.firstWhere(
      (u) => u.id.toLowerCase() == clean || u.login.toLowerCase() == clean,
      orElse: () => fallback ?? getUserByLogin(id),
    );
  }

  /// Busca um usuário específico pelo seu login
  UserModel getUserByLogin(String login, {UserModel? fallback}) {
    final clean = login.replaceAll('@', '').toLowerCase();
    if (_currentUser.login.toLowerCase() == clean) return _currentUser;
    return _users.firstWhere(
      (u) => u.login.toLowerCase() == clean,
      orElse: () => fallback ?? UserModel(
        id: clean,
        name: clean,
        login: clean,
        avatarUrl: '',
        followersCount: 0,
        followingCount: 0,
        isFollowedByCurrentUser: false,
      ),
    );
  }
}
