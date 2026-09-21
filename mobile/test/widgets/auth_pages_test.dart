import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/pages/login_page.dart';
import 'package:mewmory/pages/register_page.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Auth Pages UI Tests', () {
    testWidgets('LoginPage renders correctly and validates empty fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));

      // Verify branding and title
      expect(find.text('Mewmory'), findsOneWidget);
      expect(find.text('Sổ tay từ vựng tiếng Anh thông minh'), findsOneWidget);

      // Verify buttons
      expect(find.text('Đăng nhập'), findsWidgets);
      expect(find.text('Đăng nhập với Google'), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);

      // Tap submit with empty fields -> triggers validation error
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    });

    testWidgets('RegisterPage validates required name field',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterPage()));

      final textFields = find.byType(TextFormField);
      // Tap submit with empty name
      await tester.enterText(textFields.at(1), 'test@example.com');
      await tester.enterText(textFields.at(2), '123456');
      await tester.enterText(textFields.at(3), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Tạo tài khoản'));
      await tester.pumpAndSettle();

      expect(find.text('Họ và tên không được để trống'), findsOneWidget);

      // Enter 1 char name
      await tester.enterText(textFields.at(0), 'A');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tạo tài khoản'));
      await tester.pumpAndSettle();

      expect(find.text('Họ và tên phải có ít nhất 2 ký tự'), findsOneWidget);
    });

    testWidgets('RegisterPage renders correctly and validates password mismatch',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterPage()));

      // Verify header and button
      expect(find.text('Tạo tài khoản'), findsNWidgets(2));
      expect(find.text('Đăng nhập'), findsOneWidget);

      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(4)); // Name, Email, Password, ConfirmPassword

      // Enter valid name
      await tester.enterText(textFields.at(0), 'Nguyễn Văn A');
      // Enter valid email
      await tester.enterText(textFields.at(1), 'test@example.com');
      // Enter password
      await tester.enterText(textFields.at(2), '123456');
      // Enter mismatched confirm password
      await tester.enterText(textFields.at(3), '654321');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Tạo tài khoản'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    });
  });
}
