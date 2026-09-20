import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

enum MewButtonVariant { filled, outlined }

class MewButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final MewButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  const MewButton.filled({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 48.0,
  }) : variant = MewButtonVariant.filled;

  const MewButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 48.0,
  }) : variant = MewButtonVariant.outlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;
    final isFilled = variant == MewButtonVariant.filled;
    final isEnabled = onPressed != null && !isLoading;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFilled ? colors.eggshell : colors.ink,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isFilled ? colors.eggshell : colors.ink,
                  letterSpacing: 0.14,
                ),
              ),
            ],
          );

    final buttonStyle = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return isFilled ? colors.ash.withValues(alpha: 0.4) : Colors.transparent;
        }
        return isFilled ? colors.ink : colors.eggshell;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.smoke;
        }
        return isFilled ? colors.eggshell : colors.ink;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (isFilled) return BorderSide.none;
        return BorderSide(color: colors.stone, width: 1);
      }),
    );

    final button = isFilled
        ? ElevatedButton(
            style: buttonStyle,
            onPressed: isEnabled ? onPressed : null,
            child: child,
          )
        : OutlinedButton(
            style: buttonStyle,
            onPressed: isEnabled ? onPressed : null,
            child: child,
          );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return SizedBox(
      height: height,
      child: button,
    );
  }
}
