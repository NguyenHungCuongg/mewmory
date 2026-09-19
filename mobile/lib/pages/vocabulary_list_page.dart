import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/services_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/mew_chip.dart';
import '../widgets/common/offline_banner.dart';
import '../widgets/vocabulary/filter_sheet.dart';
import '../widgets/vocabulary/word_card.dart';

class VocabularyListPage extends ConsumerStatefulWidget {
  const VocabularyListPage({super.key});

  @override
  ConsumerState<VocabularyListPage> createState() => _VocabularyListPageState();
}

class _VocabularyListPageState extends ConsumerState<VocabularyListPage> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        ref.read(vocabularyFilterProvider.notifier).setSearchQuery(value);
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(vocabularyFilterProvider.notifier).setSearchQuery('');
  }

  Future<void> _handleRefresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final isOnline = ref.read(connectivityProvider).value ?? false;
    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có kết nối mạng để đồng bộ.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      final syncService = ref.read(syncServiceProvider);
      final lastSync = await syncService.getLastSyncAt(user.id);
      if (lastSync != null) {
        await syncService.incrementalSync(user.id, lastSync);
      } else {
        await syncService.fullSync(user.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đồng bộ: $e'),
            backgroundColor: MewColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteWord(String id, String word) async {
    try {
      await ref.read(vocabularyServiceProvider).delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa từ "$word"'),
            backgroundColor: MewColors.graphite,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xóa từ vựng: $e'),
            backgroundColor: MewColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabListAsync = ref.watch(vocabularyListProvider);
    final filters = ref.watch(vocabularyFilterProvider);
    final isOnline = ref.watch(connectivityProvider).value ?? true;

    return Scaffold(
      backgroundColor: MewColors.eggshell,
      appBar: AppBar(
        title: Text(
          'Từ vựng',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: MewColors.ink,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded, color: MewColors.ink),
                onPressed: () => FilterSheet.show(context),
              ),
              if (filters.hasActiveFilters)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: MewColors.emberOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Offline Banner
          if (!isOnline) const OfflineBanner(),

          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: MewColors.warmTaupe,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MewColors.stone, width: 1.0),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: MewColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm từ hoặc nghĩa tiếng Việt...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: MewColors.ash,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: MewColors.smoke,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: MewColors.smoke,
                            size: 18,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Active Filter Chips Bar (if active)
          if (filters.hasActiveFilters)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  if (filters.cefrLevel != null) ...[
                    MewChip(
                      label: 'Cấp độ: ${filters.cefrLevel}',
                      isSelected: true,
                      onSelected: (_) => ref
                          .read(vocabularyFilterProvider.notifier)
                          .setCefrLevel(null),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (filters.partOfSpeech != null) ...[
                    MewChip(
                      label: 'Loại từ: ${filters.partOfSpeech}',
                      isSelected: true,
                      onSelected: (_) => ref
                          .read(vocabularyFilterProvider.notifier)
                          .setPartOfSpeech(null),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (filters.usageRegister != null) ...[
                    MewChip(
                      label: 'Ngữ cảnh: ${filters.usageRegister}',
                      isSelected: true,
                      onSelected: (_) => ref
                          .read(vocabularyFilterProvider.notifier)
                          .setUsageRegister(null),
                    ),
                    const SizedBox(width: 6),
                  ],
                  ActionChip(
                    label: Text(
                      'Xóa tất cả',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: MewColors.smoke,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: MewColors.stone),
                    shape: const StadiumBorder(),
                    onPressed: () => ref
                        .read(vocabularyFilterProvider.notifier)
                        .resetFilters(),
                  ),
                ],
              ),
            ),

          // Vocabulary Items List
          Expanded(
            child: vocabListAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  final isFiltered = filters.hasActiveFilters ||
                      (filters.searchQuery != null &&
                          filters.searchQuery!.isNotEmpty);

                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: MewColors.ink,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: EmptyState(
                            icon: isFiltered
                                ? Icons.search_off_rounded
                                : Icons.menu_book_outlined,
                            title: isFiltered
                                ? 'Không tìm thấy từ vựng'
                                : 'Chưa có từ vựng nào',
                            message: isFiltered
                                ? 'Thử thay đổi từ khóa hoặc điều kiện bộ lọc.'
                                : 'Bắt đầu hành trình bằng cách thêm từ vựng mới với gợi ý thông minh từ AI.',
                            actionLabel: isFiltered ? null : 'Thêm từ đầu tiên',
                            onAction: isFiltered
                                ? null
                                : () => context.push('/vocabulary/add'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: MewColors.ink,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return WordCard(
                        item: item,
                        onTap: () => context.push('/vocabulary/${item.vocabulary.id}'),
                        onDelete: () => _handleDeleteWord(
                          item.vocabulary.id,
                          item.vocabulary.word,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Đã xảy ra lỗi khi tải từ vựng: $err',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: MewColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/vocabulary/add'),
        backgroundColor: MewColors.ink,
        foregroundColor: MewColors.eggshell,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
