import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lookup_provider.dart';
import '../common/mew_button.dart';
import '../common/mew_chip.dart';
import '../common/mew_text_field.dart';
import 'definition_tile.dart';

class MeaningSelector extends ConsumerWidget {
  const MeaningSelector({super.key});

  void _showEditDefinitionDialog(
    BuildContext context,
    WidgetRef ref,
    int meaningIndex,
    int defIndex,
    EditableDefinition def,
  ) {
    final viController = TextEditingController(text: def.definitionVi ?? '');
    final enController = TextEditingController(text: def.definitionEn ?? '');
    final exampleController = TextEditingController(text: def.example ?? '');

    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.eggshell,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chỉnh sửa nghĩa',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 16),
              MewTextField(
                controller: viController,
                label: l10n?.meaningVi ?? 'Nghĩa tiếng Việt',
                hintText: 'Ví dụ: Kiên cường, bền bỉ',
              ),
              const SizedBox(height: 12),
              MewTextField(
                controller: enController,
                label: l10n?.meaningEn ?? 'Định nghĩa tiếng Anh (tùy chọn)',
                hintText: 'Ví dụ: Able to recover quickly',
              ),
              const SizedBox(height: 12),
              MewTextField(
                controller: exampleController,
                label: l10n?.exampleSentence ?? 'Câu ví dụ (tùy chọn)',
                hintText: 'Ví dụ: She is very resilient.',
              ),
              const SizedBox(height: 20),
              MewButton.filled(
                label: l10n?.confirm ?? 'Xong',
                onPressed: () {
                  ref.read(lookupProvider.notifier).updateDefinition(
                        meaningIndex,
                        defIndex,
                        defVi: viController.text.trim(),
                        defEn: enController.text.trim(),
                        example: exampleController.text.trim(),
                      );
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeaningCard(
    BuildContext context,
    WidgetRef ref,
    int mIdx,
    EditableMeaning meaning,
  ) {
    final colors = context.mewColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colors.warmTaupe,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.stone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: Part of Speech + Badges
          Row(
            children: [
              if (meaning.partOfSpeech != null &&
                  meaning.partOfSpeech!.isNotEmpty)
                Text(
                  meaning.partOfSpeech!.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colors.ink,
                  ),
                ),
              const Spacer(),
              if (meaning.cefrLevel != null &&
                  meaning.cefrLevel!.isNotEmpty) ...[
                MewChip(
                  label: meaning.cefrLevel!,
                  customBgColor: colors.ink,
                  customTextColor: colors.eggshell,
                ),
                const SizedBox(width: 6),
              ],
              if (meaning.usageRegister != null &&
                  meaning.usageRegister!.isNotEmpty) ...[
                MewChip(
                  label: meaning.usageRegister!,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Definitions List
          for (var dIdx = 0; dIdx < meaning.definitions.length; dIdx++)
            DefinitionTile(
              definition: meaning.definitions[dIdx],
              onToggle: (_) {
                ref
                    .read(lookupProvider.notifier)
                    .toggleDefinitionSelection(mIdx, dIdx);
              },
              onEdit: () => _showEditDefinitionDialog(
                context,
                ref,
                mIdx,
                dIdx,
                meaning.definitions[dIdx],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookupState = ref.watch(lookupProvider);
    final meanings = lookupState.editableMeanings;

    if (meanings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var mIdx = 0; mIdx < meanings.length; mIdx++)
          _buildMeaningCard(context, ref, mIdx, meanings[mIdx]),
      ],
    );
  }
}
