import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/photo_source_bottom_sheet.dart';
import '../routes/app_routes.dart';

/// TELA DE ALTERAÇÃO DE DADOS DO USUÁRIO (TELA EDITAR PERFIL):
/// Permite alterar nome, senha, trocar a foto de perfil (via Câmera ou Galeria)
/// e solicitar a exclusão definitiva do perfil.

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _passwordController = TextEditingController(text: '123456');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final state = AppStateProvider.of(context);
      _nameController.text = state.currentUser.name;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        final state = AppStateProvider.of(context);
        state.updateProfile(name: _nameController.text);

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      });
    }
  }

  void _showDeleteAccountDialog(BuildContext context, dynamic state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Perfil?'),
        content: const Text(
          'Esta ação removerá sua conta e todas as suas postagens permanentemente. Deseja continuar?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              state.deleteAccount();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil excluído com sucesso.'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.landing,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Sim, Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Dados do Perfil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar com Botão de Trocar Foto
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppTheme.primaryLight,
                      backgroundImage: NetworkImage(state.currentUser.avatarUrl),
                    ),
                    InkWell(
                      onTap: () {
                        PhotoSourceBottomSheet.show(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    PhotoSourceBottomSheet.show(context);
                  },
                  icon: const Icon(Icons.photo_camera_back_outlined, size: 18),
                  label: const Text('Alterar Foto de Perfil'),
                ),
                const SizedBox(height: 24),

                // Form de Edição
                CustomTextField(
                  label: 'Nome Completo',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'O nome não pode ficar em branco';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  label: 'Nova Senha (opcional)',
                  hint: 'Deixe em branco para manter a atual',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 32),

                // Botão de Salvar Alterações
                PrimaryButton(
                  text: 'Salvar Alterações',
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 40),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),

                // Área de Perigo: Excluir Perfil
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Zona de Perigo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ao excluir seu perfil, todas as suas postagens e interações serão removidas do Papacapim.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMutedColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteAccountDialog(context, state),
                          icon: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
                          label: const Text('Excluir Meu Perfil', style: TextStyle(color: AppTheme.errorColor)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.errorColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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
    );
  }
}
