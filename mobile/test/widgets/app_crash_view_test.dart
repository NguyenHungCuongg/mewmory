import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/config/theme.dart';
import 'package:mewmory/widgets/common/app_crash_view.dart';

void main() {
  group('AppCrashView Widget Tests', () {
    testWidgets('renders friendly crash UI when FlutterErrorDetails provided', (tester) async {
      final details = FlutterErrorDetails(
        exception: Exception('Simulated test crash'),
        stack: StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: MewTheme.light,
          home: AppCrashView(details: details),
        ),
      );

      expect(find.text('Đã có sự cố xảy ra'), findsOneWidget);
      expect(
        find.text('Ứng dụng gặp sự cố ngoài dự kiến. Dữ liệu của bạn vẫn an toàn.'),
        findsOneWidget,
      );
      expect(find.text('Thử tải lại'), findsOneWidget);
    });

    testWidgets('ErrorWidget.builder displays AppCrashView on build exception', (tester) async {
      final originalBuilder = ErrorWidget.builder;
      ErrorWidget.builder = (details) => AppCrashView(details: details);

      // Widget that throws on build
      await tester.pumpWidget(
        MaterialApp(
          theme: MewTheme.light,
          home: Builder(
            builder: (context) {
              throw Exception('Widget crash simulation');
            },
          ),
        ),
      );

      // Absorb the simulated exception in test binding
      final exception = tester.takeException();
      expect(exception, isNotNull);

      // Verify the friendly error view caught it
      expect(find.text('Đã có sự cố xảy ra'), findsOneWidget);

      // Restore original builder
      ErrorWidget.builder = originalBuilder;
    });
  });
}
