import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/db/database.dart';
import 'package:mewmory/widgets/vocabulary/word_card.dart';

void main() {
  group('WordCard Overflow & Layout Tests', () {
    testWidgets('WordCard does not overflow with long word (resurrection), phonetic and badges on 360px screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final item = VocabularyWithDefinitions(
        vocabulary: Vocabulary(
          id: 'test-1',
          userId: 'user-1',
          word: 'resurrection',
          phonetic: "/,rez.ə'rek.ʃən/",
          partOfSpeech: 'noun',
          cefrLevel: 'C1',
          usageRegister: 'formal',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
        ),
        definitions: [
          Definition(
            id: 'def-1',
            vocabularyId: 'test-1',
            sortOrder: 1,
            definitionVi: 'sự phục sinh, sống lại',
            example: 'The religious text describes the event...',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
          ),
        ],
        collectionIds: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: WordCard(item: item),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('resurrection'), findsOneWidget);
      expect(find.text('C1'), findsOneWidget);
      expect(find.text('noun'), findsOneWidget);
    });

    testWidgets('WordCard handles extra-long word and long part of speech on 320px narrow screen without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final item = VocabularyWithDefinitions(
        vocabulary: Vocabulary(
          id: 'test-2',
          userId: 'user-1',
          word: 'incomprehensibility',
          phonetic: '/ɪnˌkɒm.prɪˌhen.səˈbɪl.ə.ti/',
          partOfSpeech: 'preposition',
          cefrLevel: 'C2',
          usageRegister: 'technical',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
        ),
        definitions: [
          Definition(
            id: 'def-2',
            vocabularyId: 'test-2',
            sortOrder: 1,
            definitionVi: 'tính chất không thể hiểu được',
            example: 'Quantum physics is hard to grasp...',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
          ),
        ],
        collectionIds: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: WordCard(item: item),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('incomprehensibility'), findsOneWidget);
      expect(find.text('C2'), findsOneWidget);
      expect(find.text('preposition'), findsOneWidget);
    });

    testWidgets('WordCard renders short word and phonetic on single line cleanly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final item = VocabularyWithDefinitions(
        vocabulary: Vocabulary(
          id: 'test-3',
          userId: 'user-1',
          word: 'pelvis',
          phonetic: "/'pɛl.vɪs/",
          partOfSpeech: 'noun',
          cefrLevel: 'B2',
          usageRegister: 'neutral',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
        ),
        definitions: [
          Definition(
            id: 'def-3',
            vocabularyId: 'test-3',
            sortOrder: 1,
            definitionVi: 'Khung xương chậu',
            example: 'The doctor ordered an X-ray...',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
          ),
        ],
        collectionIds: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: WordCard(item: item),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('pelvis'), findsOneWidget);
      expect(find.textContaining("/'pɛl.vɪs/"), findsOneWidget);
      expect(find.text('B2'), findsOneWidget);
      expect(find.text('noun'), findsOneWidget);
    });

    testWidgets('WordCard renders without phonetic or badges gracefully',
        (WidgetTester tester) async {
      final item = VocabularyWithDefinitions(
        vocabulary: Vocabulary(
          id: 'test-4',
          userId: 'user-1',
          word: 'cervical',
          phonetic: null,
          partOfSpeech: null,
          cefrLevel: null,
          usageRegister: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
        ),
        definitions: const [],
        collectionIds: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordCard(item: item),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('cervical'), findsOneWidget);
    });
  });
}
