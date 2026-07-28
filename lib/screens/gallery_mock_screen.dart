import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria de Fotos Simulada'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Selecione uma imagem da sua galeria:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ),
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
                    onTap: () {
                      state.updateAvatar(photoUrl);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto de perfil selecionada da galeria!'),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                      Navigator.pop(context);
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
