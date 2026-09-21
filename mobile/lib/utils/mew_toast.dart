import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'error_translator.dart';

enum MewToastType { success, error, info }

/// Centralized Toast system for Mewmory Mobile.
/// Guarantees high-contrast readable typography across both Light and Dark themes,
/// friendly error translation, and consistent editorial aesthetics.
class MewToast {
  MewToast._();

  /// Displays a success toast with a checkmark icon.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      type: MewToastType.success,
      duration: duration,
    );
  }

  /// Displays a user-friendly error toast. Translates Supabase/JSON/network errors automatically.
  static void showError(
    BuildContext context,
    dynamic error, {
    String? prefix,
    Duration duration = const Duration(seconds: 4),
    String? locale,
  }) {
    final friendlyMessage = ErrorTranslator.translate(
      error,
      prefix: prefix,
      locale: locale ?? 'vi',
    );
    _show(
      context: context,
      message: friendlyMessage,
      type: MewToastType.error,
      duration: duration,
    );
  }

  /// Displays an informational / neutral notification toast.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      type: MewToastType.info,
      duration: duration,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required MewToastType type,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor;
    final Color textColor;
    final Color iconColor;
    final IconData iconData;
    final BorderSide? border;

    switch (type) {
      case MewToastType.success:
        if (isDark) {
          bgColor = const Color(0xFF1E3A27);
          textColor = const Color(0xFFE8F5E9);
          iconColor = const Color(0xFF81C784);
          border = const BorderSide(color: Color(0xFF2E5939), width: 1);
        } else {
          bgColor = const Color(0xFF2D7D46);
          textColor = Colors.white;
          iconColor = Colors.white;
          border = null;
        }
        iconData = Icons.check_circle_rounded;
        break;

      case MewToastType.error:
        if (isDark) {
          bgColor = const Color(0xFF4A1818);
          textColor = const Color(0xFFFFEBEE);
          iconColor = const Color(0xFFE57373);
          border = const BorderSide(color: Color(0xFF702525), width: 1);
        } else {
          bgColor = const Color(0xFFD32F2F);
          textColor = Colors.white;
          iconColor = Colors.white;
          border = null;
        }
        iconData = Icons.error_outline_rounded;
        break;

      case MewToastType.info:
        if (isDark) {
          bgColor = const Color(0xFF242422);
          textColor = const Color(0xFFF0F0EE);
          iconColor = const Color(0xFFC8C8C4);
          border = const BorderSide(color: Color(0xFF383834), width: 1);
        } else {
          bgColor = const Color(0xFF2A2825);
          textColor = const Color(0xFFFDFCFC);
          iconColor = const Color(0xFFFDFCFC);
          border = null;
        }
        iconData = Icons.info_outline_rounded;
        break;
    }

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: isDark ? 0 : 3,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: border ?? BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Icon(iconData, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
