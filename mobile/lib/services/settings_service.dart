import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/database.dart' as db;
import '../models/user_settings.dart';

class SettingsService {
  final SupabaseClient? _client;
  final db.AppDatabase _db;

  SettingsService({
    SupabaseClient? client,
    required db.AppDatabase database,
  })  : _client = client,
        _db = database;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  /// Get user settings: checks local Drift cache first; if empty, fetches from Supabase
  Future<UserSettings?> get(String userId) async {
    // 1. Check local cache
    final localQuery = _db.select(_db.userSettingsTable)
      ..where((s) => s.userId.equals(userId));
    final localRow = await localQuery.getSingleOrNull();

    if (localRow != null) {
      List<String>? notificationCols;
      if (localRow.notificationCollections != null) {
        try {
          final decoded = jsonDecode(localRow.notificationCollections!);
          if (decoded is List) {
            notificationCols = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }

      return UserSettings(
        id: localRow.id,
        userId: localRow.userId,
        aiProvider: localRow.aiProvider,
        aiModel: localRow.aiModel,
        notificationEnabled: localRow.notificationEnabled,
        notificationMode: localRow.notificationMode,
        notificationTime: localRow.notificationTime,
        notificationCollections: notificationCols,
        updatedAt: localRow.updatedAt,
      );
    }

    // 2. Fallback to Supabase
    try {
      final remoteRow = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (remoteRow != null) {
        final settings = UserSettings.fromJson(remoteRow);
        await _db.into(_db.userSettingsTable).insertOnConflictUpdate(
              settings.toDriftCompanion(),
            );
        return settings;
      }
    } catch (_) {
      // Return null or default if offline and not in cache
    }

    return null;
  }

  /// Update user settings on Supabase, then update local Drift cache
  Future<void> update(UserSettings settings) async {
    final now = DateTime.now();

    await _supabase.from('user_settings').upsert({
      'id': settings.id,
      'user_id': settings.userId,
      'ai_provider': settings.aiProvider,
      'ai_model': settings.aiModel,
      'notification_enabled': settings.notificationEnabled,
      'notification_mode': settings.notificationMode,
      'notification_time': settings.notificationTime,
      'notification_collections': settings.notificationCollections,
      'updated_at': now.toIso8601String(),
    });

    await _db.into(_db.userSettingsTable).insertOnConflictUpdate(
          settings.toDriftCompanion(),
        );
  }
}
