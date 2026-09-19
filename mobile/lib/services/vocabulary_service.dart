import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/database.dart' as db;
import '../models/definition.dart';
import '../models/vocabulary.dart';

class VocabularyService {
  final SupabaseClient? _client;
  final db.AppDatabase _db;

  VocabularyService({
    SupabaseClient? client,
    required db.AppDatabase database,
  })  : _client = client,
        _db = database;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  /// Reactive stream of vocabulary list with filters from local Drift cache
  Stream<List<db.VocabularyWithDefinitions>> watchAll(
    String userId, {
    String? cefrLevel,
    String? partOfSpeech,
    String? usageRegister,
    String? collectionId,
    String? searchQuery,
    String sortBy = 'created_at',
    bool ascending = false,
  }) {
    return _db.vocabularyDao.watchAll(
      userId,
      cefrLevel: cefrLevel,
      partOfSpeech: partOfSpeech,
      usageRegister: usageRegister,
      collectionId: collectionId,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  /// Get snapshot of vocabulary list from local Drift cache
  Future<List<db.VocabularyWithDefinitions>> getAll(
    String userId, {
    String? cefrLevel,
    String? partOfSpeech,
    String? usageRegister,
    String? collectionId,
    String? searchQuery,
    String sortBy = 'created_at',
    bool ascending = false,
  }) async {
    return await _db.vocabularyDao.getAll(
      userId,
      cefrLevel: cefrLevel,
      partOfSpeech: partOfSpeech,
      usageRegister: usageRegister,
      collectionId: collectionId,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  /// Get single vocabulary by ID with its definitions from local Drift cache
  Future<db.VocabularyWithDefinitions?> getById(String id) async {
    return await _db.vocabularyDao.getById(id);
  }

  /// Watch single vocabulary by ID reactively from local Drift cache
  Stream<db.VocabularyWithDefinitions?> watchById(String id) {
    return _db.vocabularyDao.watchById(id);
  }

  /// Search vocabulary by keyword (matches word or English/Vietnamese definitions)
  Future<List<db.VocabularyWithDefinitions>> search(
    String userId,
    String query,
  ) async {
    return await _db.vocabularyDao.search(userId, query);
  }

  /// Create vocabulary: write to Supabase first, then write-through to Drift cache
  Future<Vocabulary> create({
    required String userId,
    required String word,
    String? phonetic,
    String? audioUrl,
    String? partOfSpeech,
    String? cefrLevel,
    String? usageRegister,
    required List<Definition> definitions,
    List<String> collectionIds = const [],
  }) async {
    // 1. Insert vocabulary record to Supabase
    final vocabRow = await _supabase
        .from('vocabularies')
        .insert({
          'user_id': userId,
          'word': word,
          'phonetic': phonetic,
          'audio_url': audioUrl,
          'part_of_speech': partOfSpeech,
          'cefr_level': cefrLevel,
          'usage_register': usageRegister,
        })
        .select()
        .single();

    final createdVocab = Vocabulary.fromJson(vocabRow);

    // 2. Insert definitions to Supabase
    final List<Definition> savedDefs = [];
    if (definitions.isNotEmpty) {
      final defsPayload = definitions.asMap().entries.map((e) {
        return {
          'vocabulary_id': createdVocab.id,
          'definition_en': e.value.definitionEn,
          'definition_vi': e.value.definitionVi,
          'example': e.value.example,
          'sort_order': e.value.sortOrder != 0 ? e.value.sortOrder : e.key,
        };
      }).toList();

      final defRows = await _supabase
          .from('definitions')
          .insert(defsPayload)
          .select();

      for (final r in defRows as List) {
        savedDefs.add(Definition.fromJson(r as Map<String, dynamic>));
      }
    }

    // 3. Insert collection links to Supabase if any
    if (collectionIds.isNotEmpty) {
      final linksPayload = collectionIds.map((cid) {
        return {
          'vocabulary_id': createdVocab.id,
          'collection_id': cid,
        };
      }).toList();

      await _supabase.from('vocabulary_collections').insert(linksPayload);
    }

    // 4. Update Drift cache immediately
    await _db.vocabularyDao.upsertVocabulary(createdVocab.toDriftCompanion());
    if (savedDefs.isNotEmpty) {
      await _db.vocabularyDao.upsertDefinitions(
        savedDefs.map((d) => d.toDriftCompanion()).toList(),
      );
    }
    for (final cid in collectionIds) {
      await _db.collectionDao.assignToCollection(createdVocab.id, cid);
    }

    return Vocabulary(
      id: createdVocab.id,
      userId: createdVocab.userId,
      word: createdVocab.word,
      phonetic: createdVocab.phonetic,
      audioUrl: createdVocab.audioUrl,
      partOfSpeech: createdVocab.partOfSpeech,
      cefrLevel: createdVocab.cefrLevel,
      usageRegister: createdVocab.usageRegister,
      createdAt: createdVocab.createdAt,
      updatedAt: createdVocab.updatedAt,
      isDeleted: createdVocab.isDeleted,
      definitions: savedDefs,
      collectionIds: collectionIds,
    );
  }

  /// Update vocabulary: update Supabase, then update local Drift cache
  Future<void> update({
    required Vocabulary vocabulary,
    List<Definition>? definitions,
    List<String>? collectionIds,
  }) async {
    final now = DateTime.now();

    // 1. Update vocabulary on Supabase
    await _supabase.from('vocabularies').update({
      'word': vocabulary.word,
      'phonetic': vocabulary.phonetic,
      'audio_url': vocabulary.audioUrl,
      'part_of_speech': vocabulary.partOfSpeech,
      'cefr_level': vocabulary.cefrLevel,
      'usage_register': vocabulary.usageRegister,
      'updated_at': now.toIso8601String(),
    }).eq('id', vocabulary.id);

    // 2. Update definitions if provided
    if (definitions != null) {
      for (final def in definitions) {
        if (def.id.isNotEmpty) {
          await _supabase.from('definitions').upsert({
            'id': def.id,
            'vocabulary_id': vocabulary.id,
            'definition_en': def.definitionEn,
            'definition_vi': def.definitionVi,
            'example': def.example,
            'sort_order': def.sortOrder,
            'updated_at': now.toIso8601String(),
          });
        }
      }
    }

    // 3. Update collection links if provided
    if (collectionIds != null) {
      // Mark all existing links for this vocab as deleted on Supabase
      await _supabase
          .from('vocabulary_collections')
          .update({'is_deleted': true, 'updated_at': now.toIso8601String()})
          .eq('vocabulary_id', vocabulary.id);

      // Upsert new collection links
      if (collectionIds.isNotEmpty) {
        final linksPayload = collectionIds.map((cid) {
          return {
            'vocabulary_id': vocabulary.id,
            'collection_id': cid,
            'is_deleted': false,
            'updated_at': now.toIso8601String(),
          };
        }).toList();

        await _supabase.from('vocabulary_collections').upsert(linksPayload);
      }
    }

    // 4. Update Drift cache
    await _db.vocabularyDao.upsertVocabulary(vocabulary.toDriftCompanion());
    if (definitions != null && definitions.isNotEmpty) {
      await _db.vocabularyDao.upsertDefinitions(
        definitions.map((d) => d.toDriftCompanion()).toList(),
      );
    }
  }

  /// Soft-delete vocabulary on Supabase and local cache
  Future<void> delete(String id) async {
    final now = DateTime.now().toIso8601String();

    // 1. Soft delete on Supabase
    await _supabase.from('vocabularies').update({
      'is_deleted': true,
      'updated_at': now,
    }).eq('id', id);

    await _supabase.from('definitions').update({
      'is_deleted': true,
      'updated_at': now,
    }).eq('vocabulary_id', id);

    await _supabase.from('vocabulary_collections').update({
      'is_deleted': true,
      'updated_at': now,
    }).eq('vocabulary_id', id);

    // 2. Soft delete in Drift cache
    await _db.vocabularyDao.deleteVocabulary(id);
  }
}
