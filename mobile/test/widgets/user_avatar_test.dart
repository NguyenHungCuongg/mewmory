import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/widgets/common/user_avatar.dart';

void main() {
  group('UserAvatar Widget Tests', () {
    testWidgets('renders initial letter of name capitalized', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'cuong'),
          ),
        ),
      );

      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('falls back to email initial if name is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: '', email: 'alex@mewmory.com'),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders ? when name and email are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    test('deterministic color calculation produces same color for same name', () {
      final color1 = UserAvatar.getBackgroundColor('Cuong');
      final color2 = UserAvatar.getBackgroundColor('Cuong');
      expect(color1, equals(color2));
      expect(UserAvatar.palette.contains(color1), isTrue);
    });

    test('deterministic color calculation works for empty string', () {
      final color = UserAvatar.getBackgroundColor('');
      expect(color, equals(UserAvatar.palette.first));
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'Bob', size: 64.0),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(UserAvatar),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, equals(64.0));
      expect(container.constraints?.maxHeight, equals(64.0));
    });
  });
}
