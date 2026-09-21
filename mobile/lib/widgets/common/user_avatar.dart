import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserAvatar extends StatelessWidget {
  final String? name;
  final String? email;
  final String? photoUrl;
  final double size;
  final BoxBorder? border;

  const UserAvatar({
    super.key,
    this.name,
    this.email,
    this.photoUrl,
    this.size = 40.0,
    this.border,
  });

  static const List<Color> palette = [
    Color(0xFFE07A5F), // Terracotta
    Color(0xFF588157), // Sage
    Color(0xFF4A6FA5), // Slate Blue
    Color(0xFFC68B59), // Warm Ochre
    Color(0xFF8E6E53), // Warm Umber
    Color(0xFF6D597A), // Dusty Plum
    Color(0xFF5F797B), // Muted Teal
    Color(0xFF3D3A34), // Charcoal Graphite
  ];

  static Color getBackgroundColor(String identifier) {
    if (identifier.isEmpty) return palette.first;
    int hash = 0;
    for (int i = 0; i < identifier.length; i++) {
      hash = (hash << 5) - hash + identifier.codeUnitAt(i);
      hash = hash.toSigned(32);
    }
    return palette[hash.abs() % palette.length];
  }

  static String getInitial(String? name, String? email) {
    final cleanName = name?.trim() ?? '';
    if (cleanName.isNotEmpty) {
      return cleanName[0].toUpperCase();
    }
    final cleanEmail = email?.trim() ?? '';
    if (cleanEmail.isNotEmpty) {
      return cleanEmail[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final identifier = (name?.trim().isNotEmpty == true)
        ? name!.trim()
        : (email?.trim().isNotEmpty == true ? email!.trim() : '');
    final initial = getInitial(name, email);
    final bgColor = getBackgroundColor(identifier);

    Widget fallbackAvatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
    );

    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!.trim(),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallbackAvatar,
        ),
      );
    }

    return fallbackAvatar;
  }
}
