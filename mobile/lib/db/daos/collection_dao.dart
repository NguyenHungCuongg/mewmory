import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';
import '../tables/collections_table.dart';
import '../tables/vocabulary_collections_table.dart';
import '../tables/vocabularies_table.dart';

part 'collection_dao.g.dart';

class CollectionWithCount {
  final Collection collection;
  final int wordCount;

  const CollectionWithCount({
    required this.collection,
    required this.wordCount,
  });
}

@DriftAccessor(tables: [Collections, VocabularyCollections, Vocabularies])
class CollectionDao extends DatabaseAccessor<AppDatabase>
    with _$CollectionDaoMixin {
  CollectionDao(super.db);

  Future<List<CollectionWithCount>> _loadWordCounts(
    List<Collection> cols,
    String userId,
  ) async {
    if (cols.isEmpty) return [];

    final colIds = cols.map((c) => c.id).toList();

    // Query active words linked to each collection
    final countQuery = select(vocabularyCollections).join([
      innerJoin(
        vocabularies,
        vocabularies.id.equalsExp(vocabularyCollections.vocabularyId) &
            vocabularies.isDeleted.equals(false) &
            vocabularies.userId.equals(userId),
      ),
    ])
      ..where(
        vocabularyCollections.collectionId.isIn(colIds) &
            vocabularyCollections.isDeleted.equals(false),
      );

    final rows = await countQuery.get();
    final counts = <String, int>{};
    for (final row in rows) {
      final colId = row.readTable(vocabularyCollections).collectionId;
      counts[colId] = (counts[colId] ?? 0) + 1;
    }

    return cols.map((c) {
      return CollectionWithCount(
        collection: c,
        wordCount: counts[c.id] ?? 0,
      );
    }).toList();
  }

  Stream<List<CollectionWithCount>> watchAll(String userId) {
    final query = select(collections)
      ..where((c) => c.userId.equals(userId) & c.isDeleted.equals(false))
      ..orderBy([
        (c) => OrderingTerm(expression: c.isDefault, mode: OrderingMode.desc),
        (c) => OrderingTerm(expression: c.createdAt, mode: OrderingMode.asc),
      ]);

    return query.watch().asyncMap((cols) => _loadWordCounts(cols, userId));
  }

  Future<List<CollectionWithCount>> getAll(String userId) async {
    final query = select(collections)
      ..where((c) => c.userId.equals(userId) & c.isDeleted.equals(false))
      ..orderBy([
        (c) => OrderingTerm(expression: c.isDefault, mode: OrderingMode.desc),
        (c) => OrderingTerm(expression: c.createdAt, mode: OrderingMode.asc),
      ]);

    final cols = await query.get();
    return _loadWordCounts(cols, userId);
  }

  Future<Collection?> getById(String id) async {
    final query = select(collections)
      ..where((c) => c.id.equals(id) & c.isDeleted.equals(false));
    return query.getSingleOrNull();
  }

  Future<void> upsert(CollectionsCompanion entry) async {
    await into(collections).insertOnConflictUpdate(entry);
  }

  Future<void> deleteCollection(String id) async {
    final now = DateTime.now();
    await transaction(() async {
      await (update(vocabularyCollections)
            ..where((vc) => vc.collectionId.equals(id)))
          .write(
        VocabularyCollectionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await (update(collections)..where((c) => c.id.equals(id))).write(
        CollectionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> assignToCollection(
    String vocabularyId,
    String collectionId,
  ) async {
    final existing = await (select(vocabularyCollections)
          ..where(
            (vc) =>
                vc.vocabularyId.equals(vocabularyId) &
                vc.collectionId.equals(collectionId),
          ))
        .getSingleOrNull();

    if (existing != null) {
      if (existing.isDeleted) {
        await (update(vocabularyCollections)
              ..where((vc) => vc.id.equals(existing.id)))
            .write(
          VocabularyCollectionsCompanion(
            isDeleted: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    } else {
      await into(vocabularyCollections).insert(
        VocabularyCollectionsCompanion(
          id: Value(const Uuid().v4()),
          vocabularyId: Value(vocabularyId),
          collectionId: Value(collectionId),
          isDeleted: const Value(false),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> removeFromCollection(
    String vocabularyId,
    String collectionId,
  ) async {
    await (update(vocabularyCollections)
          ..where(
            (vc) =>
                vc.vocabularyId.equals(vocabularyId) &
                vc.collectionId.equals(collectionId),
          ))
        .write(
      VocabularyCollectionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<String>> getCollectionIdsForVocabulary(
    String vocabularyId,
  ) async {
    final query = selectOnly(vocabularyCollections)
      ..addColumns([vocabularyCollections.collectionId])
      ..where(
        vocabularyCollections.vocabularyId.equals(vocabularyId) &
            vocabularyCollections.isDeleted.equals(false),
      );

    final rows = await query.get();
    return rows
        .map((row) => row.read(vocabularyCollections.collectionId)!)
        .toList();
  }
}
