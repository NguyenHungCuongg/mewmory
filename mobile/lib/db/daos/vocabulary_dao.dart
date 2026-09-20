import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/vocabularies_table.dart';
import '../tables/definitions_table.dart';
import '../tables/vocabulary_collections_table.dart';

part 'vocabulary_dao.g.dart';

class VocabularyWithDefinitions {
  final Vocabulary vocabulary;
  final List<Definition> definitions;
  final List<String> collectionIds;

  const VocabularyWithDefinitions({
    required this.vocabulary,
    required this.definitions,
    this.collectionIds = const [],
  });
}

@DriftAccessor(tables: [Vocabularies, Definitions, VocabularyCollections])
class VocabularyDao extends DatabaseAccessor<AppDatabase>
    with _$VocabularyDaoMixin {
  VocabularyDao(super.db);

  SimpleSelectStatement<$VocabulariesTable, Vocabulary> _buildVocabularyQuery(
    String userId, {
    String? cefrLevel,
    String? partOfSpeech,
    String? usageRegister,
    String? collectionId,
    String? searchQuery,
    String sortBy = 'created_at',
    bool ascending = false,
  }) {
    final query = select(vocabularies)
      ..where((v) => v.userId.equals(userId) & v.isDeleted.equals(false));

    if (cefrLevel != null && cefrLevel.isNotEmpty) {
      query.where((v) => v.cefrLevel.equals(cefrLevel));
    }

    if (partOfSpeech != null && partOfSpeech.isNotEmpty) {
      query.where((v) => v.partOfSpeech.equals(partOfSpeech));
    }

    if (usageRegister != null && usageRegister.isNotEmpty) {
      query.where((v) => v.usageRegister.equals(usageRegister));
    }

    if (collectionId != null && collectionId.isNotEmpty) {
      final vocabInCollection = selectOnly(vocabularyCollections)
        ..addColumns([vocabularyCollections.vocabularyId])
        ..where(
          vocabularyCollections.collectionId.equals(collectionId) &
              vocabularyCollections.isDeleted.equals(false),
        );
      query.where((v) => v.id.isInQuery(vocabInCollection));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      final matchingDefVocabIds = selectOnly(definitions)
        ..addColumns([definitions.vocabularyId])
        ..where(
          definitions.isDeleted.equals(false) &
              (definitions.definitionVi.lower().like(term) |
                  definitions.definitionEn.lower().like(term)),
        );

      query.where(
        (v) => v.word.lower().like(term) | v.id.isInQuery(matchingDefVocabIds),
      );
    }

    final mode = ascending ? OrderingMode.asc : OrderingMode.desc;
    if (sortBy == 'word') {
      query.orderBy([(v) => OrderingTerm(expression: v.word, mode: mode)]);
    } else if (sortBy == 'updated_at') {
      query.orderBy([(v) => OrderingTerm(expression: v.updatedAt, mode: mode)]);
    } else {
      query.orderBy([(v) => OrderingTerm(expression: v.createdAt, mode: mode)]);
    }

    return query;
  }

  Future<List<VocabularyWithDefinitions>> _loadDefinitionsAndCollections(
    List<Vocabulary> vocabs,
  ) async {
    if (vocabs.isEmpty) return [];

    final vocabIds = vocabs.map((v) => v.id).toList();

    // Load definitions
    final defsQuery = select(definitions)
      ..where(
        (d) => d.vocabularyId.isIn(vocabIds) & d.isDeleted.equals(false),
      )
      ..orderBy([
        (d) => OrderingTerm(expression: d.sortOrder, mode: OrderingMode.asc),
        (d) => OrderingTerm(expression: d.createdAt, mode: OrderingMode.asc),
      ]);
    final allDefs = await defsQuery.get();

    final defsByVocabId = <String, List<Definition>>{};
    for (final def in allDefs) {
      defsByVocabId.putIfAbsent(def.vocabularyId, () => []).add(def);
    }

    // Load linked collection IDs
    final linksQuery = select(vocabularyCollections)
      ..where(
        (vc) => vc.vocabularyId.isIn(vocabIds) & vc.isDeleted.equals(false),
      );
    final allLinks = await linksQuery.get();

    final colIdsByVocabId = <String, List<String>>{};
    for (final link in allLinks) {
      colIdsByVocabId
          .putIfAbsent(link.vocabularyId, () => [])
          .add(link.collectionId);
    }

    return vocabs.map((v) {
      return VocabularyWithDefinitions(
        vocabulary: v,
        definitions: defsByVocabId[v.id] ?? const [],
        collectionIds: colIdsByVocabId[v.id] ?? const [],
      );
    }).toList();
  }

  Stream<List<VocabularyWithDefinitions>> watchAll(
    String userId, {
    String? cefrLevel,
    String? partOfSpeech,
    String? usageRegister,
    String? collectionId,
    String? searchQuery,
    String sortBy = 'created_at',
    bool ascending = false,
  }) {
    final query = _buildVocabularyQuery(
      userId,
      cefrLevel: cefrLevel,
      partOfSpeech: partOfSpeech,
      usageRegister: usageRegister,
      collectionId: collectionId,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );

    return query.watch().asyncMap(_loadDefinitionsAndCollections);
  }

  Future<List<VocabularyWithDefinitions>> getAll(
    String userId, {
    String? cefrLevel,
    String? partOfSpeech,
    String? usageRegister,
    String? collectionId,
    String? searchQuery,
    String sortBy = 'created_at',
    bool ascending = false,
  }) async {
    final query = _buildVocabularyQuery(
      userId,
      cefrLevel: cefrLevel,
      partOfSpeech: partOfSpeech,
      usageRegister: usageRegister,
      collectionId: collectionId,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );

    final vocabs = await query.get();
    return _loadDefinitionsAndCollections(vocabs);
  }

  Future<VocabularyWithDefinitions?> getById(String id) async {
    final query = select(vocabularies)
      ..where((v) => v.id.equals(id) & v.isDeleted.equals(false));
    final vocab = await query.getSingleOrNull();
    if (vocab == null) return null;

    final list = await _loadDefinitionsAndCollections([vocab]);
    return list.isNotEmpty ? list.first : null;
  }

  Stream<VocabularyWithDefinitions?> watchById(String id) {
    final query = select(vocabularies)
      ..where((v) => v.id.equals(id) & v.isDeleted.equals(false));
    return query.watchSingleOrNull().asyncMap((vocab) async {
      if (vocab == null) return null;
      final list = await _loadDefinitionsAndCollections([vocab]);
      return list.isNotEmpty ? list.first : null;
    });
  }

  Future<VocabularyWithDefinitions?> getRandomWord(String userId) async {
    final query = select(vocabularies)
      ..where((v) => v.userId.equals(userId) & v.isDeleted.equals(false))
      ..orderBy([(v) => OrderingTerm.random()])
      ..limit(1);
    final vocab = await query.getSingleOrNull();
    if (vocab == null) return null;

    final list = await _loadDefinitionsAndCollections([vocab]);
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> upsertVocabulary(VocabulariesCompanion entry) async {
    await into(vocabularies).insertOnConflictUpdate(entry);
  }

  Future<void> upsertDefinitions(List<DefinitionsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(definitions, entries);
    });
  }

  Future<List<VocabularyWithDefinitions>> search(
    String userId,
    String query,
  ) async {
    return getAll(userId, searchQuery: query);
  }

  Future<void> deleteVocabulary(String id) async {
    final now = DateTime.now();
    await transaction(() async {
      await (update(definitions)..where((d) => d.vocabularyId.equals(id)))
          .write(
        DefinitionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await (update(vocabularyCollections)
            ..where((vc) => vc.vocabularyId.equals(id)))
          .write(
        VocabularyCollectionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await (update(vocabularies)..where((v) => v.id.equals(id))).write(
        VocabulariesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> hardDeleteVocabulary(String id) async {
    await (delete(vocabularies)..where((v) => v.id.equals(id))).go();
  }
}
