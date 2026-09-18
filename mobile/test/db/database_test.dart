import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Database & DAOs', () {
    const testUserId = 'test-user-123';

    test('CollectionDao - insert, get, and count words', () async {
      final now = DateTime.now();

      await db.collectionDao.upsert(
        CollectionsCompanion.insert(
          id: 'col-1',
          userId: testUserId,
          name: 'Daily English',
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final cols = await db.collectionDao.getAll(testUserId);
      expect(cols.length, 1);
      expect(cols.first.collection.name, 'Daily English');
      expect(cols.first.wordCount, 0);
    });

    test('VocabularyDao - insert, get with definitions, and search', () async {
      final now = DateTime.now();

      // Insert vocabulary
      await db.vocabularyDao.upsertVocabulary(
        VocabulariesCompanion.insert(
          id: 'vocab-1',
          userId: testUserId,
          word: 'resilient',
          phonetic: const Value('/rɪˈzɪliənt/'),
          cefrLevel: const Value('B2'),
          partOfSpeech: const Value('adjective'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      // Insert definitions
      await db.vocabularyDao.upsertDefinitions([
        DefinitionsCompanion.insert(
          id: 'def-1',
          vocabularyId: 'vocab-1',
          definitionEn: const Value('Able to withstand or recover quickly.'),
          definitionVi: const Value('Kiên cường, bền bỉ.'),
          sortOrder: const Value(0),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);

      // Assign to collection
      await db.collectionDao.assignToCollection('vocab-1', 'col-1');

      // Query vocabulary with definitions
      final results = await db.vocabularyDao.getAll(testUserId);
      expect(results.length, 1);
      expect(results.first.vocabulary.word, 'resilient');
      expect(results.first.definitions.length, 1);
      expect(results.first.definitions.first.definitionVi, 'Kiên cường, bền bỉ.');
      expect(results.first.collectionIds, contains('col-1'));

      // Search by Vietnamese definition keyword
      final searchResults = await db.vocabularyDao.search(testUserId, 'kiên cường');
      expect(searchResults.length, 1);
      expect(searchResults.first.vocabulary.word, 'resilient');

      // Search by English word keyword
      final searchEnResults = await db.vocabularyDao.search(testUserId, 'resil');
      expect(searchEnResults.length, 1);
    });

    test('StatsDao - calculate total count and level distribution', () async {
      final now = DateTime.now();

      await db.vocabularyDao.upsertVocabulary(
        VocabulariesCompanion.insert(
          id: 'v-1',
          userId: testUserId,
          word: 'cat',
          cefrLevel: const Value('A1'),
          partOfSpeech: const Value('noun'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await db.vocabularyDao.upsertVocabulary(
        VocabulariesCompanion.insert(
          id: 'v-2',
          userId: testUserId,
          word: 'dog',
          cefrLevel: const Value('A1'),
          partOfSpeech: const Value('noun'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final total = await db.statsDao.getTotalCount(testUserId);
      expect(total, 2);

      final levels = await db.statsDao.getLevelDistribution(testUserId);
      expect(levels['A1'], 2);

      final pos = await db.statsDao.getPartOfSpeechDistribution(testUserId);
      expect(pos['noun'], 2);
    });
  });
}
