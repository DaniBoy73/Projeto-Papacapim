// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Campo de texto padronizado com label flutuante e estilo do tema Papacapim.
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final int maxLines;
  final int? maxLength;
  final bool showToggleObscure;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.showToggleObscure = false,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      style: GoogleFonts.inter(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.showToggleObscure
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        counterStyle: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
