import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/pages/add_word_page.dart';
import 'package:mewmory/providers/connectivity_provider.dart';

void main() {
  testWidgets('AddWordPage renders search input, lookup button, and manual mode toggle',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const MaterialApp(
          home: AddWordPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('Thêm từ mới'), findsOneWidget);

    // Verify Word Input & Tra cứu button
    expect(find.text('Nhập từ tiếng Anh (ví dụ: resilient)'), findsOneWidget);
    expect(find.text('Tra cứu'), findsOneWidget);

    // Verify Manual Mode button is present
    expect(find.text('Nhập thủ công'), findsOneWidget);

    // Toggle manual mode on
    await tester.tap(find.text('Nhập thủ công'));
    await tester.pumpAndSettle();

    // In manual mode, verify form fields
    expect(find.text('Phiên âm IPA (tùy chọn)'), findsOneWidget);
    expect(find.text('Loại từ'), findsOneWidget);
    expect(find.text('Cấp độ CEFR'), findsOneWidget);
    expect(find.text('Nghĩa tiếng Việt'), findsOneWidget);
    expect(find.text('Lưu từ vựng'), findsOneWidget);
  });
}
