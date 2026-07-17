// lib/screens/post/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/post_card.dart';
import '../../widgets/user_avatar.dart';
import '../../data/mock_data.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _replyController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSending = false;

  bool get _canSend =>
      _replyController.text.trim().isNotEmpty && !_isSending;

  @override
  void initState() {
    super.initState();
    _replyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _replyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    if (!_canSend) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSending = true);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final feed = context.read<FeedProvider>();
    final user = auth.currentUser!;

    final reply = PostModel(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      content: _replyController.text.trim(),
      authorName: user.name,
      authorLogin: user.login,
      authorAvatarUrl: user.avatarUrl,
      authorLocalAvatarPath: user.localAvatarPath,
      createdAt: DateTime.now(),
      replyToId: widget.post.id,
    );

    feed.replyToPost(widget.post.id, reply);
    _replyController.clear();
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final feed = context.watch<FeedProvider>();
    final currentUser = auth.currentUser!;
    final replies = feed.repliesOf(widget.post.id);

    // Pega estado atualizado do post
    final livePost = feed.allPosts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Postagem',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Post principal + respostas
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Post principal expandido
                SliverToBoxAdapter(
                  child: _DetailedPost(
                    post: livePost,
                    isOwner: currentUser.id == livePost.userId,
                    feed: feed,
                    onDelete: () => Navigator.pop(context),
                  ),
                ),

                // Divisor
                const SliverToBoxAdapter(
                  child: Divider(height: 1),
                ),

                // Título Respostas
                if (replies.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '${replies.length} ${replies.length == 1 ? 'resposta' : 'respostas'}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                // Lista de respostas
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Column(
                      children: [
                        PostCard(post: replies[i], isCompact: true),
                        const Divider(height: 1),
                      ],
                    ),
                    childCount: replies.length,
                  ),
                ),

                if (replies.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            const Text('💬',
                                style: TextStyle(fontSize: 36)),
                            const SizedBox(height: 8),
                            Text(
                              'Seja o primeiro a responder!',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),

          // Caixa de resposta fixa no fundo
          _ReplyBox(
            user: currentUser,
            controller: _replyController,
            focusNode: _focusNode,
            canSend: _canSend,
            isSending: _isSending,
            onSend: _sendReply,
            onTapField: () => _focusNode.requestFocus(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Post principal expandido
// ---------------------------------------------------------------------------
class _DetailedPost extends StatelessWidget {
  final PostModel post;
  final bool isOwner;
  final FeedProvider feed;
  final VoidCallback onDelete;

  const _DetailedPost({
    required this.post,
    required this.isOwner,
    required this.feed,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final repliesCount = feed.repliesOf(post.id).length;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Autor
          Row(
            children: [
              UserAvatar(
                avatarUrl: post.authorAvatarUrl,
                localPath: post.authorLocalAvatarPath,
                name: post.authorName,
                radius: 24,
                onTap: () {
                  final user = mockUsers.firstWhere(
                    (u) => u.id == post.userId,
                    orElse: () => mockUsers[0],
                  );
                  Navigator.pushNamed(context, AppRoutes.profile,
                      arguments: user);
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '@${post.authorLogin}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 20, color: AppColors.textSecondary),
                  onPressed: () => _confirmDelete(context),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Conteúdo
          Text(
            post.content,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Data completa
          Text(
            _formatDate(post.createdAt),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(height: 24),

          // Contadores
          Row(
            children: [
              Consumer<FeedProvider>(
                builder: (_, feedProv, __) {
                  final livePost = feedProv.allPosts.firstWhere(
                    (p) => p.id == post.id,
                    orElse: () => post,
                  );
                  return Row(
                    children: [
                      Text(
                        livePost.likesCount.toString(),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'curtidas',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 20),
              Text(
                repliesCount.toString(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'respostas',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Botões de ação
          Consumer<FeedProvider>(
            builder: (_, feedProv, __) {
              final livePost = feedProv.allPosts.firstWhere(
                (p) => p.id == post.id,
                orElse: () => post,
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DetailAction(
                    icon: livePost.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border_rounded,
                    label: livePost.isLiked ? 'Curtido' : 'Curtir',
                    color: livePost.isLiked
                        ? AppColors.liked
                        : AppColors.textSecondary,
                    onTap: () => feedProv.toggleLike(post.id),
                  ),
                  _DetailAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Responder',
                    color: AppColors.textSecondary,
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Excluir post?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Esta ação não pode ser desfeita.',
            style:
                GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              feed.deletePost(post.id);
              onDelete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post excluído')),
              );
            },
            child: Text('Excluir',
                style: GoogleFonts.inter(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} · ${date.day} de ${months[date.month - 1]}. de ${date.year}';
  }
}

class _DetailAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DetailAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Caixa de resposta fixa no fundo
// ---------------------------------------------------------------------------
class _ReplyBox extends StatelessWidget {
  final dynamic user;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onTapField;

  const _ReplyBox({
    required this.user,
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.isSending,
    required this.onSend,
    required this.onTapField,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            UserAvatar(
              avatarUrl: user.avatarUrl,
              localPath: user.localAvatarPath,
              name: user.name,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 4,
                minLines: 1,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Adicione uma resposta...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              opacity: canSend ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: canSend ? onSend : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
