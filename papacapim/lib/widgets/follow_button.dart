// lib/widgets/follow_button.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Botão de seguir/deixar de seguir reutilizável.
class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isFollowing
          ? OutlinedButton(
              key: const ValueKey('following'),
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(120, 38),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                side: const BorderSide(
                    color: AppColors.textSecondary, width: 1.2),
                foregroundColor: AppColors.textPrimary,
              ),
              child: Text(
                'Seguindo',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            )
          : ElevatedButton(
              key: const ValueKey('follow'),
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 38),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Seguir',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}
