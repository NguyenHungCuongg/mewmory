import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final double borderRadius;

  const AppLogo({
    super.key,
    this.size = 56.0,
    this.showWordmark = false,
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;

    final logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.warmTaupe,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.stone, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/branding/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.menu_book_rounded,
          size: size * 0.5,
          color: colors.ink,
        ),
      ),
    );

    if (!showWordmark) {
      return logoIcon;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoIcon,
        const SizedBox(height: 14),
        Text(
          'Mewmory',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.64,
            color: colors.ink,
          ),
        ),
      ],
    );
  }
}
