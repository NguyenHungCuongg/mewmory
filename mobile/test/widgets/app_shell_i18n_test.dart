import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/app.dart';
import 'package:mewmory/providers/theme_provider.dart';
import 'package:mewmory/widgets/common/language_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LanguageSwitcher toggles language and updates bottom navigation labels', (tester) async {
    SharedPreferences.setMockInitialValues({'mewmory-locale': 'vi'});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MewmoryApp(
          router: createRouter(enableAuthRedirect: false, initialLocation: '/dashboard'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Từ vựng'), findsOneWidget);
    expect(find.text('Bộ sưu tập'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);

    final switcher = find.byType(LanguageSwitcher);
    expect(switcher, findsOneWidget);

    await tester.tap(switcher);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Vocabulary'), findsOneWidget);
    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(prefs.getString('mewmory-locale'), 'en');
  });
}
