// lib/widgets/papacapim_logo.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Logo do Papacapim com ícone de pássaro (emoji) e tipografia customizada.
/// Suporta versão clara (para header colorido) e escura.
class PapacapimLogo extends StatelessWidget {
  final bool light;
  final double fontSize;

  const PapacapimLogo({
    super.key,
    this.light = true,
    this.fontSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Papacapim',
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: light ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '🐦',
          style: TextStyle(fontSize: fontSize * 0.85),
        ),
      ],
    );
  }
}
