import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/config/theme.dart';

void main() {
  group('MewTheme & MewThemeColors Tests', () {
    test('MewTheme.light provides valid light theme and extensions', () {
      final light = MewTheme.light;
      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, MewColors.eggshell);

      final colors = light.extension<MewThemeColors>();
      expect(colors, isNotNull);
      expect(colors!.eggshell, const Color(0xFFFDFCFC));
      expect(colors.ink, const Color(0xFF000000));
      expect(colors.warmTaupe, const Color(0xFFF5F3F1));
      expect(colors.stone, const Color(0xFFEBE8E4));
    });

    test('MewTheme.dark provides valid dark theme with inverted warm palette', () {
      final dark = MewTheme.dark;
      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, const Color(0xFF141413));

      final colors = dark.extension<MewThemeColors>();
      expect(colors, isNotNull);
      expect(colors!.eggshell, const Color(0xFF141413));
      expect(colors.warmTaupe, const Color(0xFF1C1C1A));
      expect(colors.stone, const Color(0xFF2E2E2B));
      expect(colors.ink, const Color(0xFFF0F0EE));
      expect(colors.graphite, const Color(0xFFC8C8C4));
      expect(colors.smoke, const Color(0xFF8C8C87));
      expect(colors.ash, const Color(0xFF60605C));
      expect(colors.violetSpark, const Color(0xFF4A72FF));
      expect(colors.emberOrange, const Color(0xFFFF7A52));
    });

    testWidgets('MewThemeContextExtension provides easy access to colors', (tester) async {
      late MewThemeColors colors;
      late bool isDark;

      await tester.pumpWidget(
        MaterialApp(
          theme: MewTheme.light,
          darkTheme: MewTheme.dark,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              colors = context.mewColors;
              isDark = context.isDark;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isDark, isTrue);
      expect(colors.eggshell, const Color(0xFF141413));
      expect(colors.ink, const Color(0xFFF0F0EE));
    });
  });
}
