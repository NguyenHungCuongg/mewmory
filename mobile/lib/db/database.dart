import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/vocabularies_table.dart';
import 'tables/definitions_table.dart';
import 'tables/collections_table.dart';
import 'tables/vocabulary_collections_table.dart';
import 'tables/user_settings_table.dart';
import 'daos/vocabulary_dao.dart';
import 'daos/collection_dao.dart';
import 'daos/stats_dao.dart';

export 'daos/vocabulary_dao.dart';
export 'daos/collection_dao.dart';
export 'daos/stats_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Vocabularies,
    Definitions,
    Collections,
    VocabularyCollections,
    UserSettingsTable,
  ],
  daos: [
    VocabularyDao,
    CollectionDao,
    StatsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'mewmory.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
