// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();
  String? _localAvatarPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _nameController = TextEditingController(text: user.name);
    _bioController = TextEditingController(text: user.bio ?? '');
    _localAvatarPath = user.localAvatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Seleção de foto
  // ---------------------------------------------------------------------------
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Fecha o bottom sheet
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked != null) {
        setState(() => _localAvatarPath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao acessar câmera/galeria: $e')),
        );
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primary, size: 22),
                ),
                title: Text(
                  'Escolher da galeria',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 15),
                ),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primary, size: 22),
                ),
                title: Text(
                  'Tirar foto',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 15),
                ),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Salvar
  // ---------------------------------------------------------------------------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final feed = context.read<FeedProvider>();

    auth.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      localAvatarPath: _localAvatarPath,
    );

    // Sincroniza avatar nos posts
    if (auth.currentUser != null) {
      feed.syncUserInPosts(auth.currentUser!);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Editar perfil',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    'Salvar',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar com botão de editar
              Center(
                child: Stack(
                  children: [
                    UserAvatar(
                      avatarUrl: user.avatarUrl,
                      localPath: _localAvatarPath,
                      name: user.name,
                      radius: 52,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePicker,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.surface, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _showImagePicker,
                child: Text(
                  'Alterar foto',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campos
              CustomTextField(
                controller: _nameController,
                label: 'Nome',
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Nome muito curto'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Conte um pouco sobre você...',
                maxLines: 3,
                maxLength: 160,
              ),
              const SizedBox(height: 8),

              // Info sobre @login (não editável nesta versão)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'O login @${user.login} não pode ser alterado por aqui.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
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
    );
  }
}
