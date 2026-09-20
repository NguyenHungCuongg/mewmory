import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/db/database.dart';
import 'package:mewmory/models/user_settings.dart';
import 'package:mewmory/services/collection_service.dart';
import 'package:mewmory/services/settings_service.dart';

void main() {
  late AppDatabase db;
  late CollectionService colService;
  late SettingsService setService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    colService = CollectionService(database: db);
    setService = SettingsService(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CollectionService (Local Cache Operations)', () {
    const userId = 'user-col-test';

    test('watchAll and getAll return collections with word count', () async {
      final now = DateTime.now();

      await db.collectionDao.upsert(
        CollectionsCompanion.insert(
          id: 'c-100',
          userId: userId,
          name: 'Academic Words',
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final cols = await colService.getAll(userId);
      expect(cols.length, 1);
      expect(cols.first.collection.name, 'Academic Words');
      expect(cols.first.wordCount, 0);

      final single = await colService.getById('c-100');
      expect(single, isNotNull);
      expect(single!.name, 'Academic Words');
    });

    test('delete marks collection as deleted in local cache', () async {
      final now = DateTime.now();

      await db.collectionDao.upsert(
        CollectionsCompanion.insert(
          id: 'c-200',
          userId: userId,
          name: 'Temporary List',
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await db.collectionDao.deleteCollection('c-200');

      final cols = await colService.getAll(userId);
      expect(cols.isEmpty, true);
    });
  });

  group('SettingsService (Local Cache Operations)', () {
    const userId = 'user-settings-test';

    test('get retrieves cached settings correctly', () async {
      final now = DateTime.now();

      final settings = UserSettings(
        id: 's-100',
        userId: userId,
        aiProvider: 'openrouter',
        aiModel: 'claude-3.5-sonnet',
        notificationCollections: ['c-1', 'c-2'],
        updatedAt: now,
      );

      await db.into(db.userSettingsTable).insert(settings.toDriftCompanion());

      final cached = await setService.get(userId);
      expect(cached, isNotNull);
      expect(cached!.aiProvider, 'openrouter');
      expect(cached.aiModel, 'claude-3.5-sonnet');
      expect(cached.notificationCollections, ['c-1', 'c-2']);
    });
  });
}
