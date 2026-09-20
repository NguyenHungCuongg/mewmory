import 'package:drift/drift.dart';

@DataClassName('Vocabulary')
class Vocabularies extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get word => text()();
  TextColumn get phonetic => text().nullable()();
  TextColumn get audioUrl => text().named('audio_url').nullable()();
  TextColumn get partOfSpeech => text().named('part_of_speech').nullable()();
  TextColumn get cefrLevel => text().named('cefr_level').nullable()();
  TextColumn get usageRegister => text().named('usage_register').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
