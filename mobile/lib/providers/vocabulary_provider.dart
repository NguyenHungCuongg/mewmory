import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database.dart' as db;
import 'auth_provider.dart';
import 'services_provider.dart';

class VocabularyFilters {
  final String? searchQuery;
  final String? cefrLevel;
  final String? partOfSpeech;
  final String? usageRegister;
  final String? collectionId;
  final String sortBy;
  final bool ascending;

  const VocabularyFilters({
    this.searchQuery,
    this.cefrLevel,
    this.partOfSpeech,
    this.usageRegister,
    this.collectionId,
    this.sortBy = 'created_at',
    this.ascending = false,
  });

  VocabularyFilters copyWith({
    String? searchQuery,
    String? cefrLevel,
    String? partOfSpeech,
    String? usageRegister,
    String? collectionId,
    String? sortBy,
    bool? ascending,
    bool clearSearch = false,
    bool clearCefr = false,
    bool clearPos = false,
    bool clearUsage = false,
    bool clearCollection = false,
  }) {
    return VocabularyFilters(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      cefrLevel: clearCefr ? null : (cefrLevel ?? this.cefrLevel),
      partOfSpeech: clearPos ? null : (partOfSpeech ?? this.partOfSpeech),
      usageRegister: clearUsage ? null : (usageRegister ?? this.usageRegister),
      collectionId:
          clearCollection ? null : (collectionId ?? this.collectionId),
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  bool get hasActiveFilters =>
      (cefrLevel != null && cefrLevel!.isNotEmpty) ||
      (partOfSpeech != null && partOfSpeech!.isNotEmpty) ||
      (usageRegister != null && usageRegister!.isNotEmpty) ||
      (collectionId != null && collectionId!.isNotEmpty);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyFilters &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          cefrLevel == other.cefrLevel &&
          partOfSpeech == other.partOfSpeech &&
          usageRegister == other.usageRegister &&
          collectionId == other.collectionId &&
          sortBy == other.sortBy &&
          ascending == other.ascending;

  @override
  int get hashCode => Object.hash(
        searchQuery,
        cefrLevel,
        partOfSpeech,
        usageRegister,
        collectionId,
        sortBy,
        ascending,
      );
}

class VocabularyFilterNotifier extends Notifier<VocabularyFilters> {
  @override
  VocabularyFilters build() => const VocabularyFilters();

  void setSearchQuery(String query) {
    state =
        state.copyWith(searchQuery: query.trim().isEmpty ? null : query.trim());
  }

  void setCefrLevel(String? level) {
    if (state.cefrLevel == level) {
      state = state.copyWith(clearCefr: true);
    } else {
      state = state.copyWith(cefrLevel: level);
    }
  }

  void setPartOfSpeech(String? pos) {
    if (state.partOfSpeech == pos) {
      state = state.copyWith(clearPos: true);
    } else {
      state = state.copyWith(partOfSpeech: pos);
    }
  }

  void setUsageRegister(String? register) {
    if (state.usageRegister == register) {
      state = state.copyWith(clearUsage: true);
    } else {
      state = state.copyWith(usageRegister: register);
    }
  }

  void setCollectionId(String? collectionId) {
    if (state.collectionId == collectionId) {
      state = state.copyWith(clearCollection: true);
    } else {
      state = state.copyWith(collectionId: collectionId);
    }
  }

  void setSorting(String sortBy, {bool ascending = false}) {
    state = state.copyWith(sortBy: sortBy, ascending: ascending);
  }

  void resetFilters() {
    state = VocabularyFilters(searchQuery: state.searchQuery);
  }

  void clearAll() {
    state = const VocabularyFilters();
  }
}

final vocabularyFilterProvider =
    NotifierProvider<VocabularyFilterNotifier, VocabularyFilters>(
  VocabularyFilterNotifier.new,
);

final vocabularyListProvider =
    StreamProvider<List<db.VocabularyWithDefinitions>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);

  final filters = ref.watch(vocabularyFilterProvider);
  final vocabService = ref.watch(vocabularyServiceProvider);

  return vocabService.watchAll(
    user.id,
    searchQuery: filters.searchQuery,
    cefrLevel: filters.cefrLevel,
    partOfSpeech: filters.partOfSpeech,
    usageRegister: filters.usageRegister,
    collectionId: filters.collectionId,
    sortBy: filters.sortBy,
    ascending: filters.ascending,
  );
});
