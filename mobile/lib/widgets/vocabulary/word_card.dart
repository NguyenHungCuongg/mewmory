import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../db/daos/vocabulary_dao.dart';
import '../../l10n/app_localizations.dart';
import '../common/mew_card.dart';
import '../common/mew_chip.dart';

class WordCard extends StatelessWidget {
  final VocabularyWithDefinitions item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const WordCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);
    final vocab = item.vocabulary;
    final firstDef =
        item.definitions.isNotEmpty ? item.definitions.first : null;

    final wordStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: colors.ink,
    );
    final phoneticStyle = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: colors.ash,
    );

    final cardContent = MewCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Word + Phonetic + Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final hasPhonetic = vocab.phonetic != null &&
                        vocab.phonetic!.trim().isNotEmpty;

                    bool fitsOnSingleLine = false;
                    if (hasPhonetic) {
                      final tp = TextPainter(
                        text: TextSpan(
                          children: [
                            TextSpan(text: vocab.word, style: wordStyle),
                            const TextSpan(text: '   '),
                            TextSpan(
                                text: vocab.phonetic!, style: phoneticStyle),
                          ],
                        ),
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                      )..layout();
                      fitsOnSingleLine = tp.width <= availableWidth;
                    }

                    if (hasPhonetic && !fitsOnSingleLine) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            vocab.word,
                            style: wordStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vocab.phonetic!,
                            style: phoneticStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            vocab.word,
                            style: wordStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasPhonetic) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              vocab.phonetic!,
                              style: phoneticStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              if ((vocab.cefrLevel != null && vocab.cefrLevel!.isNotEmpty) ||
                  (vocab.partOfSpeech != null &&
                      vocab.partOfSpeech!.isNotEmpty)) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (vocab.cefrLevel != null &&
                        vocab.cefrLevel!.isNotEmpty) ...[
                      MewChip(
                        label: vocab.cefrLevel!,
                        customBgColor: colors.ink,
                        customTextColor: colors.eggshell,
                      ),
                      if (vocab.partOfSpeech != null &&
                          vocab.partOfSpeech!.isNotEmpty)
                        const SizedBox(width: 6),
                    ],
                    if (vocab.partOfSpeech != null &&
                        vocab.partOfSpeech!.isNotEmpty)
                      MewChip(
                        label: vocab.partOfSpeech!,
                      ),
                  ],
                ),
              ],
            ],
          ),

          // Row 2: Vietnamese Definition
          if (firstDef?.definitionVi != null &&
              firstDef!.definitionVi!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              firstDef.definitionVi!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colors.graphite,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Row 3: Example (if available)
          if (firstDef?.example != null &&
              firstDef!.example!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '“${firstDef.example!}”',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: colors.smoke,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    if (onDelete != null) {
      return Slidable(
        key: ValueKey(vocab.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: colors.error,
              foregroundColor: colors.eggshell,
              icon: Icons.delete_outline_rounded,
              label: l10n?.delete ?? 'Xóa',
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
