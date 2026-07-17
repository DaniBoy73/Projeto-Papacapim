// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

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
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text,
      login: _loginController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(auth.errorMessage ?? 'Erro ao criar conta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header verde-azulado
          _RegisterHeader(),

          // Formulário
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.textPrimary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Criar conta',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    _SectionLabel('NOME COMPLETO'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nome completo',
                      hint: 'Seu nome completo',
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'Mínimo 3 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _SectionLabel('LOGIN'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _loginController,
                      label: 'Login',
                      hint: 'seu_login',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe o login';
                        }
                        if (v.trim().contains(' ')) {
                          return 'Login sem espaços';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _SectionLabel('SENHA'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      hint: '••••••••',
                      obscureText: true,
                      showToggleObscure: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _SectionLabel('CONFIRMAR SENHA'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _confirmController,
                      label: 'Confirmar senha',
                      hint: '••••••••',
                      obscureText: true,
                      showToggleObscure: true,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _submit,
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return 'Senhas não conferem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Criar conta'),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'Já tem conta? '),
                              TextSpan(
                                text: 'Entrar',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        gradient: AppColors.registerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: 10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 80,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 24,
            child: Text(
              '🌿',
              style: const TextStyle(fontSize: 48),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Papacapim',
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Junte-se à comunidade',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    );
  }
}
