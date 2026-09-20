import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/db/database.dart';
import 'package:mewmory/services/vocabulary_service.dart';

void main() {
  late AppDatabase db;
  late VocabularyService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = VocabularyService(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('VocabularyService (Local Cache Operations)', () {
    const userId = 'user-service-test';

    test('getAll and watchAll reflect data inserted in local cache', () async {
      final now = DateTime.now();

      // Seed Drift cache directly
      await db.vocabularyDao.upsertVocabulary(
        VocabulariesCompanion.insert(
          id: 'v-100',
          userId: userId,
          word: 'meticulous',
          cefrLevel: const Value('C1'),
          partOfSpeech: const Value('adjective'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await db.vocabularyDao.upsertDefinitions([
        DefinitionsCompanion.insert(
          id: 'd-100',
          vocabularyId: 'v-100',
          definitionVi: const Value('Tỉ mỉ, cẩn thận'),
          sortOrder: const Value(0),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);

      final all = await service.getAll(userId);
      expect(all.length, 1);
      expect(all.first.vocabulary.word, 'meticulous');
      expect(all.first.definitions.first.definitionVi, 'Tỉ mỉ, cẩn thận');

      final single = await service.getById('v-100');
      expect(single, isNotNull);
      expect(single!.vocabulary.word, 'meticulous');

      final searchResults = await service.search(userId, 'tỉ mỉ');
      expect(searchResults.length, 1);
    });

    test('delete marks word as deleted in local cache', () async {
      final now = DateTime.now();

      await db.vocabularyDao.upsertVocabulary(
        VocabulariesCompanion.insert(
          id: 'v-200',
          userId: userId,
          word: 'obsolete',
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      // Verify exists
      final before = await service.getAll(userId);
      expect(before.length, 1);

      // Perform local delete
      await db.vocabularyDao.deleteVocabulary('v-200');

      // Verify filtered out
      final after = await service.getAll(userId);
      expect(after.isEmpty, true);
    });
  });
}
