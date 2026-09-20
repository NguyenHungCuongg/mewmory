import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../common/mew_card.dart';

class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    final title = l10n?.languageTitle ?? 'Ngôn ngữ';
    final viLabel = l10n?.langVietnamese ?? 'Tiếng Việt';
    final enLabel = l10n?.langEnglish ?? 'English';

    final options = [
      (
        locale: const Locale('vi'),
        code: 'VI',
        label: viLabel,
        desc: 'Tiếng Việt (Mặc định)',
      ),
      (
        locale: const Locale('en'),
        code: 'EN',
        label: enLabel,
        desc: 'English (US)',
      ),
    ];

    return MewCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language_outlined, size: 20, color: colors.ink),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final isSelected =
                (currentLocale?.languageCode ?? 'vi') == opt.locale.languageCode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                color: isSelected ? colors.eggshell : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? colors.ink : colors.stone,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? colors.ink : colors.stone,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      opt.code,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? colors.eggshell : colors.smoke,
                      ),
                    ),
                  ),
                  title: Text(
                    opt.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: colors.ink,
                    ),
                  ),
                  subtitle: Text(
                    opt.desc,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colors.smoke,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: colors.ink, size: 20)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(opt.locale);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
