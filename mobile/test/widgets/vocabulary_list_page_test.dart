import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/pages/vocabulary_list_page.dart';
import 'package:mewmory/providers/vocabulary_provider.dart';

void main() {
  testWidgets('VocabularyListPage renders search bar, FAB, and empty state when empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vocabularyListProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(
          home: VocabularyListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('Từ vựng'), findsOneWidget);

    // Verify Search bar
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Tìm kiếm từ hoặc nghĩa tiếng Việt...'), findsOneWidget);

    // Verify FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify Empty State
    expect(find.text('Chưa có từ vựng nào'), findsOneWidget);
    expect(find.text('Thêm từ đầu tiên'), findsOneWidget);

    // Tap filter button to open bottom sheet
    await tester.tap(find.byIcon(Icons.filter_list_rounded));
    await tester.pumpAndSettle();

    // Verify FilterSheet opens
    expect(find.text('Bộ lọc & Sắp xếp'), findsOneWidget);
    expect(find.text('Cấp độ (CEFR)'), findsOneWidget);
    expect(find.text('Loại từ'), findsOneWidget);
  });
}
