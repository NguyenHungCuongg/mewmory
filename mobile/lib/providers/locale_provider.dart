import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';

const String localePreferenceKey = 'mewmory-locale';

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      final stored = prefs.getString(localePreferenceKey);
      if (stored == 'en') {
        return const Locale('en');
      } else if (stored == 'vi') {
        return const Locale('vi');
      }
      return const Locale('vi');
    } catch (_) {
      return const Locale('vi');
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) return;
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(localePreferenceKey, locale.languageCode);
    } catch (_) {
      // Ignore write errors in memory/testing mode
    }
  }

  Future<void> toggleLocale() async {
    final currentCode = state?.languageCode ?? 'vi';
    final next = currentCode == 'vi' ? const Locale('en') : const Locale('vi');
    await setLocale(next);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
