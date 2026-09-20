import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../models/collection.dart' as model;
import '../providers/auth_provider.dart';
import '../providers/collection_provider.dart';
import '../providers/services_provider.dart';
import '../widgets/collection/collection_card.dart';
import '../widgets/collection/collection_form_sheet.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_indicator.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

  Future<void> _handleDelete(
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(myCollectionsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: MewColors.eggshell,
      appBar: AppBar(
        backgroundColor: MewColors.eggshell,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Bộ sưu tập',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.48,
            color: MewColors.ink,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CollectionFormSheet.show(context),
        backgroundColor: MewColors.ink,
        foregroundColor: MewColors.eggshell,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
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
        child: collectionsAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Lỗi khi tải bộ sưu tập: $err',
                style: GoogleFonts.inter(color: MewColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: EmptyState(
                      icon: Icons.folder_outlined,
                      title: 'Chưa có bộ sưu tập nào',
                      message:
                          'Tạo bộ sưu tập đầu tiên để sắp xếp các từ vựng theo chủ đề!',
                      actionLabel: 'Tạo bộ sưu tập',
                      onAction: () => CollectionFormSheet.show(context),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 88,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final colModel = model.Collection.fromDrift(item.collection);

                return CollectionCard(
                  item: item,
                  onTap: () => context.push('/collections/${item.collection.id}'),
                  onEdit: () => CollectionFormSheet.show(
                    context,
                    collection: colModel,
                  ),
                  onDelete: item.collection.isDefault
                      ? null
                      : () => _handleDelete(context, ref, colModel),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
