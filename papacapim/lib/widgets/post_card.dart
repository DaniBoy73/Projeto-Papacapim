// lib/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../routes/app_routes.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'user_avatar.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card de post reutilizável usado no Feed, Perfil e Busca.
/// Exibe autor, conteúdo, curtidas, respostas e botão de exclusão (somente dono).
class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isCompact; // Versão reduzida para listas de resposta

  const PostCard({
    super.key,
    required this.post,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final feed = context.read<FeedProvider>();
    final currentUser = auth.currentUser;
    final isOwner = currentUser?.id == post.userId;

    return InkWell(
      onTap: isCompact
          ? null
          : () => Navigator.pushNamed(
                context,
                AppRoutes.postDetail,
                arguments: post,
              ),
      child: Container(
        color: AppColors.surface,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isCompact ? 10 : 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar clicável
            UserAvatar(
              avatarUrl: post.authorAvatarUrl,
              localPath: post.authorLocalAvatarPath,
              name: post.authorName,
              radius: isCompact ? 18 : 22,
              onTap: () {
                final user = mockUsers.firstWhere(
                  (u) => u.id == post.userId,
                  orElse: () => mockUsers[0],
                );
                Navigator.pushNamed(context, AppRoutes.profile,
                    arguments: user);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: nome, @login, tempo e botão excluir
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final user = mockUsers.firstWhere(
                                  (u) => u.id == post.userId,
                                  orElse: () => mockUsers[0],
                                );
                                Navigator.pushNamed(
                                    context, AppRoutes.profile,
                                    arguments: user);
                              },
                              child: Text(
                                post.authorName,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '@${post.authorLogin}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '· ${timeago.format(post.createdAt, locale: 'pt_BR')}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botão excluir (apenas dono)
                      if (isOwner && !isCompact)
                        _DeleteButton(postId: post.id, feed: feed),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Conteúdo do post
                  Text(
                    post.content,
                    style: GoogleFonts.inter(
                      fontSize: isCompact ? 13 : 15,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Ações: curtir e comentar
                  if (!isCompact)
                    _PostActions(post: post, feed: feed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ações do post (curtir + comentários)
// ---------------------------------------------------------------------------
class _PostActions extends StatelessWidget {
  final PostModel post;
  final FeedProvider feed;

  const _PostActions({required this.post, required this.feed});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (_, feedProv, __) {
        // Pega estado atualizado do post
        final currentPost = feedProv.allPosts.firstWhere(
          (p) => p.id == post.id,
          orElse: () => post,
        );
        final repliesCount = feedProv.repliesOf(post.id).length;

        return Row(
          children: [
            // Curtir
            _ActionButton(
              icon: currentPost.isLiked
                  ? Icons.favorite
                  : Icons.favorite_border_rounded,
              iconColor: currentPost.isLiked
                  ? AppColors.liked
                  : AppColors.textSecondary,
              count: currentPost.likesCount,
              onTap: () => feedProv.toggleLike(post.id),
            ),
            const SizedBox(width: 20),
            // Comentar
            _ActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: AppColors.textSecondary,
              count: repliesCount,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.postDetail,
                arguments: post,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botão de exclusão com confirmação
// ---------------------------------------------------------------------------
class _DeleteButton extends StatelessWidget {
  final String postId;
  final FeedProvider feed;

  const _DeleteButton({required this.postId, required this.feed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline_rounded,
          size: 18, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: 'Excluir post',
      onPressed: () => _confirmDelete(context),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir post?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Esta ação não pode ser desfeita.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              feed.deletePost(postId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post excluído')),
              );
            },
            child: Text(
              'Excluir',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
