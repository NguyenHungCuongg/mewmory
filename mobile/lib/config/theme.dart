import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MewColors {
  // Surfaces
  static const eggshell = Color(0xFFFDFCFC);
  static const warmTaupe = Color(0xFFFDFDFB);
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

class MewColorsDark {
  // Surfaces
  static const eggshell = Color(0xFF141413);
  static const warmTaupe = Color(0xFF1C1C1A);
  static const stone = Color(0xFF2E2E2B);

  // Text
  static const ink = Color(0xFFF0F0EE);
  static const graphite = Color(0xFFC8C8C4);
  static const smoke = Color(0xFF8C8C87);
  static const ash = Color(0xFF60605C);

  // Accents
  static const violetSpark = Color(0xFF4A72FF);
  static const emberOrange = Color(0xFFFF7A52);

  // Semantic
  static const success = Color(0xFF43A047);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFB8C00);
}

@immutable
class MewThemeColors extends ThemeExtension<MewThemeColors> {
  final Color eggshell;
  final Color warmTaupe;
  final Color stone;
  final Color ink;
  final Color graphite;
  final Color smoke;
  final Color ash;
  final Color violetSpark;
  final Color emberOrange;
  final Color success;
  final Color error;
  final Color warning;

  const MewThemeColors({
    required this.eggshell,
    required this.warmTaupe,
    required this.stone,
    required this.ink,
    required this.graphite,
    required this.smoke,
    required this.ash,
    required this.violetSpark,
    required this.emberOrange,
    required this.success,
    required this.error,
    required this.warning,
  });

  static const light = MewThemeColors(
    eggshell: MewColors.eggshell,
    warmTaupe: MewColors.warmTaupe,
    stone: MewColors.stone,
    ink: MewColors.ink,
    graphite: MewColors.graphite,
    smoke: MewColors.smoke,
    ash: MewColors.ash,
    violetSpark: MewColors.violetSpark,
    emberOrange: MewColors.emberOrange,
    success: MewColors.success,
    error: MewColors.error,
    warning: MewColors.warning,
  );

  static const dark = MewThemeColors(
    eggshell: MewColorsDark.eggshell,
    warmTaupe: MewColorsDark.warmTaupe,
    stone: MewColorsDark.stone,
    ink: MewColorsDark.ink,
    graphite: MewColorsDark.graphite,
    smoke: MewColorsDark.smoke,
    ash: MewColorsDark.ash,
    violetSpark: MewColorsDark.violetSpark,
    emberOrange: MewColorsDark.emberOrange,
    success: MewColorsDark.success,
    error: MewColorsDark.error,
    warning: MewColorsDark.warning,
  );

  @override
  MewThemeColors copyWith({
    Color? eggshell,
    Color? warmTaupe,
    Color? stone,
    Color? ink,
    Color? graphite,
    Color? smoke,
    Color? ash,
    Color? violetSpark,
    Color? emberOrange,
    Color? success,
    Color? error,
    Color? warning,
  }) {
    return MewThemeColors(
      eggshell: eggshell ?? this.eggshell,
      warmTaupe: warmTaupe ?? this.warmTaupe,
      stone: stone ?? this.stone,
      ink: ink ?? this.ink,
      graphite: graphite ?? this.graphite,
      smoke: smoke ?? this.smoke,
      ash: ash ?? this.ash,
      violetSpark: violetSpark ?? this.violetSpark,
      emberOrange: emberOrange ?? this.emberOrange,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
    );
  }

  @override
  MewThemeColors lerp(ThemeExtension<MewThemeColors>? other, double t) {
    if (other is! MewThemeColors) return this;
    return MewThemeColors(
      eggshell: Color.lerp(eggshell, other.eggshell, t)!,
      warmTaupe: Color.lerp(warmTaupe, other.warmTaupe, t)!,
      stone: Color.lerp(stone, other.stone, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      graphite: Color.lerp(graphite, other.graphite, t)!,
      smoke: Color.lerp(smoke, other.smoke, t)!,
      ash: Color.lerp(ash, other.ash, t)!,
      violetSpark: Color.lerp(violetSpark, other.violetSpark, t)!,
      emberOrange: Color.lerp(emberOrange, other.emberOrange, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension MewThemeContextExtension on BuildContext {
  MewThemeColors get mewColors =>
      Theme.of(this).extension<MewThemeColors>() ?? MewThemeColors.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
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
      extensions: const [MewThemeColors.light],
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
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MewColors.ink,
          side: const BorderSide(color: MewColors.stone),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MewColors.eggshell,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  static ThemeData get dark {
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.64,
        height: 1.13,
        color: MewColorsDark.ink,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.48,
        height: 1.17,
        color: MewColorsDark.ink,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: MewColorsDark.ink,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.16,
        height: 1.5,
        color: MewColorsDark.ink,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.16,
        height: 1.5,
        color: MewColorsDark.smoke,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.14,
        height: 1.5,
        color: MewColorsDark.smoke,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: MewColorsDark.ash,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.14,
        height: 1.5,
        color: MewColorsDark.ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MewColorsDark.eggshell,
      textTheme: textTheme,
      extensions: const [MewThemeColors.dark],
      colorScheme: const ColorScheme.dark(
        primary: MewColorsDark.ink,
        onPrimary: MewColorsDark.eggshell,
        secondary: MewColorsDark.smoke,
        surface: MewColorsDark.eggshell,
        onSurface: MewColorsDark.ink,
        error: MewColorsDark.error,
        outline: MewColorsDark.stone,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: MewColorsDark.eggshell,
        foregroundColor: MewColorsDark.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: MewColorsDark.warmTaupe,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MewColorsDark.eggshell,
        selectedItemColor: MewColorsDark.ink,
        unselectedItemColor: MewColorsDark.ash,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MewColorsDark.ink,
          foregroundColor: MewColorsDark.eggshell,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MewColorsDark.ink,
          side: const BorderSide(color: MewColorsDark.stone),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MewColorsDark.eggshell,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MewColorsDark.stone),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MewColorsDark.stone),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MewColorsDark.ink, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: MewColorsDark.ash, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: MewColorsDark.stone,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MewColorsDark.stone,
        selectedColor: MewColorsDark.ink,
        labelStyle:
            GoogleFonts.inter(fontSize: 12, color: MewColorsDark.graphite),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MewColorsDark.eggshell,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MewColorsDark.warmTaupe,
        contentTextStyle: GoogleFonts.inter(
          color: MewColorsDark.ink,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
