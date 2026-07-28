import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';
import '../routes/app_routes.dart';

/// WIDGET REUTILIZÁVEL: Cartão de postagem
/// Componente central do Feed do Papacapim.

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isOwnPost = post.authorId == state.currentUser.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: Avatar + Nome/Login + Tempo + Menu/Lixeira (se for dono)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Clicável -> Navega para Perfil
                GestureDetector(
                  onTap: () {
                    final targetUser = state.getUserByLogin(post.authorLogin);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.profile,
                      arguments: targetUser,
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryLight,
                    backgroundImage: NetworkImage(post.authorAvatarUrl),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Nome, Handle e Tempo
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final targetUser = state.getUserByLogin(post.authorLogin);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.profile,
                        arguments: targetUser,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '@${post.authorLogin} • ${post.formattedTime}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botão Excluir Post (Exibido apenas nos posts do próprio usuário logado)
                if (isOwnPost)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20),
                    tooltip: 'Excluir postagem',
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, state);
                    },
                  ),
              ],
            ),

            // Banner visual de Resposta (se este post for resposta a outro)
            if (post.parentPostId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Respondendo a @${post.parentAuthorLogin ?? 'usuario'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Conteúdo da Postagem
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: AppTheme.textColor,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 6),

            // Rodapé de Ações: Curtir e Responder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão de Curtir / Descurtir
                InkWell(
                  onTap: () {
                    state.toggleLike(post.id);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          post.isLikedByCurrentUser
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: post.isLikedByCurrentUser
                              ? Colors.red
                              : AppTheme.textMutedColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.likesCount}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: post.isLikedByCurrentUser
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: post.isLikedByCurrentUser
                                ? Colors.red
                                : AppTheme.textMutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botão de Responder
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.createPost,
                      arguments: post,
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: AppTheme.textMutedColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.commentsCount > 0 ? '${post.commentsCount}' : 'Responder',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botão de Compartilhar Simulado
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18, color: AppTheme.textMutedColor),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link da postagem copiado para a área de transferência!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo de confirmação de exclusão do post
  void _showDeleteConfirmationDialog(BuildContext context, dynamic state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Postagem?'),
        content: const Text('Tem certeza de que deseja remover esta postagem? Esta ação não pode ser desfeita.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              state.deletePost(post.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Postagem excluída com sucesso!'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
