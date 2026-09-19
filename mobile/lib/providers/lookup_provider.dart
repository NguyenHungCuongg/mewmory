import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/lookup_result.dart';
import 'services_provider.dart';

enum LookupStatus { idle, loading, success, error }

class EditableDefinition {
  final String id;
  String? definitionEn;
  String? definitionVi;
  String? example;
  int sortOrder;
  bool isSelected;

  EditableDefinition({
    required this.id,
    this.definitionEn,
    this.definitionVi,
    this.example,
    this.sortOrder = 0,
    this.isSelected = true,
  });
}

class EditableMeaning {
  final String? partOfSpeech;
  final String? cefrLevel;
  final String? usageRegister;
  final List<EditableDefinition> definitions;

  EditableMeaning({
    this.partOfSpeech,
    this.cefrLevel,
    this.usageRegister,
    required this.definitions,
  });
}

class LookupState {
  final LookupStatus status;
  final LookupResult? result;
  final List<EditableMeaning> editableMeanings;
  final List<String> selectedCollectionIds;
  final String? errorMessage;
  final bool isAudioPlaying;

  const LookupState({
    this.status = LookupStatus.idle,
    this.result,
    this.editableMeanings = const [],
    this.selectedCollectionIds = const [],
    this.errorMessage,
    this.isAudioPlaying = false,
  });

  LookupState copyWith({
    LookupStatus? status,
    LookupResult? result,
    List<EditableMeaning>? editableMeanings,
    List<String>? selectedCollectionIds,
    String? errorMessage,
    bool? isAudioPlaying,
  }) {
    return LookupState(
      status: status ?? this.status,
      result: result ?? this.result,
      editableMeanings: editableMeanings ?? this.editableMeanings,
      selectedCollectionIds:
          selectedCollectionIds ?? this.selectedCollectionIds,
      errorMessage: errorMessage ?? this.errorMessage,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
    );
  }

  int get selectedDefinitionsCount {
    var count = 0;
    for (final meaning in editableMeanings) {
      for (final def in meaning.definitions) {
        if (def.isSelected) count++;
      }
    }
    return count;
  }
}

class LookupNotifier extends Notifier<LookupState> {
  @override
  LookupState build() => const LookupState();

  Future<void> lookupWord(String word) async {
    final cleanWord = word.trim();
    if (cleanWord.isEmpty) return;

    state = state.copyWith(status: LookupStatus.loading, errorMessage: null);

    try {
      final lookupService = ref.read(lookupServiceProvider);
      final result = await lookupService.lookupWord(cleanWord);

      const uuid = Uuid();
      final editableMeanings = <EditableMeaning>[];

      for (final meaning in result.meanings) {
        final defs = <EditableDefinition>[];
        for (var i = 0; i < meaning.definitions.length; i++) {
          final d = meaning.definitions[i];
          defs.add(
            EditableDefinition(
              id: uuid.v4(),
              definitionEn: d.definitionEn,
              definitionVi: d.definitionVi,
              example: d.example,
              sortOrder: i,
              isSelected: true,
            ),
          );
        }

        editableMeanings.add(
          EditableMeaning(
            partOfSpeech: meaning.partOfSpeech,
            cefrLevel: meaning.cefrLevel,
            usageRegister: meaning.usageRegister,
            definitions: defs,
          ),
        );
      }

      state = state.copyWith(
        status: LookupStatus.success,
        result: result,
        editableMeanings: editableMeanings,
        selectedCollectionIds: [],
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: LookupStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void toggleDefinitionSelection(int meaningIndex, int defIndex) {
    final meanings = List<EditableMeaning>.from(state.editableMeanings);
    final def = meanings[meaningIndex].definitions[defIndex];
    def.isSelected = !def.isSelected;
    state = state.copyWith(editableMeanings: meanings);
  }

  void updateDefinition(
    int meaningIndex,
    int defIndex, {
    String? defEn,
    String? defVi,
    String? example,
  }) {
    final meanings = List<EditableMeaning>.from(state.editableMeanings);
    final def = meanings[meaningIndex].definitions[defIndex];
    if (defEn != null) def.definitionEn = defEn;
    if (defVi != null) def.definitionVi = defVi;
    if (example != null) def.example = example;
    state = state.copyWith(editableMeanings: meanings);
  }

  void toggleCollectionSelection(String collectionId) {
    final list = List<String>.from(state.selectedCollectionIds);
    if (list.contains(collectionId)) {
      list.remove(collectionId);
    } else {
      list.add(collectionId);
    }
    state = state.copyWith(selectedCollectionIds: list);
  }

  void setAudioPlaying(bool isPlaying) {
    state = state.copyWith(isAudioPlaying: isPlaying);
  }

  void reset() {
    state = const LookupState();
  }
}

final lookupProvider = NotifierProvider<LookupNotifier, LookupState>(
  LookupNotifier.new,
);
