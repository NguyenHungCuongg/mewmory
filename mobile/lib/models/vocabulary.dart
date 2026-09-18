import 'package:drift/drift.dart' show Value;
import 'package:json_annotation/json_annotation.dart';
import '../db/database.dart' hide Vocabulary, Definition;
import 'definition.dart';

part 'vocabulary.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Vocabulary {
  final String id;
  final String userId;
  final String word;
  final String? phonetic;
  final String? audioUrl;
  final String? partOfSpeech;
  final String? cefrLevel;
  final String? usageRegister;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final List<Definition>? definitions;
  final List<String>? collectionIds;

  const Vocabulary({
    required this.id,
    required this.userId,
    required this.word,
    this.phonetic,
    this.audioUrl,
    this.partOfSpeech,
    this.cefrLevel,
    this.usageRegister,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.definitions,
    this.collectionIds,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) =>
      _$VocabularyFromJson(json);

  Map<String, dynamic> toJson() => _$VocabularyToJson(this);

  VocabulariesCompanion toDriftCompanion() {
    return VocabulariesCompanion(
      id: Value(id),
      userId: Value(userId),
      word: Value(word),
      phonetic: Value(phonetic),
      audioUrl: Value(audioUrl),
      partOfSpeech: Value(partOfSpeech),
      cefrLevel: Value(cefrLevel),
      usageRegister: Value(usageRegister),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }
}
