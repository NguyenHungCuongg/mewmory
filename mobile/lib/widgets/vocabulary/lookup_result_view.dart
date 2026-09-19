import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lookup_provider.dart';
import '../common/mew_card.dart';
import '../common/mew_chip.dart';
import 'meaning_selector.dart';

class LookupResultView extends ConsumerStatefulWidget {
  const LookupResultView({super.key});

  @override
  ConsumerState<LookupResultView> createState() => _LookupResultViewState();
}

class _LookupResultViewState extends ConsumerState<LookupResultView> {
  AudioPlayer? _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player?.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    if (_player == null || url.isEmpty) return;

    try {
      if (_isPlaying) {
        await _player!.stop();
      } else {
        await _player!.play(UrlSource(url));
      }
    } catch (_) {
      // Audio play error fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final lookupState = ref.watch(lookupProvider);
    final result = lookupState.result;

    if (result == null) return const SizedBox.shrink();

    final user = ref.watch(currentUserProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word Header Card
        MewCard.elevated(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.word,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.56,
                            color: MewColors.ink,
                          ),
                        ),
                        if (result.phonetic != null &&
                            result.phonetic!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            result.phonetic!,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: MewColors.ash,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (result.audioUrl != null &&
                      result.audioUrl!.isNotEmpty) ...[
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: MewColors.warmTaupe,
                        foregroundColor: MewColors.ink,
                        shape: const CircleBorder(),
                        side: const BorderSide(color: MewColors.stone),
                      ),
                      icon: Icon(
                        _isPlaying
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        size: 24,
                      ),
                      onPressed: () => _playAudio(result.audioUrl!),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // AI Suggested Collections Section
        if (result.suggestedCollections.isNotEmpty || user != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'Gợi ý bộ sưu tập',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MewColors.ink,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.suggestedCollections.map((colName) {
              final isSelected =
                  lookupState.selectedCollectionIds.contains(colName);
              return MewChip(
                label: colName,
                isSelected: isSelected,
                avatar: const Icon(Icons.folder_outlined, size: 14),
                onSelected: (_) {
                  ref
                      .read(lookupProvider.notifier)
                      .toggleCollectionSelection(colName);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Meanings & Definitions Selector
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Row(
            children: [
              Text(
                'Chọn nghĩa để lưu',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MewColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                'Đã chọn ${lookupState.selectedDefinitionsCount} nghĩa',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: MewColors.smoke,
                ),
              ),
            ],
          ),
        ),
        const MeaningSelector(),
      ],
    );
  }
}
