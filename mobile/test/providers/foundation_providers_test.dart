import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/db/database.dart';
import 'package:mewmory/providers/database_provider.dart';
import 'package:mewmory/providers/connectivity_provider.dart';
import 'package:mewmory/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Foundation Providers', () {
    test('databaseProvider provides AppDatabase and disposes correctly', () {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) {
            final db = AppDatabase(NativeDatabase.memory());
            ref.onDispose(() => db.close());
            return db;
          }),
        ],
      );

      final db = container.read(databaseProvider);
      expect(db, isA<AppDatabase>());
      container.dispose();
    });

    test('connectivityProvider can be read and overridden', () {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith((ref) => Stream.value(true)),
        ],
      );

      final state = container.read(connectivityProvider);
      expect(state, isA<AsyncValue<bool>>());
      container.dispose();
    });

    test('currentUserProvider defaults to null when not authenticated', () {
      final container = ProviderContainer();
      final user = container.read(currentUserProvider);
      expect(user, isNull);
      container.dispose();
    });
  });
}
