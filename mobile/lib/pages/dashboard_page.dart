import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/services_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/common/offline_banner.dart';
import '../widgets/dashboard/daily_review_card.dart';
import '../widgets/dashboard/stats_summary_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _handleRefresh(BuildContext context, WidgetRef ref, String userId) async {
    try {
      final syncService = ref.read(syncServiceProvider);
      final lastSync = await syncService.getLastSyncAt(userId);
      if (lastSync != null) {
        await syncService.incrementalSync(userId, lastSync);
      } else {
        await syncService.fullSync(userId);
      }

      // Invalidate stats providers to re-fetch freshly synced data
      ref.invalidate(totalWordCountProvider(userId));
      ref.invalidate(levelDistributionProvider(userId));
      ref.invalidate(wordsLearnedThisWeekProvider(userId));
      ref.invalidate(dailyReviewWordProvider);
    } catch (_) {}
  }

  String _getGreetingName(WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return 'bạn';

    final metaName = user.userMetadata?['display_name'] as String?;
    if (metaName != null && metaName.trim().isNotEmpty) {
      return metaName.trim();
    }

    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'bạn';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';
    final displayName = _getGreetingName(ref);

    final totalCountAsync = ref.watch(totalWordCountProvider(userId));
    final weekCountAsync = ref.watch(wordsLearnedThisWeekProvider(userId));
    final distributionAsync = ref.watch(levelDistributionProvider(userId));

    return Scaffold(
      backgroundColor: MewColors.eggshell,
      appBar: AppBar(
        backgroundColor: MewColors.eggshell,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Mewmory',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.48,
            color: MewColors.ink,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: MewColors.ink,
        backgroundColor: MewColors.eggshell,
        onRefresh: () => _handleRefresh(context, ref, userId),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Offline banner if needed
            const SliverToBoxAdapter(
              child: OfflineBanner(),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting
                  Text(
                    'Xin chào, $displayName! 👋',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: MewColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hãy duy trì thói quen học từ vựng mỗi ngày cùng Mewmory nhé.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: MewColors.smoke,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Daily Review Card
                  DailyReviewCard(
                    userId: userId,
                    onAddWord: () => context.push('/vocabulary/add'),
                  ),
                  const SizedBox(height: 16),

                  // Stats Summary Card
                  StatsSummaryCard(
                    totalCount: totalCountAsync.value ?? 0,
                    weekCount: weekCountAsync.value ?? 0,
                    levelDistribution: distributionAsync.value ?? const {},
                    onTap: () => context.go('/vocabulary'),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
