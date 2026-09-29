import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../widgets/common/mew_button.dart';

class NotFoundPage extends StatelessWidget {
  final Exception? error;

  const NotFoundPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;

    return Scaffold(
      backgroundColor: colors.eggshell,
      appBar: AppBar(
        backgroundColor: colors.eggshell,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.warmTaupe,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.stone, width: 1),
                ),
                child: Icon(
                  Icons.explore_off_outlined,
                  size: 48,
                  color: colors.smoke,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.64,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Không tìm thấy trang',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Đường dẫn bạn yêu cầu không tồn tại hoặc đã bị di chuyển.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.smoke,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              MewButton.filled(
                label: 'Về trang chủ',
                icon: const Icon(Icons.home_outlined, size: 18),
                onPressed: () => context.go('/dashboard'),
                isFullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
