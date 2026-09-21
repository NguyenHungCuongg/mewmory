import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/config/theme.dart';
import 'package:mewmory/widgets/common/mew_card.dart';
import 'package:mewmory/widgets/common/mew_text_field.dart';

void main() {
  group('Common Widgets Theme Awareness Tests', () {
    testWidgets('MewCard adapts background and border color in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: MewTheme.light,
          darkTheme: MewTheme.dark,
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: MewCard(child: Text('Card Content')),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(MewCard), matching: find.byType(Container)).first,
      );
      final boxDecoration = container.decoration as BoxDecoration;
      // In dark mode, warmTaupe is Color(0xFF1C1C1A)
      expect(boxDecoration.color, const Color(0xFF1C1C1A));
    });

    testWidgets('MewTextField adapts fillColor in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: MewTheme.light,
          darkTheme: MewTheme.dark,
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: MewTextField(hintText: 'Enter something'),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      // In dark mode, eggshell is Color(0xFF141413)
      expect(textField.decoration?.fillColor, const Color(0xFF141413));
    });
  });
}
