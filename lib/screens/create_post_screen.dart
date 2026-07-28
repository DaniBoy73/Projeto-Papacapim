import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';

/// TELA DE CRIAR POSTAGEM E RESPOSTA:
/// Interface para digitação de texto com suporte a limite de caracteres e
/// vinculação de respostas a postagens existentes.

class CreatePostScreen extends StatefulWidget {
  final PostModel? replyToPost;

  const CreatePostScreen({
    super.key,
    this.replyToPost,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final int _maxCharacters = 280;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _handlePublish() {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreva algo antes de publicar!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final state = AppStateProvider.of(context);
      state.addPost(text, replyToPost: widget.replyToPost);

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.replyToPost != null
                ? 'Sua resposta foi enviada!'
                : 'Postagem publicada no Papacapim!',
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isReply = widget.replyToPost != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isReply ? 'Responder Postagem' : 'Nova Postagem'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
            child: ElevatedButton(
              onPressed: _contentController.text.trim().isNotEmpty && !_isLoading
                  ? _handlePublish
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isReply ? 'Responder' : 'Publicar',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de resposta (se estiver respondendo a um post)
              if (isReply) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.reply, color: AppTheme.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Respondendo a @${widget.replyToPost!.authorLogin}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '"${widget.replyToPost!.content}"',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMutedColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Área de texto com Avatar do autor
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primaryLight,
                    backgroundImage: NetworkImage(state.currentUser.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLength: _maxCharacters,
                      maxLines: 6,
                      minLines: 3,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: isReply
                            ? 'Escreva sua resposta...'
                            : 'O que está acontecendo no momento?',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Contador de Caracteres e Dica
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.public, size: 16, color: AppTheme.textMutedColor),
                      SizedBox(width: 4),
                      Text(
                        'Visível para todos no Papacapim',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMutedColor),
                      ),
                    ],
                  ),
                  Text(
                    '${_contentController.text.length}/$_maxCharacters',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _contentController.text.length > _maxCharacters - 20
                          ? AppTheme.accentColor
                          : AppTheme.textMutedColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
