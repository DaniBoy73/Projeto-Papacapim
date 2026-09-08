import 'package:flutter/material.dart';

/// Implementação para plataformas não-web (Mobile, Desktop, Testes de Widget)
Widget buildPlatformAvatar({
  required String imageUrl,
  required double size,
  required String fallbackText,
  required Color backgroundColor,
  required Color textColor,
  Widget? overlayBadge,
  VoidCallback? onTap,
}) {
  Widget avatar = CircleAvatar(
    radius: size / 2,
    backgroundColor: backgroundColor,
    backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
    onBackgroundImageError: (_, _) {},
    child: Text(
      fallbackText,
      style: TextStyle(
        fontSize: size * 0.4,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    ),
  );

  if (overlayBadge != null) {
    avatar = Stack(
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: overlayBadge,
        ),
      ],
    );
  }

  if (onTap != null) {
    avatar = GestureDetector(onTap: onTap, child: avatar);
  }

  return SizedBox(
    width: size,
    height: size,
    child: avatar,
  );
}
