import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../controllers/app_state_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

/// ============================================================================
/// TELA DE LOGIN SIMULADO
/// ============================================================================
/// Permite o acesso do usuário com campos de login e senha.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController(text: 'carlos_papacapim');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulação de delay de rede
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final state = AppStateProvider.of(context);
        final success = state.login(
          _loginController.text,
          _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bem-vindo de volta, ${state.currentUser.name}!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          // Navega para o feed principal limpando a pilha de telas
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.main,
            (route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar no Papacapim'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Acesse sua conta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Digite seu login e senha para acessar o feed de postagens.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMutedColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Campo de Login / Usuário
                CustomTextField(
                  label: 'Login ou Usuário',
                  hint: 'Ex: carlos_papacapim',
                  controller: _loginController,
                  prefixIcon: Icons.alternate_email,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe seu login';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo de Senha
                CustomTextField(
                  label: 'Senha',
                  hint: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão de Entrar
                PrimaryButton(
                  text: 'Entrar',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),

                // Link para Cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ainda não tem uma conta? ',
                      style: TextStyle(color: AppTheme.textMutedColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
