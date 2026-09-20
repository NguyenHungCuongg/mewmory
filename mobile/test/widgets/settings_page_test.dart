import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/models/user_settings.dart';
import 'package:mewmory/pages/settings_page.dart';
import 'package:mewmory/providers/settings_provider.dart';
import 'package:mewmory/widgets/settings/account_section.dart';
import 'package:mewmory/widgets/settings/ai_settings_section.dart';

void main() {
  final testSettings = UserSettings(
    id: 'settings-1',
    userId: 'user-1',
    aiProvider: 'gemini',
    aiModel: 'gemini-1.5-flash',
    notificationEnabled: true,
    notificationMode: 'gentle',
    notificationTime: '09:00',
    updatedAt: DateTime(2026, 1, 1),
  );

  group('Settings UI Tests', () {
    testWidgets('SettingsPage renders AI settings, Account, and version footer',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSettingsNotifierProvider
                .overrideWith(() => _MockSettingsNotifier(testSettings)),
          ],
          child: const MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Page Title
      expect(find.text('Cài đặt'), findsOneWidget);

      // Verify AI section
      expect(find.byType(AiSettingsSection), findsOneWidget);
      expect(find.text('Cấu hình AI'), findsOneWidget);
      expect(find.text('Google Gemini (Mặc định)'), findsOneWidget);

      // Verify Account section
      expect(find.byType(AccountSection), findsOneWidget);
      expect(find.text('Tài khoản người dùng'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);

      // Verify Version footer
      expect(find.text('Mewmory Mobile'), findsOneWidget);
      expect(
        find.text('Phiên bản 1.0.0 (Alpha) • Online-First with Drift'),
        findsOneWidget,
      );
    });

    testWidgets('AiSettingsSection displays provider and model fields',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSettingsNotifierProvider
                .overrideWith(() => _MockSettingsNotifier(testSettings)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AiSettingsSection(
                userId: 'user-1',
                initialSettings: null,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nhà cung cấp (AI Provider)'), findsOneWidget);
      expect(find.text('Mô hình AI (Tùy chọn)'), findsOneWidget);
      expect(find.text('Lưu cấu hình'), findsOneWidget);
    });
  });
}

class _MockSettingsNotifier extends UserSettingsNotifier {
  final UserSettings? initial;
  _MockSettingsNotifier(this.initial);

  @override
  Future<UserSettings?> build() async => initial;
}
