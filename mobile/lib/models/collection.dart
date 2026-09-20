import 'package:drift/drift.dart' show Value;
import 'package:json_annotation/json_annotation.dart';
import '../db/database.dart' hide Collection;

part 'collection.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Collection {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isDefault;
  final bool isAiGenerated;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int? wordCount;

  const Collection({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.isDefault = false,
    this.isAiGenerated = false,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.wordCount,
  });

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  factory Collection.fromDrift(dynamic driftCol, {int? wordCount}) {
    return Collection(
      id: driftCol.id,
      userId: driftCol.userId,
      name: driftCol.name,
      description: driftCol.description,
      isDefault: driftCol.isDefault,
      isAiGenerated: driftCol.isAiGenerated,
      createdAt: driftCol.createdAt,
      updatedAt: driftCol.updatedAt,
      isDeleted: driftCol.isDeleted,
      wordCount: wordCount,
    );
  }

  Collection copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    bool? isDefault,
    bool? isAiGenerated,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? wordCount,
  }) {
    return Collection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  CollectionsCompanion toDriftCompanion() {
    return CollectionsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      description: Value(description),
      isDefault: Value(isDefault),
      isAiGenerated: Value(isAiGenerated),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }
}
