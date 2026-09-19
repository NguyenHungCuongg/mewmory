import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';
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

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
        displayName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      );

      if (mounted) {
        if (response.session != null) {
          // Direct login after registration
          context.go('/dashboard');
        } else {
          // Confirmation email required
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.'),
              backgroundColor: MewColors.success,
              duration: Duration(seconds: 4),
            ),
          );
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: MewColors.error,
          ),
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
    return Scaffold(
      backgroundColor: MewColors.eggshell,
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
                    'Tạo tài khoản',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.64,
                      color: MewColors.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bắt đầu hành trình nâng cao vốn từ của bạn',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: MewColors.smoke,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Name Field (optional)
                  MewTextField(
                    controller: _nameController,
                    label: 'Họ và tên',
                    hintText: 'Nguyễn Văn A',
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outline, size: 20, color: MewColors.ash),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  MewTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.mail_outline, size: 20, color: MewColors.ash),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  MewTextField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    hintText: 'Tối thiểu 6 ký tự',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20, color: MewColors.ash),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: MewColors.ash,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải từ 6 ký tự trở lên';
                      }
                      return null;
                    },
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
                    prefixIcon: const Icon(Icons.lock_outline, size: 20, color: MewColors.ash),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: MewColors.ash,
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
                    label: 'Tạo tài khoản',
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
                          color: MewColors.smoke,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Đăng nhập',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MewColors.ink,
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
