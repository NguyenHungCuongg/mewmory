import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/db/daos/collection_dao.dart';
import 'package:mewmory/db/daos/vocabulary_dao.dart';
import 'package:mewmory/db/database.dart' as db;
import 'package:mewmory/pages/collection_detail_page.dart';
import 'package:mewmory/pages/collections_page.dart';
import 'package:mewmory/providers/collection_provider.dart';
import 'package:mewmory/widgets/collection/collection_card.dart';
import 'package:mewmory/widgets/collection/collection_form_sheet.dart';

void main() {
  final testCol1 = db.Collection(
    id: 'col-1',
    userId: 'user-1',
    name: 'IELTS Vocabulary',
    description: 'Từ vựng quan trọng cho bài thi IELTS',
    isDefault: true,
    isAiGenerated: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isDeleted: false,
  );

  final testColItem1 = CollectionWithCount(
    collection: testCol1,
    wordCount: 15,
  );

  final testVocab = db.Vocabulary(
    id: 'vocab-1',
    userId: 'user-1',
    word: 'ubiquitous',
    phonetic: '/juːˈbɪkwɪtəs/',
    audioUrl: null,
    partOfSpeech: 'adjective',
    cefrLevel: 'C1',
    usageRegister: 'formal',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isDeleted: false,
  );

  final testDef = db.Definition(
    id: 'def-1',
    vocabularyId: 'vocab-1',
    definitionEn: 'Present everywhere',
    definitionVi: 'Phổ biến, ở đâu cũng có',
    example: 'Smartphones are ubiquitous.',
    sortOrder: 0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isDeleted: false,
  );

  final testWordItem = VocabularyWithDefinitions(
    vocabulary: testVocab,
    definitions: [testDef],
    collectionIds: ['col-1'],
  );

  group('Collections UI Tests', () {
    testWidgets('CollectionsPage renders empty state when no collections',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCollectionsProvider
                .overrideWith((ref) => Stream.value(const [])),
          ],
          child: const MaterialApp(
            home: CollectionsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bộ sưu tập'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Chưa có bộ sưu tập nào'), findsOneWidget);
    });

    testWidgets('CollectionsPage renders collection cards with word counts',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCollectionsProvider
                .overrideWith((ref) => Stream.value([testColItem1])),
          ],
          child: const MaterialApp(
            home: CollectionsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('IELTS Vocabulary'), findsOneWidget);
      expect(find.text('15 từ'), findsOneWidget);
      expect(find.text('Mặc định'), findsOneWidget);
      expect(find.byType(CollectionCard), findsOneWidget);
    });

    testWidgets('CollectionFormSheet renders form fields in create mode',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CollectionFormSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tạo bộ sưu tập mới'), findsOneWidget);
      expect(find.text('Tên bộ sưu tập'), findsOneWidget);
      expect(find.text('Mô tả (tùy chọn)'), findsOneWidget);
      expect(find.text('Tạo'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
    });

    testWidgets('CollectionDetailPage renders collection header and words',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider('col-1')
                .overrideWith((ref) => Stream.value(testCol1)),
            wordsInCollectionProvider('col-1')
                .overrideWith((ref) => Stream.value([testWordItem])),
          ],
          child: const MaterialApp(
            home: CollectionDetailPage(id: 'col-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('IELTS Vocabulary'), findsOneWidget);
      expect(find.text('Từ vựng quan trọng cho bài thi IELTS'), findsOneWidget);
      expect(find.text('1 từ vựng'), findsOneWidget);
      expect(find.text('ubiquitous'), findsOneWidget);
      expect(find.text('Phổ biến, ở đâu cũng có'), findsOneWidget);
    });
  });
}
