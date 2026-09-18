import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/vocabularies_table.dart';
import '../tables/collections_table.dart';
import '../tables/vocabulary_collections_table.dart';

part 'stats_dao.g.dart';

@DriftAccessor(tables: [Vocabularies, Collections, VocabularyCollections])
class StatsDao extends DatabaseAccessor<AppDatabase> with _$StatsDaoMixin {
  StatsDao(super.db);

  Future<int> getTotalCount(String userId) async {
    final countExp = vocabularies.id.count();
    final query = selectOnly(vocabularies)
      ..addColumns([countExp])
      ..where(
        vocabularies.userId.equals(userId) &
            vocabularies.isDeleted.equals(false),
      );
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<Map<String, int>> getLevelDistribution(String userId) async {
    final countExp = vocabularies.id.count();
    final levelCol = vocabularies.cefrLevel;
    final query = selectOnly(vocabularies)
      ..addColumns([levelCol, countExp])
      ..where(
        vocabularies.userId.equals(userId) &
            vocabularies.isDeleted.equals(false) &
            levelCol.isNotNull(),
      )
      ..groupBy([levelCol]);

    final rows = await query.get();
    final map = <String, int>{};
    for (final row in rows) {
      final level = row.read(levelCol);
      final count = row.read(countExp) ?? 0;
      if (level != null && count > 0) {
        map[level] = count;
      }
    }
    return map;
  }

  Future<Map<String, int>> getPartOfSpeechDistribution(String userId) async {
    final countExp = vocabularies.id.count();
    final posCol = vocabularies.partOfSpeech;
    final query = selectOnly(vocabularies)
      ..addColumns([posCol, countExp])
      ..where(
        vocabularies.userId.equals(userId) &
            vocabularies.isDeleted.equals(false) &
            posCol.isNotNull(),
      )
      ..groupBy([posCol]);

    final rows = await query.get();
    final map = <String, int>{};
    for (final row in rows) {
      final pos = row.read(posCol);
      final count = row.read(countExp) ?? 0;
      if (pos != null && count > 0) {
        map[pos] = count;
      }
    }
    return map;
  }

  Future<Map<String, int>> getCollectionDistribution(String userId) async {
    final countExp = vocabularies.id.count();
    final colName = collections.name;
    final query = select(vocabularyCollections).join([
      innerJoin(
        collections,
        collections.id.equalsExp(vocabularyCollections.collectionId) &
            collections.isDeleted.equals(false) &
            collections.userId.equals(userId),
      ),
      innerJoin(
        vocabularies,
        vocabularies.id.equalsExp(vocabularyCollections.vocabularyId) &
            vocabularies.isDeleted.equals(false),
      ),
    ])
      ..where(vocabularyCollections.isDeleted.equals(false))
      ..groupBy([collections.id, colName]);

    final rows = await query.get();
    final map = <String, int>{};
    for (final row in rows) {
      final name = row.readTable(collections).name;
      final count = row.read(countExp) ?? 0;
      map[name] = count;
    }
    return map;
  }

  Future<int> getWordsLearnedToday(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final countExp = vocabularies.id.count();
    final query = selectOnly(vocabularies)
      ..addColumns([countExp])
      ..where(
        vocabularies.userId.equals(userId) &
            vocabularies.isDeleted.equals(false) &
            vocabularies.createdAt.isBiggerOrEqualValue(startOfDay),
      );
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
