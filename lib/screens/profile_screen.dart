import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/post_card.dart';
import '../widgets/empty_state_widget.dart';
import '../routes/app_routes.dart';

/// TELA DE PERFIL DE USUÁRIO (TELA PERFIL):
/// Exibe as informações detalhadas do usuário e a timeline de postagens dele.
/// Suporta visualização tanto do próprio perfil quanto do perfil de terceiros.

class ProfileScreen extends StatelessWidget {
  final UserModel? targetUser;

  const ProfileScreen({
    super.key,
    this.targetUser,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    // Se nenhum usuário for passado, exibe o perfil do usuário atualmente logado
    final initialUser = targetUser ?? state.currentUser;
    final user = state.getUserById(initialUser.id);
    final isMe = user.id == state.currentUser.id;

    // Filtra apenas as postagens deste usuário específico
    final userPosts = state.posts.where((p) => p.authorLogin == user.login).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isMe ? 'Meu Perfil' : '@${user.login}'),
        actions: [
          if (isMe)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Alterar Dados',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
            ),
        ],
      ),
      body: CustomScrollView(
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
                    'Postagens de ${isMe ? 'você' : '@${user.login}'} (${userPosts.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de Postagens do Usuário
          if (userPosts.isEmpty)
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
                  return PostCard(post: userPosts[index]);
                },
                childCount: userPosts.length,
              ),
            ),
        ],
      ),
    );
  }
}
