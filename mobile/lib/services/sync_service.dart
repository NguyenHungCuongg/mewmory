import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/database.dart' as db;
import '../models/collection.dart';
import '../models/definition.dart';
import '../models/user_settings.dart';
import '../models/vocabulary.dart';

class SyncService {
  final SupabaseClient? _client;
  final db.AppDatabase _db;

  SyncService({
    SupabaseClient? client,
    required db.AppDatabase database,
  })  : _client = client,
        _db = database;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  String _lastSyncKey(String userId) => 'last_sync_at_$userId';

  Future<DateTime?> getLastSyncAt(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey(userId));
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<void> setLastSyncAt(String userId, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey(userId), time.toIso8601String());
  }

  /// Full sync — pulls all non-deleted user data from Supabase into Drift
  Future<void> fullSync(String userId) async {
    final syncStartTime = DateTime.now();

    // 1. Pull vocabularies
    final vocabRows = await _supabase
        .from('vocabularies')
        .select()
        .eq('user_id', userId)
        .eq('is_deleted', false);

    final vocabs = (vocabRows as List)
        .map((r) => Vocabulary.fromJson(r as Map<String, dynamic>))
        .toList();

    // Bulk upsert vocabularies into Drift
    if (vocabs.isNotEmpty) {
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.vocabularies,
          vocabs.map((v) => v.toDriftCompanion()).toList(),
        );
      });

      // 2. Pull definitions for those vocabularies
      final vocabIds = vocabs.map((v) => v.id).toList();
      const chunkSize = 100;
      for (var i = 0; i < vocabIds.length; i += chunkSize) {
        final chunk = vocabIds.sublist(
          i,
          i + chunkSize > vocabIds.length ? vocabIds.length : i + chunkSize,
        );
        final defRows = await _supabase
            .from('definitions')
            .select()
            .inFilter('vocabulary_id', chunk)
            .eq('is_deleted', false);

        final defs = (defRows as List)
            .map((r) => Definition.fromJson(r as Map<String, dynamic>))
            .toList();

        if (defs.isNotEmpty) {
          await _db.batch((b) {
            b.insertAllOnConflictUpdate(
              _db.definitions,
              defs.map((d) => d.toDriftCompanion()).toList(),
            );
          });
        }
      }
    }

    // 3. Pull collections
    final colRows = await _supabase
        .from('collections')
        .select()
        .eq('user_id', userId)
        .eq('is_deleted', false);

    final cols = (colRows as List)
        .map((r) => Collection.fromJson(r as Map<String, dynamic>))
        .toList();

    if (cols.isNotEmpty) {
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.collections,
          cols.map((c) => c.toDriftCompanion()).toList(),
        );
      });
    }

    // 4. Pull vocabulary_collections
    final vcRows = await _supabase
        .from('vocabulary_collections')
        .select()
        .eq('is_deleted', false);

    final vcList = (vcRows as List).cast<Map<String, dynamic>>();
    if (vcList.isNotEmpty) {
      final vcCompanions = vcList.map((m) {
        return db.VocabularyCollectionsCompanion(
          id: drift.Value(m['id'] as String),
          vocabularyId: drift.Value(m['vocabulary_id'] as String),
          collectionId: drift.Value(m['collection_id'] as String),
          isDeleted: drift.Value(m['is_deleted'] as bool? ?? false),
          createdAt: drift.Value(DateTime.parse(m['created_at'] as String)),
          updatedAt: drift.Value(DateTime.parse(m['updated_at'] as String)),
        );
      }).toList();

      await _db.batch((b) {
        b.insertAllOnConflictUpdate(_db.vocabularyCollections, vcCompanions);
      });
    }

    // 5. Pull user_settings
    final settingsRow = await _supabase
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (settingsRow != null) {
      final settings = UserSettings.fromJson(settingsRow);
      await _db.into(_db.userSettingsTable).insertOnConflictUpdate(
            settings.toDriftCompanion(),
          );
    }

    // 6. Save lastSyncAt
    await setLastSyncAt(userId, syncStartTime);
  }

  /// Incremental sync — pulls records with updated_at > lastSyncAt
  Future<DateTime> incrementalSync(String userId, DateTime lastSyncAt) async {
    final syncStartTime = DateTime.now();
    final iso = lastSyncAt.toIso8601String();

    // 1. Incremental Vocabularies
    final vocabRows = await _supabase
        .from('vocabularies')
        .select()
        .eq('user_id', userId)
        .gt('updated_at', iso);

    final vocabs = (vocabRows as List)
        .map((r) => Vocabulary.fromJson(r as Map<String, dynamic>))
        .toList();

    if (vocabs.isNotEmpty) {
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.vocabularies,
          vocabs.map((v) => v.toDriftCompanion()).toList(),
        );
      });
    }

    // 2. Incremental Definitions
    final defRows = await _supabase
        .from('definitions')
        .select()
        .gt('updated_at', iso);

    final defs = (defRows as List)
        .map((r) => Definition.fromJson(r as Map<String, dynamic>))
        .toList();

    if (defs.isNotEmpty) {
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.definitions,
          defs.map((d) => d.toDriftCompanion()).toList(),
        );
      });
    }

    // 3. Incremental Collections
    final colRows = await _supabase
        .from('collections')
        .select()
        .eq('user_id', userId)
        .gt('updated_at', iso);

    final cols = (colRows as List)
        .map((r) => Collection.fromJson(r as Map<String, dynamic>))
        .toList();

    if (cols.isNotEmpty) {
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.collections,
          cols.map((c) => c.toDriftCompanion()).toList(),
        );
      });
    }

    // 4. Incremental VocabularyCollections
    final vcRows = await _supabase
        .from('vocabulary_collections')
        .select()
        .gt('updated_at', iso);

    final vcList = (vcRows as List).cast<Map<String, dynamic>>();
    if (vcList.isNotEmpty) {
      final vcCompanions = vcList.map((m) {
        return db.VocabularyCollectionsCompanion(
          id: drift.Value(m['id'] as String),
          vocabularyId: drift.Value(m['vocabulary_id'] as String),
          collectionId: drift.Value(m['collection_id'] as String),
          isDeleted: drift.Value(m['is_deleted'] as bool? ?? false),
          createdAt: drift.Value(DateTime.parse(m['created_at'] as String)),
          updatedAt: drift.Value(DateTime.parse(m['updated_at'] as String)),
        );
      }).toList();

      await _db.batch((b) {
        b.insertAllOnConflictUpdate(_db.vocabularyCollections, vcCompanions);
      });
    }

    // 5. Incremental UserSettings
    final settingsRow = await _supabase
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .gt('updated_at', iso)
        .maybeSingle();

    if (settingsRow != null) {
      final settings = UserSettings.fromJson(settingsRow);
      await _db.into(_db.userSettingsTable).insertOnConflictUpdate(
            settings.toDriftCompanion(),
          );
    }

    await setLastSyncAt(userId, syncStartTime);
    return syncStartTime;
  }
}
