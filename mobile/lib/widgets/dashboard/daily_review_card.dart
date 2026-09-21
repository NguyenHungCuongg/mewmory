import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../db/daos/vocabulary_dao.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/stats_provider.dart';
import '../common/loading_indicator.dart';
import '../common/mew_button.dart';
import '../common/mew_card.dart';
import '../common/mew_chip.dart';

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
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    final title = l10n?.dailyReviewTitle ?? 'Ôn tập hàng ngày';
    final gentleLabel = l10n?.gentleMode ?? 'Nhẹ nhàng';
    final flashcardLabel = l10n?.flashcardMode ?? 'Thẻ nhớ';

    return MewCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title + Mode Switch (Responsive for narrow screens)
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 275;

              final titleRow = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: colors.violetSpark.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 15,
                      color: colors.violetSpark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: colors.ink,
                      ),
                    ),
                  ),
                ],
              );

              final toggle = _buildModeToggle(colors, gentleLabel, flashcardLabel);

              if (isVeryNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: toggle,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleRow),
                  const SizedBox(width: 8),
                  toggle,
                ],
              );
            },
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
                  style: GoogleFonts.inter(color: colors.error),
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
                        Icon(
                          Icons.menu_book_outlined,
                          size: 40,
                          color: colors.ash,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.noWordsToReview ?? 'Chưa có từ vựng nào để ôn tập',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.graphite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thêm từ mới để bắt đầu ôn luyện nhé!',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: colors.smoke,
                          ),
                        ),
                        if (widget.onAddWord != null) ...[
                          const SizedBox(height: 12),
                          MewButton.filled(
                            label: l10n?.addWordNow ?? 'Thêm từ mới ngay',
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

              return _buildWordReview(item, colors, l10n);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWordReview(
    VocabularyWithDefinitions item,
    MewThemeColors colors,
    AppLocalizations? l10n,
  ) {
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
                      color: colors.ink,
                    ),
                  ),
                  if (vocab.phonetic != null && vocab.phonetic!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      vocab.phonetic!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colors.ash,
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
                  color: colors.violetSpark,
                  size: 24,
                ),
                tooltip: 'Phát âm',
              ),
            if (vocab.cefrLevel != null && vocab.cefrLevel!.isNotEmpty)
              MewChip(
                label: vocab.cefrLevel!,
                customBgColor: colors.ink,
                customTextColor: colors.eggshell,
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
                color: colors.warmTaupe,
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
                      color: colors.graphite,
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
                        color: colors.smoke,
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
                color: colors.warmTaupe,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCardFlipped ? colors.violetSpark : colors.stone,
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
                              color: colors.ink,
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
                                color: colors.smoke,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 18,
                            color: colors.smoke,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n?.flipCard ?? 'Chạm để lật thẻ xem nghĩa',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colors.smoke,
                              ),
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
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_mode == ReviewMode.flashcard && !_isCardFlipped)
              TextButton.icon(
                onPressed: () => setState(() => _isCardFlipped = true),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: Text(l10n?.flipCardAction ?? 'Lật thẻ'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.ink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            MewButton.outlined(
              label: l10n?.nextWord ?? 'Từ khác',
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

  Widget _buildModeToggle(
    MewThemeColors colors,
    String gentleLabel,
    String flashcardLabel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.warmTaupe,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: colors.stone),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(
            mode: ReviewMode.gentle,
            label: gentleLabel,
            colors: colors,
          ),
          _buildToggleItem(
            mode: ReviewMode.flashcard,
            label: flashcardLabel,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required ReviewMode mode,
    required String label,
    required MewThemeColors colors,
  }) {
    final isSelected = _mode == mode;
    return InkWell(
      onTap: () => setState(() {
        _mode = mode;
        _isCardFlipped = false;
      }),
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
            color: isSelected ? colors.eggshell : colors.smoke,
          ),
        ),
      ),
    );
  }
}
