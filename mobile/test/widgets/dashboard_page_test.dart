import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/db/daos/vocabulary_dao.dart';
import 'package:mewmory/db/database.dart' as db;
import 'package:mewmory/pages/dashboard_page.dart';
import 'package:mewmory/providers/stats_provider.dart';
import 'package:mewmory/widgets/dashboard/daily_review_card.dart';
import 'package:mewmory/widgets/dashboard/stats_summary_card.dart';

void main() {
  final testVocab = db.Vocabulary(
    id: 'vocab-review-1',
    userId: 'user-1',
    word: 'serendipity',
    phonetic: '/ˌser.ənˈdɪp.ə.ti/',
    audioUrl: null,
    partOfSpeech: 'noun',
    cefrLevel: 'C2',
    usageRegister: 'neutral',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isDeleted: false,
  );

  final testDef = db.Definition(
    id: 'def-review-1',
    vocabularyId: 'vocab-review-1',
    definitionEn: 'Finding valuable things unexpectedly',
    definitionVi: 'Sự tình cờ may mắn',
    example: 'A fortunate serendipity.',
    sortOrder: 0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isDeleted: false,
  );

  final testWordItem = VocabularyWithDefinitions(
    vocabulary: testVocab,
    definitions: [testDef],
    collectionIds: const [],
  );

  group('Dashboard UI Tests', () {
    testWidgets('DashboardPage renders greeting, daily review, and stats summary',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            totalWordCountProvider('').overrideWith((ref) => Future.value(42)),
            wordsLearnedThisWeekProvider('')
                .overrideWith((ref) => Future.value(7)),
            levelDistributionProvider('')
                .overrideWith((ref) => Future.value({'B2': 20, 'C1': 22})),
            dailyReviewWordProvider
                .overrideWith(() => _MockDailyReviewNotifier(testWordItem)),
          ],
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and greeting
      expect(find.text('Mewmory'), findsOneWidget);
      expect(find.textContaining('Xin chào'), findsOneWidget);

      // Check cards
      expect(find.byType(DailyReviewCard), findsOneWidget);
      expect(find.byType(StatsSummaryCard), findsOneWidget);

      // Check review word
      expect(find.text('serendipity'), findsOneWidget);
      expect(find.text('/ˌser.ənˈdɪp.ə.ti/'), findsOneWidget);
      expect(find.text('Sự tình cờ may mắn'), findsOneWidget);

      // Check stats
      expect(find.text('42'), findsOneWidget);
      expect(find.text('+7 tuần này'), findsOneWidget);
    });

    testWidgets('DailyReviewCard can switch to flashcard mode and flip card',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyReviewWordProvider
                .overrideWith(() => _MockDailyReviewNotifier(testWordItem)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DailyReviewCard(userId: 'user-1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially gentle mode shows definition directly
      expect(find.text('Sự tình cờ may mắn'), findsOneWidget);

      // Switch to flashcard mode
      await tester.tap(find.text('Thẻ nhớ'));
      await tester.pumpAndSettle();

      // In flashcard mode initially hidden
      expect(find.text('Chạm để lật thẻ xem nghĩa'), findsOneWidget);

      // Tap card or 'Lật thẻ' button to reveal definition
      await tester.tap(find.text('Lật thẻ'));
      await tester.pumpAndSettle();

      expect(find.text('Sự tình cờ may mắn'), findsOneWidget);
    });
  });
}

class _MockDailyReviewNotifier extends DailyReviewNotifier {
  final VocabularyWithDefinitions? initial;
  _MockDailyReviewNotifier(this.initial);

  @override
  Future<VocabularyWithDefinitions?> build() async => initial;
}
