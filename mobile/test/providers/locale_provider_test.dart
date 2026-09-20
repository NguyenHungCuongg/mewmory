import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/providers/locale_provider.dart';
import 'package:mewmory/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider Tests', () {
    test('defaults to Locale("vi") when no preference is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(localeProvider), const Locale('vi'));
    });

    test('loads saved English locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'mewmory-locale': 'en'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(localeProvider), const Locale('en'));
    });

    test('setLocale sets locale and writes to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await container.read(localeProvider.notifier).setLocale(const Locale('en'));
      expect(container.read(localeProvider), const Locale('en'));
      expect(prefs.getString('mewmory-locale'), 'en');

      await container.read(localeProvider.notifier).setLocale(const Locale('vi'));
      expect(container.read(localeProvider), const Locale('vi'));
      expect(prefs.getString('mewmory-locale'), 'vi');
    });

    test('toggleLocale switches between vi and en and saves to prefs', () async {
      SharedPreferences.setMockInitialValues({'mewmory-locale': 'vi'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await container.read(localeProvider.notifier).toggleLocale();
      expect(container.read(localeProvider), const Locale('en'));
      expect(prefs.getString('mewmory-locale'), 'en');

      await container.read(localeProvider.notifier).toggleLocale();
      expect(container.read(localeProvider), const Locale('vi'));
      expect(prefs.getString('mewmory-locale'), 'vi');
    });
  });
}
