import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MewColors {
  // Surfaces
  static const eggshell = Color(0xFFFDFCFC);
  static const warmTaupe = Color(0xFFF5F3F1);
  static const stone = Color(0xFFEBE8E4);

  // Text
  static const ink = Color(0xFF000000);
  static const graphite = Color(0xFF44403B);
  static const smoke = Color(0xFF777169);
  static const ash = Color(0xFFA59F97);

  // Accents
  static const violetSpark = Color(0xFF0447FF);
  static const emberOrange = Color(0xFFFF4704);

  // Semantic
  static const success = Color(0xFF2D7D46);
  static const error = Color(0xFFD32F2F);
  static const warning = Color(0xFFED6C02);
}

class MewTheme {
  static ThemeData get light {
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.64,
        height: 1.13,
        color: MewColors.ink,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.48,
        height: 1.17,
        color: MewColors.ink,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: MewColors.ink,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.16,
        height: 1.5,
        color: MewColors.ink,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.16,
        height: 1.5,
        color: MewColors.smoke,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.14,
        height: 1.5,
        color: MewColors.smoke,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: MewColors.ash,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.14,
        height: 1.5,
        color: MewColors.ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: MewColors.eggshell,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: MewColors.ink,
        onPrimary: MewColors.eggshell,
        secondary: MewColors.smoke,
        surface: MewColors.eggshell,
        onSurface: MewColors.ink,
        error: MewColors.error,
        outline: MewColors.stone,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: MewColors.eggshell,
        foregroundColor: MewColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: MewColors.warmTaupe,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MewColors.eggshell,
        selectedItemColor: MewColors.ink,
        unselectedItemColor: MewColors.ash,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MewColors.ink,
          foregroundColor: MewColors.eggshell,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MewColors.ink,
          side: const BorderSide(color: MewColors.stone),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MewColors.eggshell,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MewColors.stone),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MewColors.stone),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MewColors.ink, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: MewColors.ash, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: MewColors.stone,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MewColors.stone,
        selectedColor: MewColors.ink,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: MewColors.graphite),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MewColors.eggshell,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MewColors.graphite,
        contentTextStyle: GoogleFonts.inter(
          color: MewColors.eggshell,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
