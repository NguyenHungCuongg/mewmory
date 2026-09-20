import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../common/mew_button.dart';
import '../common/mew_card.dart';
import '../common/mew_text_field.dart';

class AccountSection extends ConsumerStatefulWidget {
  const AccountSection({super.key});

  @override
  ConsumerState<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<AccountSection> {
  late final TextEditingController _nameController;
  bool _isUpdatingName = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    final initialName = (user?.userMetadata?['display_name'] ??
            user?.userMetadata?['full_name'] ??
            '') as String;
    _nameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isUpdatingName = true);
    try {
      await ref.read(authServiceProvider).updateDisplayName(newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật tên hiển thị'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật: $e'),
            backgroundColor: MewColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingName = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: MewColors.eggshell,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Đăng xuất',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi Mewmory? Dữ liệu ngoại tuyến trên thiết bị vẫn được bảo lưu an toàn.',
          style: GoogleFonts.inter(color: MewColors.smoke),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: MewColors.smoke)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Đăng xuất',
                style: TextStyle(color: MewColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authServiceProvider).signOut();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi đăng xuất: $e'),
              backgroundColor: MewColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? 'Chưa xác định';

    return MewCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MewColors.eggshell,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MewColors.stone),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: MewColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Tài khoản người dùng',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MewColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email Info Tile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: MewColors.eggshell,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MewColors.stone),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email đăng nhập',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: MewColors.ash,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MewColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Display Name Field + Update button
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: MewTextField(
                  controller: _nameController,
                  label: 'Tên hiển thị',
                  hintText: 'Nhập tên hiển thị...',
                ),
              ),
              const SizedBox(width: 8),
              MewButton.filled(
                label: 'Lưu',
                isFullWidth: false,
                height: 48,
                isLoading: _isUpdatingName,
                onPressed: _isUpdatingName ? null : _handleUpdateName,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sign Out Button
          MewButton.outlined(
            label: 'Đăng xuất',
            icon: const Icon(Icons.logout_rounded, size: 18, color: MewColors.error),
            onPressed: _handleSignOut,
          ),
        ],
      ),
    );
  }
}
