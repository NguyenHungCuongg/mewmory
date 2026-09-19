import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/db/daos/vocabulary_dao.dart';
import 'package:mewmory/db/database.dart' as db;
import 'package:mewmory/pages/word_detail_page.dart';
import 'package:mewmory/providers/services_provider.dart';
import 'package:mewmory/providers/vocabulary_provider.dart';

void main() {
  final testVocab = db.Vocabulary(
    id: 'test-vocab-1',
    userId: 'user-1',
    word: 'resilient',
    phonetic: '/rɪˈzɪliənt/',
    audioUrl: null,
    partOfSpeech: 'adjective',
    cefrLevel: 'C1',
    usageRegister: 'neutral',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isDeleted: false,
  );

  final testDef = db.Definition(
    id: 'test-def-1',
    vocabularyId: 'test-vocab-1',
    definitionEn: 'Able to withstand or recover quickly',
    definitionVi: 'Kiên cường, mau hồi phục',
    example: 'She is very resilient.',
    sortOrder: 0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isDeleted: false,
  );

  final testItem = VocabularyWithDefinitions(
    vocabulary: testVocab,
    definitions: [testDef],
    collectionIds: const [],
  );

  testWidgets('WordDetailPage renders word details, tags, and definitions in view mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vocabularyDetailProvider('test-vocab-1')
              .overrideWith((ref) => Stream.value(testItem)),
          allCollectionsProvider
              .overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(
          home: WordDetailPage(id: 'test-vocab-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify word and phonetic
    expect(find.text('resilient'), findsWidgets);
    expect(find.text('/rɪˈzɪliənt/'), findsOneWidget);

    // Verify badges
    expect(find.text('ADJECTIVE'), findsOneWidget);
    expect(find.text('C1'), findsOneWidget);
    expect(find.text('neutral'), findsOneWidget);

    // Verify definitions
    expect(find.text('Kiên cường, mau hồi phục'), findsOneWidget);
    expect(find.text('Able to withstand or recover quickly'), findsOneWidget);
    expect(find.text('"She is very resilient."'), findsOneWidget);

    // Verify view mode buttons
    expect(find.text('Chỉnh sửa'), findsOneWidget);
    expect(find.text('Xóa từ'), findsOneWidget);
  });

  testWidgets('WordDetailPage enters and cancels edit mode cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vocabularyDetailProvider('test-vocab-1')
              .overrideWith((ref) => Stream.value(testItem)),
          allCollectionsProvider
              .overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(
          home: WordDetailPage(id: 'test-vocab-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Chỉnh sửa" button to enter edit mode
    await tester.tap(find.text('Chỉnh sửa'));
    await tester.pumpAndSettle();

    // Verify edit mode AppBar and buttons
    expect(find.text('Chỉnh sửa từ vựng'), findsOneWidget);
    expect(find.text('Lưu thay đổi'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
    expect(find.text('Danh sách định nghĩa'), findsOneWidget);

    // Tap "Hủy" to exit edit mode
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();

    // Back in view mode
    expect(find.text('Chỉnh sửa'), findsOneWidget);
    expect(find.text('Xóa từ'), findsOneWidget);
  });

  testWidgets('WordDetailPage shows empty state when word is not found',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vocabularyDetailProvider('missing-id')
              .overrideWith((ref) => Stream.value(null)),
          allCollectionsProvider
              .overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(
          home: WordDetailPage(id: 'missing-id'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Từ vựng không tồn tại'), findsOneWidget);
    expect(find.text('Quay lại danh sách'), findsOneWidget);
  });
}
