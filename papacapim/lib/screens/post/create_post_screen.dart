// lib/screens/post/create_post_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/user_avatar.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _controller = TextEditingController();
  static const int _maxChars = 280;
  bool _isPosting = false;

  int get _remaining => _maxChars - _controller.text.length;
  bool get _canPost =>
      _controller.text.trim().isNotEmpty && _remaining >= 0 && !_isPosting;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_canPost) return;
    FocusScope.of(context).unfocus();
    setState(() => _isPosting = true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final feed = context.read<FeedProvider>();
    final user = auth.currentUser!;

    final post = PostModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      content: _controller.text.trim(),
      authorName: user.name,
      authorLogin: user.login,
      authorAvatarUrl: user.avatarUrl,
      authorLocalAvatarPath: user.localAvatarPath,
      createdAt: DateTime.now(),
      replies: [],
    );

    feed.createPost(post);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Postagem publicada!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final progressValue = _controller.text.length / _maxChars;
    final isNearLimit = _remaining <= 20;
    final isOverLimit = _remaining < 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _canPost ? _publish : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(90, 36),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Publicar',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    avatarUrl: user.avatarUrl,
                    localPath: user.localAvatarPath,
                    name: user.name,
                    radius: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _controller,
                          maxLines: null,
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'O que está acontecendo?',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.textHint,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra inferior: progresso e contador
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Row(
              children: [
                // Círculo de progresso
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progressValue.clamp(0.0, 1.0),
                        strokeWidth: 3,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverLimit
                              ? AppColors.error
                              : isNearLimit
                                  ? Colors.orange
                                  : AppColors.primary,
                        ),
                      ),
                      if (isNearLimit)
                        Text(
                          _remaining.toString(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isOverLimit
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isOverLimit)
                  Text(
                    '${_remaining.abs()} caracteres acima do limite',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.error,
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
