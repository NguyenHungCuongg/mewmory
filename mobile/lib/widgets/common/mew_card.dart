import 'package:flutter/material.dart';
import '../../config/theme.dart';

class MewCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool isElevated;

  const MewCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.onTap,
  }) : isElevated = false;

  const MewCard.elevated({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.onTap,
  }) : isElevated = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;
    final decoration = BoxDecoration(
      color: isElevated ? colors.eggshell : colors.warmTaupe,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.stone, width: 1.0),
      boxShadow: isElevated
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    Widget content = Container(
      margin: margin,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
