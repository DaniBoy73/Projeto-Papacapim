// lib/providers/feed_provider.dart
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../data/mock_data.dart';

/// Gerencia o estado do feed, posts, curtidas, respostas e usuários.
/// Na Parte 2: substituir por chamadas HTTP aos endpoints da API.
class FeedProvider extends ChangeNotifier {
  late List<PostModel> _posts;
  bool _isLoading = false;

  FeedProvider() {
    _posts = buildMockPosts();
  }

  bool get isLoading => _isLoading;

  // ---------------------------------------------------------------------------
  // Feed
  // ---------------------------------------------------------------------------
  List<PostModel> get allPosts =>
      List.unmodifiable(_posts.where((p) => p.replyToId == null).toList());

  /// Posts apenas de usuários seguidos pelo usuário logado
  List<PostModel> followingPosts(String currentUserId) {
    final followedIds = mockUsers
        .where((u) => u.isFollowing)
        .map((u) => u.id)
        .toSet();

    return List.unmodifiable(
      _posts
          .where((p) =>
              p.replyToId == null &&
              (p.userId == currentUserId || followedIds.contains(p.userId)))
          .toList(),
    );
  }

  /// Posts de um usuário específico (para tela de perfil)
  List<PostModel> userPosts(String userId) => List.unmodifiable(
        _posts.where((p) => p.userId == userId && p.replyToId == null).toList(),
      );

  /// Respostas a um post específico
  List<PostModel> repliesOf(String postId) => List.unmodifiable(
        _posts.where((p) => p.replyToId == postId).toList(),
      );

  // ---------------------------------------------------------------------------
  // Curtir / Descurtir
  // ---------------------------------------------------------------------------
  /// Na Parte 2: POST /tweets/:id/likes  ou  DELETE /tweets/:id/likes
  void toggleLike(String postId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final post = _posts[idx];
    _posts[idx] = post.copyWith(
      isLiked: !post.isLiked,
      likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Criar post
  // ---------------------------------------------------------------------------
  /// Na Parte 2: POST /tweets
  void createPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Excluir post
  // ---------------------------------------------------------------------------
  /// Na Parte 2: DELETE /tweets/:id
  void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId || p.replyToId == postId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Responder post
  // ---------------------------------------------------------------------------
  /// Na Parte 2: POST /tweets/:id/replies
  void replyToPost(String parentId, PostModel reply) {
    _posts.add(reply);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Seguir / Deixar de seguir
  // ---------------------------------------------------------------------------
  /// Na Parte 2: POST /users/:login/followers  ou  DELETE /users/:login/followers
  void toggleFollow(UserModel targetUser) {
    final idx = mockUsers.indexWhere((u) => u.id == targetUser.id);
    if (idx == -1) return;

    final isNowFollowing = !mockUsers[idx].isFollowing;
    mockUsers[idx].isFollowing = isNowFollowing;
    mockUsers[idx].followersCount += isNowFollowing ? 1 : -1;

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Busca
  // ---------------------------------------------------------------------------
  List<PostModel> searchPosts(String query) {
    if (query.trim().isEmpty) return allPosts;
    final q = query.toLowerCase();
    return _posts
        .where((p) =>
            p.replyToId == null &&
            (p.content.toLowerCase().contains(q) ||
                p.authorName.toLowerCase().contains(q) ||
                p.authorLogin.toLowerCase().contains(q)))
        .toList();
  }

  List<UserModel> searchUsers(String query) {
    if (query.trim().isEmpty) return List.unmodifiable(mockUsers);
    final q = query.toLowerCase();
    return mockUsers
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.login.toLowerCase().contains(q))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Atualizar avatar nos posts após edição de perfil
  // ---------------------------------------------------------------------------
  void syncUserInPosts(UserModel user) {
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].userId == user.id) {
        _posts[i] = _posts[i].copyWith(
          authorAvatarUrl: user.avatarUrl,
          authorLocalAvatarPath: user.localAvatarPath,
        );
      }
    }
    notifyListeners();
  }
}
