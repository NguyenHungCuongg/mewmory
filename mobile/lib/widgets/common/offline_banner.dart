import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MewColors.warning.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(
            color: MewColors.warning.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 16,
            color: MewColors.warning,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Chế độ ngoại tuyến — Chỉ đọc dữ liệu từ bộ nhớ cache',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MewColors.graphite,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
