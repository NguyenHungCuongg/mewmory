import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/l10n/app_localizations.dart';

void main() {
  testWidgets('AppLocalizations loads correct translations for VI and EN', (tester) async {
    late AppLocalizations viL10n;
    late AppLocalizations enL10n;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            viL10n = AppLocalizations.of(context)!;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(viL10n.tabHome, 'Trang chủ');
    expect(viL10n.tabVocabulary, 'Từ vựng');
    expect(viL10n.dailyReviewTitle, 'Luyện tập hàng ngày');

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            enL10n = AppLocalizations.of(context)!;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(enL10n.tabHome, 'Home');
    expect(enL10n.tabVocabulary, 'Vocabulary');
    expect(enL10n.dailyReviewTitle, 'Daily Review');
  });
}
