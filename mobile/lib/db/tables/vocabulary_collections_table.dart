import 'package:drift/drift.dart';
import 'vocabularies_table.dart';
import 'collections_table.dart';

@DataClassName('VocabularyCollection')
class VocabularyCollections extends Table {
  TextColumn get id => text()();
  TextColumn get vocabularyId =>
      text().named('vocabulary_id').references(Vocabularies, #id)();
  TextColumn get collectionId =>
      text().named('collection_id').references(Collections, #id)();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
