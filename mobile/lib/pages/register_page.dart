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
            setState(() => _syncMessage = 'Đang đồng bộ dữ liệu...');
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
            'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
            duration: const Duration(seconds: 4),
          );
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        MewToast.showError(context, e, prefix: 'Đăng ký thất bại');
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

    return Scaffold(
      backgroundColor: colors.eggshell,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n?.registerTitle ?? 'Tạo tài khoản',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.64,
                      color: colors.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.registerSubtitle ?? 'Bắt đầu hành trình nâng cao vốn từ của bạn',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.smoke,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Name Field (Required)
                  MewTextField(
                    controller: _nameController,
                    label: l10n?.displayName ?? 'Họ và tên',
                    hintText: 'Nguyễn Văn A',
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(Icons.person_outline, size: 20, color: colors.ash),
                    validator: (v) {
                      final req = Validators.required(v, 'Họ và tên');
                      if (req != null) return req;
                      return Validators.minLength(v, 2, 'Họ và tên');
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
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  MewTextField(
                    controller: _passwordController,
                    label: l10n?.password ?? 'Mật khẩu',
                    hintText: 'Tối thiểu 6 ký tự',
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
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  MewTextField(
                    controller: _confirmPasswordController,
                    label: 'Xác nhận mật khẩu',
                    hintText: 'Nhập lại mật khẩu',
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
                      if (value != _passwordController.text) {
                        return 'Mật khẩu xác nhận không khớp';
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
                        'Đã có tài khoản? ',
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
      ),
    );
  }
}
