import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';
import '../routes/app_routes.dart';
import 'avatar/app_avatar.dart';

/// ============================================================================
/// WIDGET REUTILIZÁVEL: USER TILE
/// ============================================================================
/// Exibe um card/item de usuário na tela de busca ou lista de sugestões com
/// botão dinâmico de Seguir/Deixar de Seguir.
class UserTile extends StatelessWidget {
  final UserModel user;

  const UserTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final displayUser = state.getUserByLogin(user.login, fallback: user);
    final isMe = displayUser.login.toLowerCase() == state.currentUser.login.toLowerCase() ||
        displayUser.id.toLowerCase() == state.currentUser.id.toLowerCase();

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.profile,
            arguments: displayUser,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar do Usuário
              AppAvatar(
                imageUrl: displayUser.avatarUrl,
                radius: 24,
                name: displayUser.name,
              ),
              const SizedBox(width: 12),

              // Nome e Handle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayUser.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@${displayUser.login}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMutedColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Botão de Ação: Editar ou Seguir/Seguindo
              if (isMe)
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editProfile);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  child: const Text('Você', style: TextStyle(fontSize: 12)),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    state.toggleFollow(displayUser.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: displayUser.isFollowedByCurrentUser
                        ? Colors.grey.shade200
                        : AppTheme.primaryColor,
                    foregroundColor: displayUser.isFollowedByCurrentUser
                        ? AppTheme.textColor
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    displayUser.isFollowedByCurrentUser ? 'Seguindo' : 'Seguir',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: displayUser.isFollowedByCurrentUser
                          ? AppTheme.textColor
                          : Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
