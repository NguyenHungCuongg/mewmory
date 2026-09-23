import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import 'mew_button.dart';

class ErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const ErrorState({
    super.key,
    this.icon = Icons.error_outline_rounded,
    required this.title,
    required this.message,
    this.actionLabel = 'Thử lại',
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.error.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: colors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colors.smoke,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              MewButton.filled(
                label: actionLabel!,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: onRetry,
                isFullWidth: false,
              ),
            ],
            if (onSecondaryAction != null && secondaryActionLabel != null) ...[
              const SizedBox(height: 12),
              MewButton.outlined(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
