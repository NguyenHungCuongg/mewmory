import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/l10n/app_localizations.dart';
import 'package:mewmory/pages/login_page.dart';
import 'package:mewmory/pages/register_page.dart';
import 'package:mewmory/widgets/common/language_switcher.dart';

void main() {
  Widget createTestWidget(Widget child, [Locale locale = const Locale('vi')]) {
    return ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('Auth Pages UI Tests', () {
    testWidgets('LoginPage renders correctly in Vietnamese and validates empty fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage(), const Locale('vi')));
      await tester.pumpAndSettle();

      // Verify branding and LanguageSwitcher
      expect(find.text('Mewmory'), findsOneWidget);
      expect(find.byType(LanguageSwitcher), findsOneWidget);

      // Verify Vietnamese texts
      expect(find.text('Đăng nhập'), findsWidgets);
      expect(find.text('Đăng nhập với Google'), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);
      expect(find.text('hoặc'), findsOneWidget);

      // Tap submit with empty fields -> triggers validation error
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Trường này là bắt buộc'), findsNWidgets(2));
    });

    testWidgets('LoginPage renders correctly in English mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage(), const Locale('en')));
      await tester.pumpAndSettle();

      // Verify branding and LanguageSwitcher
      expect(find.text('Mewmory'), findsOneWidget);
      expect(find.byType(LanguageSwitcher), findsOneWidget);

      // Verify English texts
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('or'), findsOneWidget);

      // Tap submit with empty fields -> triggers validation error
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('This field is required'), findsNWidgets(2));
    });

    testWidgets('RegisterPage validates required name field in Vietnamese',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterPage(), const Locale('vi')));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSwitcher), findsOneWidget);
      final textFields = find.byType(TextFormField);

      // Tap submit with empty name
      await tester.enterText(textFields.at(1), 'test@example.com');
      await tester.enterText(textFields.at(2), '123456');
      await tester.enterText(textFields.at(3), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);

      // Enter 1 char name
      await tester.enterText(textFields.at(0), 'A');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Họ và tên phải có ít nhất 2 ký tự'), findsOneWidget);
    });

    testWidgets('RegisterPage renders correctly in English and validates password mismatch',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterPage(), const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.byType(LanguageSwitcher), findsOneWidget);

      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(4)); // Name, Email, Password, ConfirmPassword

      // Enter valid name
      await tester.enterText(textFields.at(0), 'Alex Nguyen');
      // Enter valid email
      await tester.enterText(textFields.at(1), 'test@example.com');
      // Enter password
      await tester.enterText(textFields.at(2), '123456');
      // Enter mismatched confirm password
      await tester.enterText(textFields.at(3), '654321');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
