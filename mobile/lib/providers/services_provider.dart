import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart' as db;
import '../services/collection_service.dart';
import '../services/lookup_service.dart';
import '../services/settings_service.dart';
import '../services/sync_service.dart';
import '../services/vocabulary_service.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

final vocabularyServiceProvider = Provider<VocabularyService>((ref) {
  final db = ref.watch(databaseProvider);
  return VocabularyService(database: db);
});

final collectionServiceProvider = Provider<CollectionService>((ref) {
  final db = ref.watch(databaseProvider);
  return CollectionService(database: db);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(database: db);
});

final lookupServiceProvider = Provider<LookupService>((ref) {
  return LookupService();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsService(database: db);
});

final allCollectionsProvider =
    StreamProvider<List<db.CollectionWithCount>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  final colService = ref.watch(collectionServiceProvider);
  return colService.watchAll(user.id);
});
