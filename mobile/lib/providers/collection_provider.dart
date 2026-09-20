import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart' as db;
import 'auth_provider.dart';
import 'services_provider.dart';

/// Stream collections for a specific user ID
final collectionsProvider =
    StreamProvider.family<List<db.CollectionWithCount>, String>((ref, userId) {
  final colService = ref.watch(collectionServiceProvider);
  return colService.watchAll(userId);
});

/// Stream collections for current user
final myCollectionsProvider =
    StreamProvider<List<db.CollectionWithCount>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  final colService = ref.watch(collectionServiceProvider);
  return colService.watchAll(user.id);
});

/// Stream a single collection by ID
final collectionDetailProvider =
    StreamProvider.family<db.Collection?, String>((ref, collectionId) {
  final colService = ref.watch(collectionServiceProvider);
  return colService.watchById(collectionId);
});

/// Stream all words belonging to a specific collection for current user
final wordsInCollectionProvider =
    StreamProvider.family<List<db.VocabularyWithDefinitions>, String>(
        (ref, collectionId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  final vocabService = ref.watch(vocabularyServiceProvider);
  return vocabService.watchAll(user.id, collectionId: collectionId);
});
