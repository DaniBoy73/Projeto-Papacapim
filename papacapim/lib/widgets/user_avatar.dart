// lib/widgets/user_avatar.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

/// Avatar de usuário com suporte a:
/// - Foto local (File do image_picker)
/// - URL de rede (cached)
/// - Fallback com iniciais coloridas
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? localPath;
  final String name;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.localPath,
    required this.name,
    this.radius = 22,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (localPath != null && localPath!.isNotEmpty) {
      // Foto local (image_picker)
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(localPath!)),
      );
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      // Foto de rede
      avatar = CircleAvatar(
        radius: radius,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildInitials(),
            errorWidget: (_, __, ___) => _buildInitials(),
          ),
        ),
      );
    } else {
      // Fallback com iniciais
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: _colorFromName(name),
        child: Text(
          _initials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.65,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  Widget _buildInitials() => Container(
        width: radius * 2,
        height: radius * 2,
        color: _colorFromName(name),
        child: Center(
          child: Text(
            _initials(name),
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.65,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _colorFromName(String name) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      const Color(0xFF7B5EA7),
      const Color(0xFF3A86FF),
      const Color(0xFFFF6B6B),
      const Color(0xFF06D6A0),
    ];
    int hash = 0;
    for (final c in name.codeUnits) {
      hash = (hash * 31 + c) & 0xFFFFFF;
    }
    return colors[hash % colors.length];
  }
}
