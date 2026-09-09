import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state.dart';
import '../controllers/app_state_provider.dart';

/// COMPONENTE MODAL: Seletor de foto de perfil
/// Permite escolher uma foto real do dispositivo:
/// - Windows: Abre o Explorador de Arquivos do Windows (Open File Dialog)
/// - Android/iOS: Abre a Galeria do celular ou Google Fotos / Seletor do sistema
/// - Web: Abre o seletor nativo de arquivos do navegador
/// Também oferece opção de Câmera nativa do dispositivo.

class PhotoSourceBottomSheet extends StatelessWidget {
  final String? currentName;

  const PhotoSourceBottomSheet({
    super.key,
    this.currentName,
  });

  static void show(BuildContext context, {String? currentName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PhotoSourceBottomSheet(currentName: currentName),
    );
  }

  /// Executa o fluxo real de seleção de imagem e envio para o back-end
  static Future<void> pickAndUploadImage(
    BuildContext context, {
    required ImageSource source,
    required AppState state,
    required ScaffoldMessengerState messenger,
    String? currentName,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file == null) {
        // Usuário fechou ou cancelou o explorador / seletor
        return;
      }

      final bytes = await file.readAsBytes();

      // Limite especificado na documentação da API Papacapim: máximo 5 MB
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('A imagem selecionada excede o limite máximo de 5 MB.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text('Enviando nova foto de perfil para o servidor...'),
              ),
            ],
          ),
          duration: Duration(seconds: 20),
        ),
      );

      final base64Image = base64Encode(bytes);
      final success = await state.updateAvatar(
        '', // A API gerará a URL webp definitiva
        imageData: base64Image,
        name: currentName,
      );

      messenger.hideCurrentSnackBar();

      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil atualizada com sucesso no back-end!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Erro ao salvar nova foto no servidor.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      final errorStr = e.toString();

      // No Windows desktop, a câmera nativa não possui driver direto no plugin
      if (source == ImageSource.camera &&
          (errorStr.contains('UnimplementedError') || errorStr.contains('not supported'))) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'A câmera nativa não está disponível no Windows. '
              'Escolha uma foto do Explorador de Arquivos ou use a Câmera Simulada.',
            ),
            backgroundColor: AppTheme.accentColor,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Não foi possível carregar o arquivo: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final messenger = ScaffoldMessenger.of(context);

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

            // Opção 1: Escolher da Galeria / Arquivos (REAL)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              ),
              title: const Text(
                'Escolher da Galeria / Arquivos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Explorador do Windows, Google Fotos ou Galeria do celular',
                style: TextStyle(fontSize: 13),
              ),
              onTap: () {
                Navigator.pop(context);
                pickAndUploadImage(
                  context,
                  source: ImageSource.gallery,
                  state: state,
                  messenger: messenger,
                  currentName: currentName,
                );
              },
            ),

            const Divider(height: 1, indent: 64),

            // Opção 2: Tirar foto com a Câmera (REAL)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: AppTheme.accentColor),
              ),
              title: const Text(
                'Tirar foto com a Câmera',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Abre a câmera do dispositivo',
                style: TextStyle(fontSize: 13),
              ),
              onTap: () {
                Navigator.pop(context);
                pickAndUploadImage(
                  context,
                  source: ImageSource.camera,
                  state: state,
                  messenger: messenger,
                  currentName: currentName,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
