import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'mew_card.dart';

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.stone.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class WordCardSkeleton extends StatelessWidget {
  const WordCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return MewCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(width: 120, height: 20, borderRadius: 6),
              const SizedBox(width: 8),
              const SkeletonBox(width: 70, height: 16, borderRadius: 6),
              const Spacer(),
              const SkeletonBox(width: 38, height: 22, borderRadius: 999),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonBox(width: double.infinity, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          const SkeletonBox(width: 200, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

class WordListSkeleton extends StatelessWidget {
  final int itemCount;

  const WordListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const WordCardSkeleton(),
    );
  }
}

class CollectionCardSkeleton extends StatelessWidget {
  const CollectionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return MewCard(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const SkeletonBox(width: 44, height: 44, borderRadius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 140, height: 18, borderRadius: 6),
                SizedBox(height: 6),
                SkeletonBox(width: 80, height: 14, borderRadius: 4),
              ],
            ),
          ),
          const SkeletonBox(width: 40, height: 24, borderRadius: 999),
        ],
      ),
    );
  }
}

class CollectionListSkeleton extends StatelessWidget {
  final int itemCount;

  const CollectionListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 88),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const CollectionCardSkeleton(),
    );
  }
}
