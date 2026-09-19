import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/database.dart' as db;
import '../models/collection.dart';

class CollectionService {
  final SupabaseClient? _client;
  final db.AppDatabase _db;

  CollectionService({
    SupabaseClient? client,
    required db.AppDatabase database,
  })  : _client = client,
        _db = database;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  /// Reactive stream of user collections with active word counts
  Stream<List<db.CollectionWithCount>> watchAll(String userId) {
    return _db.collectionDao.watchAll(userId);
  }

  /// Snapshot of user collections with active word counts
  Future<List<db.CollectionWithCount>> getAll(String userId) async {
    return await _db.collectionDao.getAll(userId);
  }

  /// Get single collection by ID from local cache
  Future<db.Collection?> getById(String id) async {
    return await _db.collectionDao.getById(id);
  }

  /// Create collection: writes to Supabase, then updates Drift cache
  Future<Collection> create({
    required String userId,
    required String name,
    String? description,
    bool isDefault = false,
    bool isAiGenerated = false,
  }) async {
    final row = await _supabase
        .from('collections')
        .insert({
          'user_id': userId,
          'name': name.trim(),
          'description': description?.trim(),
          'is_default': isDefault,
          'is_ai_generated': isAiGenerated,
        })
        .select()
        .single();

    final created = Collection.fromJson(row);
    await _db.collectionDao.upsert(created.toDriftCompanion());
    return created;
  }

  /// Update collection: writes to Supabase, then updates Drift cache
  Future<void> update(Collection collection) async {
    final now = DateTime.now();
    await _supabase.from('collections').update({
      'name': collection.name.trim(),
      'description': collection.description?.trim(),
      'updated_at': now.toIso8601String(),
    }).eq('id', collection.id);

    await _db.collectionDao.upsert(collection.toDriftCompanion());
  }

  /// Soft-delete collection and unbind words on Supabase and Drift cache
  Future<void> delete(String id) async {
    final now = DateTime.now().toIso8601String();

    await _supabase.from('collections').update({
      'is_deleted': true,
      'updated_at': now,
    }).eq('id', id);

    await _supabase.from('vocabulary_collections').update({
      'is_deleted': true,
      'updated_at': now,
    }).eq('collection_id', id);

    await _db.collectionDao.deleteCollection(id);
  }

  /// Assign word to collection
  Future<void> assignWord(String vocabularyId, String collectionId) async {
    await _supabase.from('vocabulary_collections').upsert(
      {
        'vocabulary_id': vocabularyId,
        'collection_id': collectionId,
        'is_deleted': false,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'vocabulary_id,collection_id',
    );

    await _db.collectionDao.assignToCollection(vocabularyId, collectionId);
  }

  /// Remove word from collection
  Future<void> removeWord(String vocabularyId, String collectionId) async {
    await _supabase.from('vocabulary_collections').update({
      'is_deleted': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).match({
      'vocabulary_id': vocabularyId,
      'collection_id': collectionId,
    });

    await _db.collectionDao.removeFromCollection(vocabularyId, collectionId);
  }

  /// Get collection IDs for a specific vocabulary from local cache
  Future<List<String>> getCollectionIdsForVocabulary(
    String vocabularyId,
  ) async {
    return await _db.collectionDao.getCollectionIdsForVocabulary(vocabularyId);
  }
}
