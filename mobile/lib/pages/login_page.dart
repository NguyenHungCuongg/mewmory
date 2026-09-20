import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/services_provider.dart';
import '../widgets/common/mew_button.dart';
import '../widgets/common/mew_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _syncMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _syncMessage = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      final user = response.user;
      if (user != null && mounted) {
        setState(() => _syncMessage = 'Đang đồng bộ dữ liệu...');
        try {
          await ref.read(syncServiceProvider).fullSync(user.id);
        } catch (_) {}
      }

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: MewColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _syncMessage = null;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.signInWithGoogle();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở đăng nhập Google.'),
            backgroundColor: MewColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập Google thất bại: $e'),
            backgroundColor: MewColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
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
                  const SizedBox(height: 20),
                  // App Title & Tagline
                  Text(
                    'Mewmory',
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.72,
                      color: MewColors.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sổ tay từ vựng tiếng Anh thông minh',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: MewColors.smoke,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

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
                    hintText: '••••••••',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleEmailLogin(),
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
                  const SizedBox(height: 28),

                  // Sign In Button
                  MewButton.filled(
                    label: _syncMessage ?? 'Đăng nhập',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleEmailLogin,
                  ),
                  const SizedBox(height: 16),

                  // Divider with "hoặc"
                  Row(
                    children: [
                      const Expanded(child: Divider(color: MewColors.stone)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'hoặc',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: MewColors.ash,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: MewColors.stone)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign-In Button
                  MewButton.outlined(
                    label: 'Đăng nhập với Google',
                    isLoading: _isGoogleLoading,
                    icon: const Icon(Icons.g_mobiledata, size: 24, color: MewColors.ink),
                    onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                  ),
                  const SizedBox(height: 32),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: MewColors.smoke,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          'Đăng ký',
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
