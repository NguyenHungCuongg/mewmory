import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../db/daos/collection_dao.dart';
import '../common/mew_card.dart';
import '../common/mew_chip.dart';

class CollectionCard extends StatelessWidget {
  final CollectionWithCount item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CollectionCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final col = item.collection;

    final cardContent = MewCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: MewColors.warmTaupe == MewTheme.light.cardColor
                      ? MewColors.stone
                      : MewColors.warmTaupe,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MewColors.stone),
                ),
                child: const Icon(
                  Icons.folder_outlined,
                  size: 22,
                  color: MewColors.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            col.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: MewColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (col.isDefault) ...[
                          const SizedBox(width: 6),
                          const MewChip(
                            label: 'Mặc định',
                            customBgColor: MewColors.stone,
                            customTextColor: MewColors.graphite,
                          ),
                        ],
                      ],
                    ),
                    if (col.description != null &&
                        col.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        col.description!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: MewColors.smoke,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MewColors.eggshell,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: MewColors.stone),
                ),
                child: Text(
                  '${item.wordCount} từ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: MewColors.graphite,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onDelete != null || onEdit != null) {
      return Slidable(
        key: ValueKey(col.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: (onEdit != null && onDelete != null && !col.isDefault)
              ? 0.5
              : 0.25,
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit!(),
                backgroundColor: MewColors.warmTaupe,
                foregroundColor: MewColors.ink,
                icon: Icons.edit_outlined,
                label: 'Sửa',
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
            if (onDelete != null && !col.isDefault)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: MewColors.error,
                foregroundColor: MewColors.eggshell,
                icon: Icons.delete_outline_rounded,
                label: 'Xóa',
                borderRadius: BorderRadius.horizontal(
                  right: const Radius.circular(20),
                  left: onEdit == null ? const Radius.circular(20) : Radius.zero,
                ),
              ),
          ],
        ),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
