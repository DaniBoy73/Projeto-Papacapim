import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// ============================================================================
/// COMPONENTE MODAL: PHOTO SOURCE BOTTOM SHEET
/// ============================================================================
/// Modal inferior que permite ao usuário escolher entre tirar foto com a Câmera
/// ou selecionar uma imagem da Galeria do celular.
/// 
/// DICA PARA SABATINA:
/// Atende ao requisito de simulação de alteração de imagem de perfil. Na Parte 2,
/// estes botões acionarão os plugins nativos `image_picker` e `camera`.
class PhotoSourceBottomSheet extends StatelessWidget {
  const PhotoSourceBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const PhotoSourceBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Alterar Foto do Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Opção 1: Câmera Mock
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              ),
              title: const Text('Tirar foto com a Câmera', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Abra o simulador de câmera do aplicativo'),
              onTap: () {
                Navigator.pop(context); // Fecha o BottomSheet
                Navigator.pushNamed(context, AppRoutes.cameraMock);
              },
            ),

            const Divider(height: 1, indent: 64),

            // Opção 2: Galeria Mock
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: AppTheme.accentColor),
              ),
              title: const Text('Escolher da Galeria', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Selecione uma foto da sua galeria simulada'),
              onTap: () {
                Navigator.pop(context); // Fecha o BottomSheet
                Navigator.pushNamed(context, AppRoutes.galleryMock);
              },
            ),
          ],
        ),
      ),
    );
  }
}
