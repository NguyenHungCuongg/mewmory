import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/config/theme.dart';
import 'package:mewmory/utils/mew_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  Widget buildTestHost({
    required ThemeMode themeMode,
    required void Function(BuildContext context) onTrigger,
  }) {
    return MaterialApp(
      theme: MewTheme.light,
      darkTheme: MewTheme.dark,
      themeMode: themeMode,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => onTrigger(context),
            child: const Text('Trigger Toast'),
          ),
        ),
      ),
    );
  }

  group('MewToast Widget Tests', () {
    testWidgets('showSuccess displays high-contrast toast in Light Mode',
        (tester) async {
      await tester.pumpWidget(
        buildTestHost(
          themeMode: ThemeMode.light,
          onTrigger: (context) {
            MewToast.showSuccess(context, 'Cập nhật thành công');
          },
        ),
      );

      await tester.tap(find.text('Trigger Toast'));
      await tester.pump(); // Start SnackBar animation
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Cập nhật thành công'), findsOneWidget);

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);

      final SnackBar snackBar = tester.widget(snackBarFinder);
      final textWidget = tester.widget<Text>(find.text('Cập nhật thành công'));

      // Verify text color and background color are NOT identical
      expect(snackBar.backgroundColor, isNotNull);
      expect(textWidget.style?.color, isNotNull);
      expect(textWidget.style!.color, isNot(equals(snackBar.backgroundColor)));
    });

    testWidgets(
        'showSuccess displays high-contrast toast in Dark Mode (no white-on-white)',
        (tester) async {
      await tester.pumpWidget(
        buildTestHost(
          themeMode: ThemeMode.dark,
          onTrigger: (context) {
            MewToast.showSuccess(context, 'Đã cập nhật tên hiển thị');
          },
        ),
      );

      await tester.tap(find.text('Trigger Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Đã cập nhật tên hiển thị'), findsOneWidget);

      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      final textWidget = tester.widget<Text>(find.text('Đã cập nhật tên hiển thị'));

      // The background in dark mode MUST NOT be white / light cream
      expect(snackBar.backgroundColor, isNot(equals(const Color(0xFFF0F0EE))));
      expect(snackBar.backgroundColor, isNot(equals(Colors.white)));

      // Text color must be defined and contrasting
      expect(textWidget.style?.color, isNotNull);
      expect(textWidget.style!.color, isNot(equals(snackBar.backgroundColor)));
    });

    testWidgets(
        'showError translates AuthException and formats user-friendly toast',
        (tester) async {
      await tester.pumpWidget(
        buildTestHost(
          themeMode: ThemeMode.light,
          onTrigger: (context) {
            MewToast.showError(
              context,
              const AuthException('Invalid login credentials'),
              prefix: 'Đăng nhập thất bại',
            );
          },
        ),
      );

      await tester.tap(find.text('Trigger Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(
        find.text('Đăng nhập thất bại: Email hoặc mật khẩu không chính xác.'),
        findsOneWidget,
      );
    });

    testWidgets('showInfo displays high-contrast toast in Dark Mode',
        (tester) async {
      await tester.pumpWidget(
        buildTestHost(
          themeMode: ThemeMode.dark,
          onTrigger: (context) {
            MewToast.showInfo(context, 'Thông tin thông báo');
          },
        ),
      );

      await tester.tap(find.text('Trigger Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Thông tin thông báo'), findsOneWidget);

      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      final textWidget = tester.widget<Text>(find.text('Thông tin thông báo'));

      expect(snackBar.backgroundColor, isNot(equals(textWidget.style!.color)));
    });
  });
}
