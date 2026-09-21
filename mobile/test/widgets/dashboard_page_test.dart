import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/config/theme.dart';
import 'package:mewmory/db/daos/vocabulary_dao.dart';
import 'package:mewmory/db/database.dart' as db;
import 'package:mewmory/l10n/app_localizations.dart';
import 'package:mewmory/pages/dashboard_page.dart';
import 'package:mewmory/providers/auth_provider.dart';
import 'package:mewmory/providers/stats_provider.dart';
import 'package:mewmory/widgets/dashboard/daily_review_card.dart';
import 'package:mewmory/widgets/dashboard/stats_summary_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    testWidgets(
        'DailyReviewCard renders without overflow in Vietnamese on narrow 360dp screen',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyReviewWordProvider
                .overrideWith(() => _MockDailyReviewNotifier(testWordItem)),
          ],
          child: MaterialApp(
            theme: MewTheme.light,
            darkTheme: MewTheme.dark,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('vi'),
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DailyReviewCard(userId: 'user-1'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Vietnamese title and toggle options
      expect(find.text('Luyện tập hàng ngày'), findsOneWidget);
      expect(find.text('Nhẹ nhàng'), findsOneWidget);
      expect(find.text('Flashcard'), findsOneWidget);

      // Verify toggle functions without any layout overflow
      await tester.tap(find.text('Flashcard'));
      await tester.pumpAndSettle();

      expect(find.text('Lật thẻ xem nghĩa'), findsOneWidget);
      expect(find.text('Lật thẻ'), findsOneWidget);

      // Flip card
      await tester.tap(find.text('Lật thẻ'));
      await tester.pumpAndSettle();

      expect(find.text('Sự tình cờ may mắn'), findsOneWidget);

      await tester.tap(find.text('Nhẹ nhàng'));
      await tester.pumpAndSettle();

      expect(find.text('Sự tình cờ may mắn'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'DailyReviewCard has zero overflow even on ultra-narrow 320dp screen',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyReviewWordProvider
                .overrideWith(() => _MockDailyReviewNotifier(testWordItem)),
          ],
          child: MaterialApp(
            theme: MewTheme.light,
            darkTheme: MewTheme.dark,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('vi'),
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DailyReviewCard(userId: 'user-1'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Flashcard'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('DashboardPage displays display_name in greeting when updated to Cường',
        (tester) async {
      final testUser = User(
        id: 'user-cuong',
        appMetadata: const {},
        userMetadata: const {'display_name': 'Cường'},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
        email: 'cuong@example.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
            totalWordCountProvider('user-cuong').overrideWith((ref) => Future.value(10)),
            wordsLearnedThisWeekProvider('user-cuong').overrideWith((ref) => Future.value(3)),
            levelDistributionProvider('user-cuong').overrideWith((ref) => Future.value({})),
            dailyReviewWordProvider.overrideWith(() => _MockDailyReviewNotifier(null)),
          ],
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Xin chào, Cường! 👋'), findsOneWidget);
    });

    testWidgets('DashboardPage displays full_name in greeting when display_name is absent',
        (tester) async {
      final testUser = User(
        id: 'user-cuong',
        appMetadata: const {},
        userMetadata: const {'full_name': 'Cường'},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
        email: 'cuong@example.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
            totalWordCountProvider('user-cuong').overrideWith((ref) => Future.value(10)),
            wordsLearnedThisWeekProvider('user-cuong').overrideWith((ref) => Future.value(3)),
            levelDistributionProvider('user-cuong').overrideWith((ref) => Future.value({})),
            dailyReviewWordProvider.overrideWith(() => _MockDailyReviewNotifier(null)),
          ],
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Xin chào, Cường! 👋'), findsOneWidget);
    });

    testWidgets('DashboardPage falls back to email prefix in greeting when metadata absent',
        (tester) async {
      final testUser = User(
        id: 'user-cuong',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
        email: 'cuong@example.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
            totalWordCountProvider('user-cuong').overrideWith((ref) => Future.value(10)),
            wordsLearnedThisWeekProvider('user-cuong').overrideWith((ref) => Future.value(3)),
            levelDistributionProvider('user-cuong').overrideWith((ref) => Future.value({})),
            dailyReviewWordProvider.overrideWith(() => _MockDailyReviewNotifier(null)),
          ],
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Xin chào, cuong! 👋'), findsOneWidget);
    });
  });
}

class _MockDailyReviewNotifier extends DailyReviewNotifier {
  final VocabularyWithDefinitions? initial;
  _MockDailyReviewNotifier(this.initial);

  @override
  Future<VocabularyWithDefinitions?> build() async => initial;
}
