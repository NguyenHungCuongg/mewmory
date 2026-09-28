import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/database.dart' as db;
import '../models/collection.dart';
import '../models/definition.dart';
import '../models/user_settings.dart';
import '../models/vocabulary.dart';

/// Re-read this much before the cursor: a row stamped just before the newest
/// one we saw may commit after we read. Re-pulling a row is harmless (upsert).
const syncCursorOverlap = Duration(seconds: 60);

/// Newest server `updated_at` in [seen], or [previous] if none is newer.
/// The cursor must come from server timestamps, not the device clock.
DateTime? nextSyncCursor(DateTime? previous, Iterable<DateTime> seen) {
  var cursor = previous;
  for (final t in seen) {
    if (cursor == null || t.isAfter(cursor)) cursor = t;
  }
  return cursor;
}

/// `updated_at` lower bound for an incremental pull from [cursor].
String syncQueryStart(DateTime cursor) =>
    cursor.subtract(syncCursorOverlap).toUtc().toIso8601String();

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
    final seen = <DateTime>[];

    // 1. Pull vocabularies
    final vocabRows = await _supabase
        .from('vocabularies')
        .select()
        .eq('user_id', userId)
        .eq('is_deleted', false);

    final vocabs = (vocabRows as List)
        .map((r) => Vocabulary.fromJson(r as Map<String, dynamic>))
        .toList();
    seen.addAll(vocabs.map((v) => v.updatedAt));

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
        seen.addAll(defs.map((d) => d.updatedAt));

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
    seen.addAll(cols.map((c) => c.updatedAt));

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
    seen.addAll(vcList.map((m) => DateTime.parse(m['updated_at'] as String)));
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
      seen.add(settings.updatedAt);
      await _db.into(_db.userSettingsTable).insertOnConflictUpdate(
            settings.toDriftCompanion(),
          );
    }

    // 6. Save the cursor (newest server timestamp); no data -> next sync is full again
    final cursor = nextSyncCursor(null, seen);
    if (cursor != null) await setLastSyncAt(userId, cursor);
  }

  /// Incremental sync — pulls records with updated_at > lastSyncAt
  Future<DateTime> incrementalSync(String userId, DateTime lastSyncAt) async {
    final seen = <DateTime>[];
    final iso = syncQueryStart(lastSyncAt);

    // 1. Incremental Vocabularies
    final vocabRows = await _supabase
        .from('vocabularies')
        .select()
        .eq('user_id', userId)
        .gt('updated_at', iso);

    final vocabs = (vocabRows as List)
        .map((r) => Vocabulary.fromJson(r as Map<String, dynamic>))
        .toList();
    seen.addAll(vocabs.map((v) => v.updatedAt));

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
    seen.addAll(defs.map((d) => d.updatedAt));

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
    seen.addAll(cols.map((c) => c.updatedAt));

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
    seen.addAll(vcList.map((m) => DateTime.parse(m['updated_at'] as String)));
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
      seen.add(settings.updatedAt);
      await _db.into(_db.userSettingsTable).insertOnConflictUpdate(
            settings.toDriftCompanion(),
          );
    }

    final cursor = nextSyncCursor(lastSyncAt, seen)!;
    await setLastSyncAt(userId, cursor);
    return cursor;
  }
}
