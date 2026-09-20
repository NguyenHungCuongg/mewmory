import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/settings/account_section.dart';
import '../widgets/settings/ai_settings_section.dart';
import '../widgets/settings/language_section.dart';
import '../widgets/settings/theme_section.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';
    final settingsAsync = ref.watch(userSettingsNotifierProvider);
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    final title = l10n?.settingsTitle ?? 'Cài đặt';

    return Scaffold(
      backgroundColor: colors.eggshell,
      appBar: AppBar(
        backgroundColor: colors.eggshell,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.48,
            color: colors.ink,
          ),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Lỗi khi tải cài đặt: $err',
              style: GoogleFonts.inter(color: colors.error),
            ),
          ),
        ),
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Theme Section
              const ThemeSection(),
              const SizedBox(height: 16),

              // Language Section
              const LanguageSection(),
              const SizedBox(height: 16),

              // AI Settings
              AiSettingsSection(
                userId: userId,
                initialSettings: settings,
              ),
              const SizedBox(height: 16),

              // Account Section
              const AccountSection(),
              const SizedBox(height: 32),

              // App Version Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'Mewmory Mobile',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.smoke,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Phiên bản 1.0.0 (Alpha) • Online-First with Drift',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: colors.ash,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
