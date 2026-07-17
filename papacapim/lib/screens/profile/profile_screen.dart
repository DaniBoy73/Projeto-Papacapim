// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/follow_button.dart';
import '../../widgets/post_card.dart';
import '../../widgets/user_avatar.dart';
import '../../data/mock_data.dart';

/// Tela de perfil que funciona tanto para o usuário logado (isOwnProfile=true)
/// quanto para outros usuários (isOwnProfile=false).
class ProfileScreen extends StatelessWidget {
  final UserModel user;
  final bool isOwnProfile;

  const ProfileScreen({
    super.key,
    required this.user,
    this.isOwnProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, FeedProvider>(
      builder: (_, auth, feed, __) {
        final currentUser = auth.currentUser;

        // Se o usuário visualizado é o próprio usuário logado
        final bool ownProfile =
            isOwnProfile || currentUser?.id == user.id;

        // Pega dados atualizados do usuário da lista global
        final liveUser =
            mockUsers.firstWhere((u) => u.id == user.id, orElse: () => user);

        final posts = feed.userPosts(liveUser.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // AppBar recolhível
              SliverAppBar(
                backgroundColor: AppColors.surface,
                pinned: true,
                expandedHeight: 0,
                leading: ownProfile
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                automaticallyImplyLeading: !ownProfile,
                title: ownProfile
                    ? null
                    : Text(
                        '@${liveUser.login}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                actions: [
                  if (ownProfile)
                    IconButton(
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.textSecondary, size: 20),
                      onPressed: () {
                        auth.logout();
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                    ),
                ],
              ),

              // Conteúdo
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  user: liveUser,
                  isOwnProfile: ownProfile,
                  onFollow: () => feed.toggleFollow(liveUser),
                ),
              ),

              // Título da seção de posts
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Text(
                    'Postagens',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                  child: Divider(height: 1)),

              // Lista de posts
              if (posts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('🐦',
                              style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            ownProfile
                                ? 'Você ainda não postou nada.'
                                : 'Nenhuma postagem ainda.',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Column(
                      children: [
                        PostCard(post: posts[i]),
                        const Divider(height: 1),
                      ],
                    ),
                    childCount: posts.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header do perfil
// ---------------------------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool isOwnProfile;
  final VoidCallback onFollow;

  const _ProfileHeader({
    required this.user,
    required this.isOwnProfile,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar grande
              UserAvatar(
                avatarUrl: user.avatarUrl,
                localPath: user.localAvatarPath,
                name: user.name,
                radius: 40,
              ),
              const Spacer(),
              // Botão de editar ou seguir
              if (isOwnProfile)
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.editProfile),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar perfil'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(
                        color: AppColors.textSecondary, width: 1.2),
                    foregroundColor: AppColors.textPrimary,
                    textStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                FollowButton(
                  isFollowing: user.isFollowing,
                  onTap: onFollow,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Nome e @login
          Text(
            user.name,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '@${user.login}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          // Bio
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              user.bio!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Seguidores / Seguindo
          Row(
            children: [
              _StatChip(count: user.followingCount, label: 'Seguindo'),
              const SizedBox(width: 20),
              _StatChip(count: user.followersCount, label: 'Seguidores'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;

  const _StatChip({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
