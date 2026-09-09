import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state.dart';
import '../controllers/app_state_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/post_card.dart';
import '../widgets/empty_state_widget.dart';
import '../routes/app_routes.dart';

/// TELA DE PERFIL DE USUÁRIO (TELA PERFIL):
/// Exibe as informações detalhadas do usuário e a timeline de postagens dele.
/// Suporta visualização tanto do próprio perfil quanto do perfil de terceiros.

class ProfileScreen extends StatefulWidget {
  final UserModel? targetUser;

  const ProfileScreen({
    super.key,
    this.targetUser,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<PostModel>? _userPosts;
  bool _isLoadingPosts = false;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      final state = AppStateProvider.of(context);
      final initialUser = widget.targetUser ?? state.currentUser;
      final user = state.getUserByLogin(initialUser.login, fallback: initialUser);
      _hasLoaded = true;
      _loadProfileData(user.login, state);
    }
  }

  Future<void> _loadProfileData(String login, AppState state) async {
    setState(() => _isLoadingPosts = true);
    try {
      final results = await Future.wait([
        state.fetchUserPosts(login),
        state.fetchUserProfile(login),
      ]);
      if (mounted) {
        setState(() {
          _userPosts = results[0] as List<PostModel>;
          _isLoadingPosts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    // Se nenhum usuário for passado ou for o próprio usuário, sincroniza diretamente com state.currentUser
    final isTargetMe = widget.targetUser == null ||
        widget.targetUser!.login.toLowerCase() == state.currentUser.login.toLowerCase() ||
        widget.targetUser!.id.toLowerCase() == state.currentUser.id.toLowerCase();
    final initialUser = isTargetMe ? state.currentUser : widget.targetUser!;
    final user = isTargetMe
        ? state.currentUser
        : state.getUserByLogin(initialUser.login, fallback: initialUser);
    final isMe = user.login.toLowerCase() == state.currentUser.login.toLowerCase() ||
        user.id.toLowerCase() == state.currentUser.id.toLowerCase();

    // Postagens do usuário com sincronização reativa em tempo real
    List<PostModel> postsToDisplay;
    if (isMe) {
      // Combina os posts do estado global com os posts carregados da API
      final myStatePosts = state.posts
          .where((p) => p.authorLogin.toLowerCase() == user.login.toLowerCase())
          .toList();
      final combined = <PostModel>[...myStatePosts];
      if (_userPosts != null) {
        for (final p in _userPosts!) {
          if (!combined.any((item) => item.id == p.id)) {
            combined.add(p);
          }
        }
      }
      // Garante que o nome e avatar do autor estejam atualizados com o perfil mais recente
      postsToDisplay = combined.map((p) {
        return p.copyWith(
          authorName: user.name,
          authorAvatarUrl: user.avatarUrl.isNotEmpty ? user.avatarUrl : p.authorAvatarUrl,
        );
      }).toList();
      postsToDisplay.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      postsToDisplay = _userPosts ??
          state.posts.where((p) => p.authorLogin.toLowerCase() == user.login.toLowerCase()).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isMe ? 'Meu Perfil' : '@${user.login}'),
        actions: [
          if (isMe)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Alterar Dados',
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.editProfile);
                if (mounted) {
                  _loadProfileData(user.login, state);
                }
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadProfileData(user.login, state);
          await state.refreshFeed();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Cabeçalho do Perfil (Header)
            SliverToBoxAdapter(
              child: ProfileHeader(user: user),
            ),

            // Título da Seção de Postagens
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppTheme.backgroundColor,
                child: Row(
                  children: [
                    const Icon(Icons.grid_on, size: 18, color: AppTheme.textMutedColor),
                    const SizedBox(width: 8),
                    Text(
                      'Postagens de ${isMe ? 'você' : '@${user.login}'} (${postsToDisplay.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    if (_isLoadingPosts) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Lista de Postagens do Usuário
            if (postsToDisplay.isEmpty && !_isLoadingPosts)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  icon: Icons.article_outlined,
                  title: 'Nenhuma publicação ainda',
                  message: isMe
                      ? 'Você ainda não fez nenhuma publicação. Que tal criar uma agora?'
                      : 'Este usuário ainda não publicou nada no Papacapim.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return PostCard(post: postsToDisplay[index]);
                  },
                  childCount: postsToDisplay.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
