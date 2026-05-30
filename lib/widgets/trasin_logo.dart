import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class TrasinLogo extends StatelessWidget {
  final double fontSize;

  const TrasinLogo({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Trasin',
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: AppTheme.primary,
        letterSpacing: -0.5,
      ),
    );
  }
}
