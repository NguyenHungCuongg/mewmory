import 'package:drift/drift.dart' show Value;
import 'package:json_annotation/json_annotation.dart';
import '../db/database.dart' hide Definition;

part 'definition.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Definition {
  final String id;
  final String vocabularyId;
  final String? definitionEn;
  final String? definitionVi;
  final String? example;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Definition({
    required this.id,
    required this.vocabularyId,
    this.definitionEn,
    this.definitionVi,
    this.example,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  factory Definition.fromJson(Map<String, dynamic> json) =>
      _$DefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$DefinitionToJson(this);

  DefinitionsCompanion toDriftCompanion() {
    return DefinitionsCompanion(
      id: Value(id),
      vocabularyId: Value(vocabularyId),
      definitionEn: Value(definitionEn),
      definitionVi: Value(definitionVi),
      example: Value(example),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }
}
