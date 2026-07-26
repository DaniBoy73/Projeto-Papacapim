import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../widgets/primary_button.dart';

/// ============================================================================
/// TELA INITIAL: LANDING PAGE
/// ============================================================================
/// Apresenta o aplicativo Papacapim com botões para Entrar ou Cadastrar-se.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            children: [
              const Spacer(),

              // Ícone da marca Papacapim
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flutter_dash, // Ícone simpático da ave/mascote
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // Nome do App e Tagline
              const Text(
                'Papacapim',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A sua rede social simples, rápida e conectada. Compartilhe o que está acontecendo agora.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMutedColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Botões de Entrada
              PrimaryButton(
                text: 'Entrar na minha conta',
                icon: Icons.login,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                text: 'Criar nova conta',
                isOutlined: true,
                icon: Icons.person_add_outlined,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
