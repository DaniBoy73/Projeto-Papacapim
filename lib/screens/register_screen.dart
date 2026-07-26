import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../controllers/app_state_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

/// ============================================================================
/// TELA DE CADASTRO SIMULADO
/// ============================================================================
/// Form para registro de novos usuários no Papacapim.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Delay para efeito visual de carregamento
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final state = AppStateProvider.of(context);
        final success = state.register(
          _nameController.text,
          _loginController.text,
          _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta criada com sucesso! Seja bem-vindo ao Papacapim.'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
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
        title: const Text('Criar Conta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Junte-se ao Papacapim',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Preencha seus dados abaixo para criar o seu perfil.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMutedColor,
                  ),
                ),
                const SizedBox(height: 28),

                // Nome Completo
                CustomTextField(
                  label: 'Nome Completo',
                  hint: 'Ex: Maria Oliveira',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Informe seu nome completo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Login / @handle
                CustomTextField(
                  label: 'Login de Usuário (@handle)',
                  hint: 'Ex: maria_dev',
                  controller: _loginController,
                  prefixIcon: Icons.alternate_email,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Informe o login desejado';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Senha
                CustomTextField(
                  label: 'Senha',
                  hint: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (val) {
                    if (val == null || val.trim().length < 4) {
                      return 'A senha deve ter pelo menos 4 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Confirmar Senha
                CustomTextField(
                  label: 'Confirmar Senha',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão Cadastrar
                PrimaryButton(
                  text: 'Criar Minha Conta',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),

                // Link para Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já possui uma conta? ',
                      style: TextStyle(color: AppTheme.textMutedColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: const Text(
                        'Entrar',
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
