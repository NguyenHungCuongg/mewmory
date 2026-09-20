import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../db/daos/vocabulary_dao.dart';
import '../../providers/stats_provider.dart';
import '../common/mew_button.dart';
import '../common/mew_card.dart';
import '../common/mew_chip.dart';
import '../common/loading_indicator.dart';

enum ReviewMode { gentle, flashcard }

class DailyReviewCard extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback? onAddWord;

  const DailyReviewCard({
    super.key,
    required this.userId,
    this.onAddWord,
  });

  @override
  ConsumerState<DailyReviewCard> createState() => _DailyReviewCardState();
}

class _DailyReviewCardState extends ConsumerState<DailyReviewCard> {
  ReviewMode _mode = ReviewMode.gentle;
  bool _isCardFlipped = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    if (_isPlayingAudio) return;
    try {
      setState(() => _isPlayingAudio = true);
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      _audioPlayer.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
    } catch (_) {
      if (mounted) setState(() => _isPlayingAudio = false);
    }
  }

  void _nextWord() {
    setState(() {
      _isCardFlipped = false;
      _isPlayingAudio = false;
    });
    ref.read(dailyReviewWordProvider.notifier).nextWord();
  }

  @override
  Widget build(BuildContext context) {
    final wordAsync = ref.watch(dailyReviewWordProvider);

    return MewCard.elevated(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Mode Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: MewColors.warmTaupe,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: MewColors.emberOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ôn tập hàng ngày',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MewColors.ink,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: MewColors.warmTaupe,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: MewColors.stone),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        _mode = ReviewMode.gentle;
                        _isCardFlipped = false;
                      }),
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _mode == ReviewMode.gentle
                              ? MewColors.ink
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Nhẹ nhàng',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _mode == ReviewMode.gentle
                                ? MewColors.eggshell
                                : MewColors.smoke,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() {
                        _mode = ReviewMode.flashcard;
                        _isCardFlipped = false;
                      }),
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _mode == ReviewMode.flashcard
                              ? MewColors.ink
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Thẻ nhớ',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _mode == ReviewMode.flashcard
                                ? MewColors.eggshell
                                : MewColors.smoke,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content body
          wordAsync.when(
            loading: () => const SizedBox(
              height: 140,
              child: Center(child: LoadingIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'Không thể tải từ ôn tập: $err',
                  style: GoogleFonts.inter(color: MewColors.error),
                ),
              ),
            ),
            data: (item) {
              if (item == null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 40,
                          color: MewColors.ash,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chưa có từ vựng nào để ôn tập',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MewColors.graphite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thêm từ mới để bắt đầu ôn luyện nhé!',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: MewColors.smoke,
                          ),
                        ),
                        if (widget.onAddWord != null) ...[
                          const SizedBox(height: 12),
                          MewButton.filled(
                            label: 'Thêm từ mới',
                            isFullWidth: false,
                            height: 36,
                            onPressed: widget.onAddWord,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return _buildWordReview(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWordReview(VocabularyWithDefinitions item) {
    final vocab = item.vocabulary;
    final firstDef =
        item.definitions.isNotEmpty ? item.definitions.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word + Phonetic + Audio
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vocab.word,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: MewColors.ink,
                    ),
                  ),
                  if (vocab.phonetic != null && vocab.phonetic!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      vocab.phonetic!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: MewColors.ash,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (vocab.audioUrl != null && vocab.audioUrl!.isNotEmpty)
              IconButton(
                onPressed: _isPlayingAudio ? null : () => _playAudio(vocab.audioUrl!),
                icon: Icon(
                  _isPlayingAudio ? Icons.volume_up : Icons.volume_up_outlined,
                  color: MewColors.violetSpark,
                  size: 24,
                ),
                tooltip: 'Phát âm',
              ),
            if (vocab.cefrLevel != null && vocab.cefrLevel!.isNotEmpty)
              MewChip(
                label: vocab.cefrLevel!,
                customBgColor: MewColors.ink,
                customTextColor: MewColors.eggshell,
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Gentle mode or Flashcard mode view
        if (_mode == ReviewMode.gentle) ...[
          if (firstDef?.definitionVi != null &&
              firstDef!.definitionVi!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MewColors.warmTaupe,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstDef.definitionVi!,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: MewColors.graphite,
                      height: 1.4,
                    ),
                  ),
                  if (firstDef.example != null &&
                      firstDef.example!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '“${firstDef.example!}”',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: MewColors.smoke,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ] else ...[
          // Flashcard mode
          GestureDetector(
            onTap: () => setState(() => _isCardFlipped = !_isCardFlipped),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: MewColors.warmTaupe,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCardFlipped ? MewColors.violetSpark : MewColors.stone,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: _isCardFlipped
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            firstDef?.definitionVi ?? 'Không có định nghĩa',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: MewColors.ink,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (firstDef?.example != null &&
                              firstDef!.example!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '“${firstDef.example!}”',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: MewColors.smoke,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app_outlined,
                            size: 18,
                            color: MewColors.smoke,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Chạm để lật thẻ xem nghĩa',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: MewColors.smoke,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Action Buttons: Next Word
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_mode == ReviewMode.flashcard && !_isCardFlipped)
              TextButton.icon(
                onPressed: () => setState(() => _isCardFlipped = true),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Lật thẻ'),
                style: TextButton.styleFrom(
                  foregroundColor: MewColors.ink,
                ),
              ),
            const SizedBox(width: 8),
            MewButton.outlined(
              label: 'Từ khác',
              icon: const Icon(Icons.refresh_rounded, size: 16),
              isFullWidth: false,
              height: 38,
              onPressed: _nextWord,
            ),
          ],
        ),
      ],
    );
  }
}
