import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Sign-Out Local Cache Cleansing Tests', () {
    test('clearAllLocalData wipes all tables across vocabularies, definitions, and collections', () async {
      final now = DateTime.now();

      // Seed vocabulary
      await db.into(db.vocabularies).insert(
            VocabulariesCompanion.insert(
              id: 'vocab-1',
              userId: 'user-1',
              word: 'ephemeral',
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // Seed definition
      await db.into(db.definitions).insert(
            DefinitionsCompanion.insert(
              id: 'def-1',
              vocabularyId: 'vocab-1',
              definitionVi: const Value('phù du, ngắn ngủi'),
              sortOrder: const Value(0),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // Seed collection
      await db.into(db.collections).insert(
            CollectionsCompanion.insert(
              id: 'col-1',
              userId: 'user-1',
              name: 'Advanced Vocab',
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // Verify records exist
      expect((await db.select(db.vocabularies).get()).length, 1);
      expect((await db.select(db.definitions).get()).length, 1);
      expect((await db.select(db.collections).get()).length, 1);

      // Perform cleanup
      await db.clearAllLocalData();

      // Verify all tables are completely empty
      expect((await db.select(db.vocabularies).get()).isEmpty, isTrue);
      expect((await db.select(db.definitions).get()).isEmpty, isTrue);
      expect((await db.select(db.collections).get()).isEmpty, isTrue);
      expect((await db.select(db.vocabularyCollections).get()).isEmpty, isTrue);
      expect((await db.select(db.userSettingsTable).get()).isEmpty, isTrue);
    });
  });
}
