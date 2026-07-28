import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';

/// SIMULADOR DE CÂMERA DO CELULAR (TELA CAMERA MOCK):
/// Simula a interface da Câmera do smartphone para captura de foto de perfil.

class CameraMockScreen extends StatefulWidget {
  const CameraMockScreen({super.key});

  @override
  State<CameraMockScreen> createState() => _CameraMockScreenState();
}

class _CameraMockScreenState extends State<CameraMockScreen> {
  bool _flashOn = false;
  bool _isFrontCamera = true;
  bool _isCapturing = false;

  // Fotos de amostra simuladas para a captura
  final List<String> _samplePhotos = [
    'https://i.pravatar.cc/150?img=33',
    'https://i.pravatar.cc/150?img=68',
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=47',
  ];

  void _takePicture() {
    setState(() => _isCapturing = true);

    // Simulação do disparo da câmera e processamento da imagem
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final state = AppStateProvider.of(context);
      
      // Seleciona uma nova URL de avatar simulada
      final newAvatar = _samplePhotos[DateTime.now().second % _samplePhotos.length];
      state.updateAvatar(newAvatar);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto capturada e salva no perfil com sucesso!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Câmera Simulado', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _flashOn = !_flashOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () {
              setState(() => _isFrontCamera = !_isFrontCamera);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Viewport da Câmera Simulada
          Center(
            child: Container(
              width: double.infinity,
              height: 420,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Retículo visual de foco da câmera
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isFrontCamera ? 'Câmera Frontal HD' : 'Câmera Traseira HD',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão de Disparo / Shutter
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isCapturing ? null : _takePicture,
                  child: Container(
                    height: 80,
                    width: 80,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isCapturing ? AppTheme.accentColor : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: _isCapturing
                          ? const Center(
                              child: CircularProgressIndicator(color: AppTheme.primaryColor),
                            )
                          : const Icon(Icons.camera, size: 36, color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Toque no botão para capturar a foto',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
