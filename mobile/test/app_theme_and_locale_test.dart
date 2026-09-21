import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/app.dart';
import 'package:mewmory/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MewmoryApp dynamically applies themeMode and locale from providers', (tester) async {
    SharedPreferences.setMockInitialValues({
      'mewmory-theme': 'dark',
      'mewmory-locale': 'en',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MewmoryApp(
          router: createRouter(enableAuthRedirect: false, initialLocation: '/dashboard'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(materialApp.locale, const Locale('en'));
    expect(materialApp.darkTheme, isNotNull);
  });
}
