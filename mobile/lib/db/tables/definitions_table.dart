import 'package:drift/drift.dart';
import 'vocabularies_table.dart';

@DataClassName('Definition')
class Definitions extends Table {
  TextColumn get id => text()();
  TextColumn get vocabularyId =>
      text().named('vocabulary_id').references(Vocabularies, #id)();
  TextColumn get definitionEn => text().named('definition_en').nullable()();
  TextColumn get definitionVi => text().named('definition_vi').nullable()();
  TextColumn get example => text().nullable()();
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
