import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'app_avatar_impl.dart';

/// Componente de avatar inteligente compatível com Web (Chrome, Edge) e Mobile/Desktop.
/// Na Web, renderiza o elemento <img> nativo do navegador para contornar limitações de CORS
/// do CanvasKit. Em outras plataformas, utiliza o pipeline nativo de imagens do Flutter.
class AppAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final String name;
  final Widget? overlayBadge;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const AppAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.name = '',
    this.overlayBadge,
    this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = radius * 2;
    final fallbackChar = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : '?';

    return buildPlatformAvatar(
      imageUrl: imageUrl,
      size: effectiveSize,
      fallbackText: fallbackChar,
      backgroundColor: backgroundColor ?? AppTheme.primaryLight,
      textColor: textColor ?? AppTheme.primaryColor,
      overlayBadge: overlayBadge,
      onTap: onTap,
    );
  }
}
