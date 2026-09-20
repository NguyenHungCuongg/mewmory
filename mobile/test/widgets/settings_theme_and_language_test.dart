import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/config/theme.dart';
import 'package:mewmory/l10n/app_localizations.dart';
import 'package:mewmory/pages/settings_page.dart';
import 'package:mewmory/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsPage renders theme options and switches themeMode', (tester) async {
    SharedPreferences.setMockInitialValues({'mewmory-theme': 'system'});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: MewTheme.light,
          darkTheme: MewTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('vi'),
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Giao diện'), findsOneWidget);
    expect(find.text('Ngôn ngữ'), findsOneWidget);

    // Tap on Dark theme option
    await tester.tap(find.text('Tối'));
    await tester.pumpAndSettle();

    expect(prefs.getString('mewmory-theme'), 'dark');

    // Tap on English language option
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(prefs.getString('mewmory-locale'), 'en');
  });
}
