import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import 'mew_button.dart';

class AppCrashView extends StatelessWidget {
  final FlutterErrorDetails? details;

  const AppCrashView({super.key, this.details});

  @override
  Widget build(BuildContext context) {
    // When called from ErrorWidget.builder, context might not have theme extension,
    // so provide graceful fallbacks.
    final mewColors = Theme.of(context).extension<MewThemeColors>();
    final eggshell = mewColors?.eggshell ?? const Color(0xFFFDFCFC);
    final ink = mewColors?.ink ?? const Color(0xFF000000);
    final smoke = mewColors?.smoke ?? const Color(0xFF777169);
    final errorColor = mewColors?.error ?? const Color(0xFFD32F2F);
    final warmTaupe = mewColors?.warmTaupe ?? const Color(0xFFF5F3F1);
    final stone = mewColors?.stone ?? const Color(0xFFEBE8E4);

    return Scaffold(
      backgroundColor: eggshell,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: errorColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: errorColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 44,
                    color: errorColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Đã có sự cố xảy ra',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ứng dụng gặp sự cố ngoài dự kiến. Dữ liệu của bạn vẫn an toàn.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: smoke,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode && details != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: warmTaupe,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: stone),
                    ),
                    child: Text(
                      details!.exceptionAsString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.redAccent,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                MewButton.filled(
                  label: 'Thử tải lại',
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  onPressed: () {
                    // Navigate back or reload the view
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  isFullWidth: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
