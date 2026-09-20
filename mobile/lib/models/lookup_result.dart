import 'package:json_annotation/json_annotation.dart';

part 'lookup_result.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LookupResult {
  final String word;
  final String? phonetic;
  final String? audioUrl;
  final List<LookupMeaning> meanings;
  final List<String> suggestedCollections;
  final LookupSource? source;

  const LookupResult({
    required this.word,
    this.phonetic,
    this.audioUrl,
    this.meanings = const [],
    this.suggestedCollections = const [],
    this.source,
  });

  factory LookupResult.fromJson(Map<String, dynamic> json) =>
      _$LookupResultFromJson(json);

  Map<String, dynamic> toJson() => _$LookupResultToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LookupMeaning {
  final String? partOfSpeech;
  final String? cefrLevel;
  final String? usageRegister;
  final List<LookupDefinition> definitions;

  const LookupMeaning({
    this.partOfSpeech,
    this.cefrLevel,
    this.usageRegister,
    this.definitions = const [],
  });

  factory LookupMeaning.fromJson(Map<String, dynamic> json) =>
      _$LookupMeaningFromJson(json);

  Map<String, dynamic> toJson() => _$LookupMeaningToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LookupDefinition {
  final String? definitionEn;
  final String? definitionVi;
  final String? example;
  final List<String>? synonyms;
  final List<String>? antonyms;

  const LookupDefinition({
    this.definitionEn,
    this.definitionVi,
    this.example,
    this.synonyms,
    this.antonyms,
  });

  factory LookupDefinition.fromJson(Map<String, dynamic> json) =>
      _$LookupDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$LookupDefinitionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LookupSource {
  final bool? dictionary;
  final bool? ai;

  const LookupSource({
    this.dictionary,
    this.ai,
  });

  factory LookupSource.fromJson(Map<String, dynamic> json) =>
      _$LookupSourceFromJson(json);

  Map<String, dynamic> toJson() => _$LookupSourceToJson(this);
}
