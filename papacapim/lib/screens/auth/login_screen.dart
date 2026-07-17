// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _loginController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Erro ao entrar.')),
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
          // Header com gradiente
          _LoginHeader(),

          // Formulário
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Entrar na conta',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 28),

                    // Campo login
                    _SectionLabel('LOGIN'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _loginController,
                      label: 'Login',
                      hint: 'seu_login',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Informe o login' : null,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                    ),
                    const SizedBox(height: 16),

                    // Campo senha
                    _SectionLabel('SENHA'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: 'Senha',
                      hint: '••••••••',
                      obscureText: true,
                      showToggleObscure: true,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a senha' : null,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _submit,
                    ),
                    const SizedBox(height: 28),

                    // Botão entrar
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Entrar'),
                    ),
                    const SizedBox(height: 20),

                    // Link para cadastro
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.register),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'Não tem conta? '),
                              TextSpan(
                                text: 'Cadastre-se',
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

                    // Dica de login mockado
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Contas de demo',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Login: carloshenrique\nSenha: 123456\n\n'
                            'Outros logins disponíveis:\nanalima, robertofarias, julicosta, patriciamendes, felipetorres',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
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

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 24,
            child: Text(
              '🐦',
              style: const TextStyle(fontSize: 52),
            ),
          ),
          // Texto
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Papacapim',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sua rede, sua voz',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.88),
                    fontWeight: FontWeight.w400,
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
