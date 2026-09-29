import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/config/theme.dart';
import 'package:mewmory/db/database.dart';
import 'package:mewmory/pages/add_word_page.dart';
import 'package:mewmory/providers/auth_provider.dart';
import 'package:mewmory/providers/database_provider.dart';
import 'package:mewmory/providers/services_provider.dart';
import 'package:mewmory/services/vocabulary_service.dart';
import 'package:mewmory/widgets/vocabulary/duplicate_warning.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late AppDatabase db;
  const testUserId = 'test-user-dup';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Pre-insert an existing word "eloquent"
    await db.into(db.vocabularies).insert(
          VocabulariesCompanion.insert(
            id: 'vocab-1',
            userId: testUserId,
            word: 'eloquent',
            cefrLevel: const Value('C1'),
            partOfSpeech: const Value('adjective'),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('Debounced duplicate check detects duplicate word while typing', (tester) async {
    final vocabService = VocabularyService(database: db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          vocabularyServiceProvider.overrideWithValue(vocabService),
          currentUserProvider.overrideWithValue(
            const User(
              id: testUserId,
              appMetadata: {},
              userMetadata: {},
              aud: 'authenticated',
              createdAt: '2026-01-01',
            ),
          ),
        ],
        child: MaterialApp(
          theme: MewTheme.light,
          home: const AddWordPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initially no duplicate warning
    expect(find.byType(DuplicateWarning), findsNothing);

    // Type "eloquent" into the text field
    final textFieldFinder = find.byType(TextField).first;
    await tester.enterText(textFieldFinder, 'eloquent');
    await tester.pump();

    // Advance time past debounce timer (300ms)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify duplicate warning is shown BEFORE clicking lookup button!
    expect(find.byType(DuplicateWarning), findsOneWidget);
    expect(find.text('Từ đã tồn tại trong sổ tay'), findsOneWidget);

    // Clear or change text to a unique word
    await tester.enterText(textFieldFinder, 'serendipity');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify duplicate warning disappeared
    expect(find.byType(DuplicateWarning), findsNothing);
  });
}
