import 'package:drift/drift.dart';

@DataClassName('UserSetting')
class UserSettingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id').unique()();
  TextColumn get aiProvider =>
      text().named('ai_provider').withDefault(const Constant('gemini'))();
  TextColumn get aiModel => text().named('ai_model').nullable()();
  BoolColumn get notificationEnabled => boolean()
      .named('notification_enabled')
      .withDefault(const Constant(true))();
  TextColumn get notificationMode => text()
      .named('notification_mode')
      .withDefault(const Constant('gentle'))();
  TextColumn get notificationTime =>
      text().named('notification_time').withDefault(const Constant('09:00'))();
  TextColumn get notificationCollections =>
      text().named('notification_collections').nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
