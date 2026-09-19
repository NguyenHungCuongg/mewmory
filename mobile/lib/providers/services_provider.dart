import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/collection_service.dart';
import '../services/lookup_service.dart';
import '../services/settings_service.dart';
import '../services/sync_service.dart';
import '../services/vocabulary_service.dart';
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
