import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart' as db;
import 'auth_provider.dart';
import 'database_provider.dart';
import 'services_provider.dart';

final totalWordCountProvider =
    FutureProvider.family<int, String>((ref, userId) {
  final database = ref.watch(databaseProvider);
  return database.statsDao.getTotalCount(userId);
});

final levelDistributionProvider =
    FutureProvider.family<Map<String, int>, String>((ref, userId) {
  final database = ref.watch(databaseProvider);
  return database.statsDao.getLevelDistribution(userId);
});

final randomWordProvider =
    FutureProvider.family<db.VocabularyWithDefinitions?, String>((ref, userId) {
  final database = ref.watch(databaseProvider);
  return database.vocabularyDao.getRandomWord(userId);
});

final wordsLearnedThisWeekProvider =
    FutureProvider.family<int, String>((ref, userId) {
  final database = ref.watch(databaseProvider);
  return database.statsDao.getWordsLearnedThisWeek(userId);
});

final wordsLearnedTodayProvider =
    FutureProvider.family<int, String>((ref, userId) {
  final database = ref.watch(databaseProvider);
  return database.statsDao.getWordsLearnedToday(userId);
});

/// AsyncNotifier for Daily Review random word with nextWord capability
class DailyReviewNotifier extends AsyncNotifier<db.VocabularyWithDefinitions?> {
  @override
  Future<db.VocabularyWithDefinitions?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;
    final vocabService = ref.watch(vocabularyServiceProvider);
    return vocabService.getRandomWord(user.id);
  }

  Future<void> nextWord() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final vocabService = ref.read(vocabularyServiceProvider);
      return vocabService.getRandomWord(user.id);
    });
  }
}

final dailyReviewWordProvider =
    AsyncNotifierProvider<DailyReviewNotifier, db.VocabularyWithDefinitions?>(
  DailyReviewNotifier.new,
);
