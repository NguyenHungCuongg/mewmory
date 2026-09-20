import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../common/mew_card.dart';

class StatsSummaryCard extends StatelessWidget {
  final int totalCount;
  final int weekCount;
  final Map<String, int> levelDistribution;
  final VoidCallback? onTap;

  const StatsSummaryCard({
    super.key,
    required this.totalCount,
    required this.weekCount,
    required this.levelDistribution,
    this.onTap,
  });

  static const Map<String, Color> _levelColors = {
    'A1': Color(0xFF4CAF50),
    'A2': Color(0xFF8BC34A),
    'B1': Color(0xFFFFB300),
    'B2': Color(0xFFFF7043),
    'C1': Color(0xFFE53935),
    'C2': Color(0xFF8E24AA),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    // Standardize CEFR levels order
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final nonZeroLevels = levels
        .where((l) => (levelDistribution[l] ?? 0) > 0)
        .toList();

    return MewCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thống kê từ vựng',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colors.smoke,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Total Count + Weekly Count
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalCount',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1.0,
                  color: colors.ink,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'từ vựng đã lưu',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.smoke,
                ),
              ),
              const Spacer(),
              if (weekCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: colors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '+$weekCount tuần này',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // CEFR Level Bar
          if (totalCount > 0 && nonZeroLevels.isNotEmpty) ...[
            Text(
              l10n?.cefrDistribution ?? 'Phân bố cấp độ CEFR',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.graphite,
              ),
            ),
            const SizedBox(height: 8),

            // Segmented Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: nonZeroLevels.map((lvl) {
                    final count = levelDistribution[lvl] ?? 0;
                    final flex = ((count / totalCount) * 100).round();
                    return Expanded(
                      flex: flex > 0 ? flex : 1,
                      child: Container(
                        color: _levelColors[lvl] ?? colors.ash,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Legend Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: nonZeroLevels.map((lvl) {
                final count = levelDistribution[lvl] ?? 0;
                final color = _levelColors[lvl] ?? colors.ash;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$lvl: $count',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.graphite,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ] else ...[
            Text(
              'Chưa có dữ liệu phân bố cấp độ.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: colors.smoke,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
