import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';
import '../routes/app_routes.dart';
import 'photo_source_bottom_sheet.dart';

/// WIDGET REUTILIZÁVEL: Cabeçalho do Perfil
/// Renderiza o cabeçalho completo do perfil do usuário com foto, nome, estatísticas
/// de seguidores/seguidos e botões de ação.

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isMe = user.id == state.currentUser.id;

    // Se for o próprio usuário, pega as estatísticas atualizadas em tempo real do AppState
    final displayUser = isMe ? state.currentUser : user;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Avatar com selo de Câmera (se for o próprio perfil)
          Stack(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: AppTheme.primaryLight,
                backgroundImage: NetworkImage(displayUser.avatarUrl),
              ),
              if (isMe)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      PhotoSourceBottomSheet.show(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Nome e @login
          Text(
            displayUser.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '@${displayUser.login}',
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textMutedColor,
            ),
          ),
          const SizedBox(height: 16),

          // Contadores de Seguidores e Seguidos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('Seguidores', displayUser.followersCount),
              Container(
                height: 24,
                width: 1,
                color: const Color(0xFFE2E8F0),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem('Seguindo', displayUser.followingCount),
            ],
          ),
          const SizedBox(height: 18),

          // Botão de Ação: Editar Perfil ou Seguir/Seguindo
          SizedBox(
            width: 200,
            child: isMe
                ? OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar Perfil'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      state.toggleFollow(displayUser.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: displayUser.isFollowedByCurrentUser
                          ? Colors.grey.shade200
                          : AppTheme.primaryColor,
                      foregroundColor: displayUser.isFollowedByCurrentUser
                          ? AppTheme.textColor
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      displayUser.isFollowedByCurrentUser ? 'Seguindo' : 'Seguir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: displayUser.isFollowedByCurrentUser
                            ? AppTheme.textColor
                            : Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textMutedColor,
          ),
        ),
      ],
    );
  }
}
