import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/config/theme.dart';
import 'package:mewmory/widgets/common/app_logo.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: MewTheme.light,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppLogo Widget Tests', () {
    testWidgets('renders icon only with specified size', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AppLogo(size: 64)),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Mewmory'), findsNothing);
    });

    testWidgets('renders icon and wordmark when showWordmark is true', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AppLogo(size: 56, showWordmark: true)),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Mewmory'), findsOneWidget);
    });
  });
}
