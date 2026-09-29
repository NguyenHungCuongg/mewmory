import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/services_provider.dart';
import '../utils/mew_toast.dart';
import '../utils/validators.dart';
import '../widgets/common/app_logo.dart';
import '../widgets/common/language_switcher.dart';
import '../widgets/common/mew_button.dart';
import '../widgets/common/mew_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _syncMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _syncMessage = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
        displayName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      );

      if (mounted) {
        if (response.session != null) {
          final user = response.user;
          if (user != null) {
            setState(() => _syncMessage = l10n?.syncingData ?? 'Đang đồng bộ dữ liệu...');
            try {
              await ref.read(syncServiceProvider).fullSync(user.id);
            } catch (_) {}
          }
          if (mounted) {
            context.go('/dashboard');
          }
        } else {
          // Confirmation email required
          MewToast.showSuccess(
            context,
            l10n?.signUpSuccessNotice ??
                'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
            duration: const Duration(seconds: 4),
          );
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        final isVi = (l10n?.localeName ?? 'vi') == 'vi';
        MewToast.showError(
          context,
          e,
          prefix: l10n?.signUpFailed ?? 'Đăng ký thất bại',
          locale: isVi ? 'vi' : 'en',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);
    final isVi = (l10n?.localeName ?? 'vi') == 'vi';

    return Scaffold(
      backgroundColor: colors.eggshell,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 16,
              child: const LanguageSwitcher(),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Center(child: AppLogo(size: 44, borderRadius: 11)),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.registerTitle ?? 'Tạo tài khoản',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -0.52,
                          color: colors.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  const SizedBox(height: 4),
                  Text(
                    l10n?.registerSubtitle ?? 'Bắt đầu hành trình nâng cao vốn từ của bạn',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colors.smoke,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Name Field (Required)
                  MewTextField(
                    controller: _nameController,
                    label: l10n?.fullName ?? 'Họ và tên',
                    hintText: l10n?.fullNameHint ?? 'Nguyễn Văn A',
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(Icons.person_outline, size: 20, color: colors.ash),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n?.fullNameRequired ?? 'Vui lòng nhập họ và tên';
                      }
                      if (v.trim().length < 2) {
                        return l10n?.fullNameMinLength ?? 'Họ và tên phải có ít nhất 2 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  MewTextField(
                    controller: _emailController,
                    label: l10n?.email ?? 'Email',
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(Icons.mail_outline, size: 20, color: colors.ash),
                    validator: (v) => Validators.email(
                      v,
                      emptyMessage: l10n?.requiredField,
                      invalidMessage: l10n?.invalidEmail,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  MewTextField(
                    controller: _passwordController,
                    label: l10n?.password ?? 'Mật khẩu',
                    hintText: l10n?.passwordHint ?? 'Tối thiểu 6 ký tự',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(Icons.lock_outline, size: 20, color: colors.ash),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: colors.ash,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (v) => Validators.password(
                      v,
                      emptyMessage: l10n?.requiredField,
                      minLengthMessage: l10n?.passwordMinLength,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  MewTextField(
                    controller: _confirmPasswordController,
                    label: l10n?.confirmPassword ?? 'Xác nhận mật khẩu',
                    hintText: l10n?.confirmPasswordHint ?? 'Nhập lại mật khẩu',
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleRegister(),
                    prefixIcon: Icon(Icons.lock_outline, size: 20, color: colors.ash),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: colors.ash,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n?.confirmPasswordRequired ?? 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != _passwordController.text) {
                        return l10n?.passwordMismatch ?? 'Mật khẩu xác nhận không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Register Button
                  MewButton.filled(
                    label: _syncMessage ?? (l10n?.signUp ?? 'Tạo tài khoản'),
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleRegister,
                  ),
                  const SizedBox(height: 28),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isVi ? 'Đã có tài khoản? ' : 'Already have an account? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: colors.smoke,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          l10n?.signIn ?? 'Đăng nhập',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }
}
