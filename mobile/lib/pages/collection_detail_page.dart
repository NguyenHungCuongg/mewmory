import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/collection.dart' as model;
import '../providers/auth_provider.dart';
import '../providers/collection_provider.dart';
import '../providers/services_provider.dart';
import '../utils/mew_toast.dart';
import '../widgets/collection/collection_form_sheet.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/vocabulary/word_card.dart';

class CollectionDetailPage extends ConsumerWidget {
  final String id;

  const CollectionDetailPage({
    super.key,
    required this.id,
  });

  Future<void> _handleDeleteCollection(
    BuildContext context,
    WidgetRef ref,
    model.Collection collection,
  ) async {
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.eggshell,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n?.deleteCollectionConfirm ?? 'Xóa bộ sưu tập',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colors.ink),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa bộ sưu tập "${collection.name}"? Các từ vựng bên trong sẽ không bị xóa.',
          style: GoogleFonts.inter(color: colors.smoke),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n?.cancel ?? 'Hủy', style: TextStyle(color: colors.smoke)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n?.delete ?? 'Xóa', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(collectionServiceProvider).delete(collection.id);
        if (context.mounted) {
          context.pop();
          MewToast.showSuccess(context, 'Đã xóa bộ sưu tập "${collection.name}"');
        }
      } catch (e) {
        if (context.mounted) {
          MewToast.showError(context, e, prefix: 'Không thể xóa');
        }
      }
    }
  }

  Future<void> _handleDeleteWord(
    BuildContext context,
    WidgetRef ref,
    String vocabId,
    String word,
  ) async {
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.eggshell,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Xóa từ "$word"?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colors.ink)),
        content: Text(
          'Từ vựng này sẽ bị xóa khỏi kho lưu trữ và đồng bộ lên đám mây.',
          style: GoogleFonts.inter(color: colors.smoke),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n?.cancel ?? 'Hủy', style: TextStyle(color: colors.smoke)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n?.delete ?? 'Xóa', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(vocabularyServiceProvider).delete(vocabId);
        if (context.mounted) {
          MewToast.showSuccess(context, 'Đã xóa từ "$word"');
        }
      } catch (e) {
        if (context.mounted) {
          MewToast.showError(context, e, prefix: 'Không thể xóa');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionDetailProvider(id));
    final wordsAsync = ref.watch(wordsInCollectionProvider(id));
    final user = ref.watch(currentUserProvider);
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    return collectionAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.eggshell,
        appBar: AppBar(backgroundColor: colors.eggshell),
        body: const WordListSkeleton(),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: colors.eggshell,
        appBar: AppBar(backgroundColor: colors.eggshell),
        body: ErrorState(
          title: l10n?.error ?? 'Lỗi khi tải bộ sưu tập',
          message: err.toString(),
          actionLabel: l10n?.retry ?? 'Thử lại',
          onRetry: () => ref.invalidate(collectionDetailProvider(id)),
        ),
      ),
      data: (col) {
        if (col == null) {
          return Scaffold(
            backgroundColor: colors.eggshell,
            appBar: AppBar(backgroundColor: colors.eggshell),
            body: EmptyState(
              icon: Icons.folder_off_outlined,
              title: 'Bộ sưu tập không tồn tại',
              message: 'Bộ sưu tập này có thể đã bị xóa hoặc không tìm thấy trong bộ nhớ.',
              actionLabel: 'Quay lại',
              onAction: () => context.pop(),
            ),
          );
        }

        final colModel = model.Collection.fromDrift(col);

        return Scaffold(
          backgroundColor: colors.eggshell,
          appBar: AppBar(
            backgroundColor: colors.eggshell,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.ink),
              onPressed: () => context.pop(),
            ),
            title: Text(
              col.name,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: colors.ink),
                tooltip: l10n?.edit ?? 'Chỉnh sửa',
                onPressed: () => CollectionFormSheet.show(
                  context,
                  collection: colModel,
                ),
              ),
              if (!col.isDefault)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: colors.error),
                  tooltip: l10n?.delete ?? 'Xóa bộ sưu tập',
                  onPressed: () =>
                      _handleDeleteCollection(context, ref, colModel),
                ),
            ],
          ),
          body: RefreshIndicator(
            color: colors.ink,
            backgroundColor: colors.eggshell,
            onRefresh: () async {
              if (user != null) {
                try {
                  final syncService = ref.read(syncServiceProvider);
                  final lastSync = await syncService.getLastSyncAt(user.id);
                  if (lastSync != null) {
                    await syncService.incrementalSync(user.id, lastSync);
                  } else {
                    await syncService.fullSync(user.id);
                  }
                } catch (_) {}
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (col.description != null &&
                            col.description!.trim().isNotEmpty) ...[
                          Text(
                            col.description!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colors.smoke,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        wordsAsync.when(
                          data: (words) => Text(
                            l10n != null
                                ? l10n.wordsCount(words.length)
                                : '${words.length} từ vựng',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colors.ash,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 12),
                        Divider(color: colors.stone, height: 1),
                      ],
                    ),
                  ),
                ),

                // Words list or empty state
                wordsAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: LoadingIndicator()),
                  ),
                  error: (err, _) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Lỗi khi tải từ vựng: $err',
                        style: GoogleFonts.inter(color: colors.error),
                      ),
                    ),
                  ),
                  data: (words) {
                    if (words.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: l10n?.emptyVocabulary ?? 'Chưa có từ vựng nào',
                          message:
                              'Bộ sưu tập này chưa chứa từ vựng nào. Hãy thêm từ vựng mới hoặc gán các từ có sẵn vào đây!',
                          actionLabel: l10n?.addWord ?? 'Thêm từ mới',
                          onAction: () => context.push('/vocabulary/add'),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 32,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = words[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: WordCard(
                                item: item,
                                onTap: () =>
                                    context.push('/vocabulary/${item.vocabulary.id}'),
                                onDelete: () => _handleDeleteWord(
                                  context,
                                  ref,
                                  item.vocabulary.id,
                                  item.vocabulary.word,
                                ),
                              ),
                            );
                          },
                          childCount: words.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
