import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/mew_toast.dart';
import '../common/mew_button.dart';
import '../common/mew_card.dart';
import '../common/mew_text_field.dart';
import '../common/user_avatar.dart';

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
            user?.userMetadata?['name'] ??
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
    if (newName.isEmpty) {
      MewToast.showError(context, 'Tên không được để trống');
      return;
    }

    setState(() => _isUpdatingName = true);
    try {
      await ref.read(authServiceProvider).updateDisplayName(newName);
      ref.invalidate(currentUserProvider);
      if (mounted) {
        MewToast.showSuccess(context, 'Đã cập nhật tên hiển thị');
      }
    } catch (e) {
      if (mounted) {
        MewToast.showError(context, e, prefix: 'Lỗi khi cập nhật');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingName = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);
    final isVi = (l10n?.localeName ?? 'vi') == 'vi';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.warmTaupe,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isVi ? 'Đăng xuất' : 'Sign Out',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colors.ink),
        ),
        content: Text(
          l10n?.signOutConfirm ??
              'Bạn có chắc chắn muốn đăng xuất khỏi Mewmory? Dữ liệu ngoại tuyến trên thiết bị vẫn được bảo lưu an toàn.',
          style: GoogleFonts.inter(color: colors.smoke),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              isVi ? 'Hủy' : 'Cancel',
              style: TextStyle(color: colors.smoke),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              isVi ? 'Đăng xuất' : 'Sign Out',
              style: TextStyle(color: colors.error),
            ),
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
          MewToast.showError(context, e, prefix: 'Lỗi khi đăng xuất');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? 'Chưa xác định';
    final displayName = (user?.userMetadata?['display_name'] ??
            user?.userMetadata?['full_name'] ??
            user?.userMetadata?['name'] ??
            '') as String;
    final photoUrl = user?.userMetadata?['avatar_url'] as String?;
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    return MewCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.eggshell,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.stone),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: colors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n?.accountTitle ?? 'Tài khoản người dùng',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Profile Info with UserAvatar
          Row(
            children: [
              UserAvatar(
                name: displayName,
                email: email,
                photoUrl: photoUrl,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.trim().isNotEmpty
                          ? displayName.trim()
                          : (user?.email?.split('@').first ?? 'Người dùng'),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.smoke,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
              color: colors.eggshell,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.stone),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email đăng nhập',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: colors.ash,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.ink,
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
                  label: l10n?.displayName ?? 'Tên hiển thị',
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
            icon: Icon(Icons.logout_rounded, size: 18, color: colors.error),
            onPressed: _handleSignOut,
          ),
        ],
      ),
    );
  }
}
