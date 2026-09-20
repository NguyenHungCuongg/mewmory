import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../common/mew_card.dart';

class ThemeSection extends ConsumerWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    final title = l10n?.themeTitle ?? 'Giao diện';
    final systemTitle = l10n?.themeSystem ?? 'Hệ thống';
    final systemDesc = l10n?.themeSystemDesc ?? 'Theo cài đặt thiết bị';
    final lightTitle = l10n?.themeLight ?? 'Sáng';
    final lightDesc = l10n?.themeLightDesc ?? 'Giao diện thanh lịch ban ngày';
    final darkTitle = l10n?.themeDark ?? 'Tối';
    final darkDesc = l10n?.themeDarkDesc ?? 'Dịu mắt ban đêm';

    final options = [
      (
        mode: ThemeMode.system,
        icon: Icons.brightness_auto_outlined,
        label: systemTitle,
        desc: systemDesc,
      ),
      (
        mode: ThemeMode.light,
        icon: Icons.light_mode_outlined,
        label: lightTitle,
        desc: lightDesc,
      ),
      (
        mode: ThemeMode.dark,
        icon: Icons.dark_mode_outlined,
        label: darkTitle,
        desc: darkDesc,
      ),
    ];

    return MewCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 20, color: colors.ink),
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
            final isSelected = currentMode == opt.mode;
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
                  leading: Icon(
                    opt.icon,
                    color: isSelected ? colors.ink : colors.smoke,
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
                    ref.read(themeModeProvider.notifier).setThemeMode(opt.mode);
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
