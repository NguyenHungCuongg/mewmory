import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../providers/lookup_provider.dart';

class DefinitionTile extends StatelessWidget {
  final EditableDefinition definition;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;

  const DefinitionTile({
    super.key,
    required this.definition,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: definition.isSelected
            ? MewColors.eggshell
            : MewColors.warmTaupe.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: definition.isSelected ? MewColors.stone : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: definition.isSelected,
              onChanged: onToggle,
              activeColor: MewColors.ink,
              checkColor: MewColors.eggshell,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Vietnamese definition
                  if (definition.definitionVi != null &&
                      definition.definitionVi!.isNotEmpty)
                    Text(
                      definition.definitionVi!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: MewColors.ink,
                        height: 1.3,
                      ),
                    ),
                  // English definition
                  if (definition.definitionEn != null &&
                      definition.definitionEn!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      definition.definitionEn!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: MewColors.graphite,
                        height: 1.3,
                      ),
                    ),
                  ],
                  // Example sentence
                  if (definition.example != null &&
                      definition.example!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '“${definition.example!}”',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: MewColors.smoke,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: MewColors.smoke,
              ),
              onPressed: onEdit,
              tooltip: 'Chỉnh sửa nghĩa',
            ),
          ],
        ),
      ),
    );
  }
}
