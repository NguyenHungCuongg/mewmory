import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../models/collection.dart' as model;
import '../providers/auth_provider.dart';
import '../providers/collection_provider.dart';
import '../providers/services_provider.dart';
import '../widgets/collection/collection_form_sheet.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_indicator.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: MewColors.eggshell,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xóa bộ sưu tập',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa bộ sưu tập "${collection.name}"? Các từ vựng bên trong sẽ không bị xóa.',
          style: GoogleFonts.inter(color: MewColors.smoke),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: MewColors.smoke)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: MewColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(collectionServiceProvider).delete(collection.id);
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa bộ sưu tập "${collection.name}"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể xóa: $e'),
              backgroundColor: MewColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: MewColors.eggshell,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Xóa từ "$word"?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(
          'Từ vựng này sẽ bị xóa khỏi kho lưu trữ và đồng bộ lên đám mây.',
          style: GoogleFonts.inter(color: MewColors.smoke),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: MewColors.smoke)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: MewColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(vocabularyServiceProvider).delete(vocabId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa từ "$word"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể xóa: $e'),
              backgroundColor: MewColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionDetailProvider(id));
    final wordsAsync = ref.watch(wordsInCollectionProvider(id));
    final user = ref.watch(currentUserProvider);

    return collectionAsync.when(
      loading: () => const Scaffold(
        backgroundColor: MewColors.eggshell,
        body: Center(child: LoadingIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: MewColors.eggshell,
        appBar: AppBar(backgroundColor: MewColors.eggshell),
        body: Center(child: Text('Lỗi: $err')),
      ),
      data: (col) {
        if (col == null) {
          return Scaffold(
            backgroundColor: MewColors.eggshell,
            appBar: AppBar(backgroundColor: MewColors.eggshell),
            body: const Center(child: Text('Bộ sưu tập không tồn tại hoặc đã bị xóa')),
          );
        }

        final colModel = model.Collection.fromDrift(col);

        return Scaffold(
          backgroundColor: MewColors.eggshell,
          appBar: AppBar(
            backgroundColor: MewColors.eggshell,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: MewColors.ink),
              onPressed: () => context.pop(),
            ),
            title: Text(
              col.name,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: MewColors.ink,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: MewColors.ink),
                tooltip: 'Chỉnh sửa',
                onPressed: () => CollectionFormSheet.show(
                  context,
                  collection: colModel,
                ),
              ),
              if (!col.isDefault)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: MewColors.error),
                  tooltip: 'Xóa bộ sưu tập',
                  onPressed: () =>
                      _handleDeleteCollection(context, ref, colModel),
                ),
            ],
          ),
          body: RefreshIndicator(
            color: MewColors.ink,
            backgroundColor: MewColors.eggshell,
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
                              color: MewColors.smoke,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        wordsAsync.when(
                          data: (words) => Text(
                            '${words.length} từ vựng',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: MewColors.graphite,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: MewColors.stone, height: 1),
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
                        style: GoogleFonts.inter(color: MewColors.error),
                      ),
                    ),
                  ),
                  data: (words) {
                    if (words.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: 'Chưa có từ vựng nào',
                          message:
                              'Bộ sưu tập này chưa chứa từ vựng nào. Hãy thêm từ vựng mới hoặc gán các từ có sẵn vào đây!',
                          actionLabel: 'Thêm từ mới',
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
