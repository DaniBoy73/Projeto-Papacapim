import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Implementação específica para Flutter Web (Chrome, Edge, etc.)
/// Usa um elemento <img> nativo do navegador dentro de HtmlElementView,
/// o que ignora restrições de CORS que o CanvasKit do Flutter Web normalmente impõe.
Widget buildPlatformAvatar({
  required String imageUrl,
  required double size,
  required String fallbackText,
  required Color backgroundColor,
  required Color textColor,
  Widget? overlayBadge,
  VoidCallback? onTap,
}) {
  final hasImage = imageUrl.isNotEmpty;
  final cleanHex = backgroundColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
  final textHex = textColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
  final viewId = 'avatar-${imageUrl.hashCode}-${size.toInt()}-$cleanHex-$hasImage';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final container = web.document.createElement('div') as web.HTMLDivElement;
    container.style.width = '100%';
    container.style.height = '100%';
    container.style.borderRadius = '50%';
    container.style.position = 'relative';
    container.style.overflow = 'hidden';
    container.style.backgroundColor = '#$cleanHex';

    if (hasImage) {
      // Usuário com foto: renderiza apenas a imagem. NENHUMA LETRA sobreposta!
      final img = web.document.createElement('img') as web.HTMLImageElement;
      img.src = imageUrl;
      img.style.width = '100%';
      img.style.height = '100%';
      img.style.borderRadius = '50%';
      img.style.objectFit = 'cover';
      img.style.display = 'block';

      // Em caso de falha de carregamento no servidor, exibe a letra de fallback
      img.onError.listen((_) {
        img.style.display = 'none';
        container.style.display = 'flex';
        container.style.alignItems = 'center';
        container.style.justifyContent = 'center';
        container.style.color = '#$textHex';
        container.style.fontWeight = 'bold';
        container.style.fontSize = '${size * 0.4}px';
        container.style.userSelect = 'none';
        container.innerText = fallbackText;
      });

      container.append(img);
    } else {
      // Usuário sem foto: exibe a letra inicial perfeitamente centralizada
      container.style.display = 'flex';
      container.style.alignItems = 'center';
      container.style.justifyContent = 'center';
      container.style.color = '#$textHex';
      container.style.fontWeight = 'bold';
      container.style.fontSize = '${size * 0.4}px';
      container.style.userSelect = 'none';
      container.innerText = fallbackText;
    }

    return container;
  });

  Widget avatar = ClipOval(
    child: SizedBox(
      width: size,
      height: size,
      child: HtmlElementView(viewType: viewId),
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
