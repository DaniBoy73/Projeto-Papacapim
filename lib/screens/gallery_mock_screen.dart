import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';
import '../widgets/photo_source_bottom_sheet.dart';

/// SIMULADOR DE GALERIA DE FOTOS DO CELULAR (TELA GALERIA MOCK):
/// Simula a grade de fotos da galeria do dispositivo para escolha de avatar.

class GalleryMockScreen extends StatelessWidget {
  const GalleryMockScreen({super.key});

  final List<String> _galleryPhotos = const [
    'https://i.pravatar.cc/150?img=11',
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=33',
    'https://i.pravatar.cc/150?img=47',
    'https://i.pravatar.cc/150?img=68',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=9',
    'https://i.pravatar.cc/150?img=13',
    'https://i.pravatar.cc/150?img=22',
  ];

  static const String _sampleBase64Image =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria de Fotos'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    PhotoSourceBottomSheet.pickAndUploadImage(
                      context,
                      source: ImageSource.gallery,
                      state: state,
                      messenger: ScaffoldMessenger.of(context),
                    );
                  },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Abrir Arquivo do Dispositivo / Galeria Real'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ou escolha uma foto de simulação:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _galleryPhotos.length,
                itemBuilder: (context, index) {
                  final photoUrl = _galleryPhotos[index];
                  final isSelected = state.currentUser.avatarUrl == photoUrl;

                  return GestureDetector(
                    onTap: () async {
                      await state.updateAvatar(photoUrl, imageData: _sampleBase64Image);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Foto de perfil selecionada e salva no back-end!'),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: isSelected
                          ? Container(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 32,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
