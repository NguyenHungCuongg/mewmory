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
        MewToast.showError(context, e, prefix: 'Đăng nhập thất bại');
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
        MewToast.showError(context, 'Không thể mở đăng nhập Google.');
      }
    } catch (e) {
      if (mounted) {
        MewToast.showError(context, e, prefix: 'Đăng nhập Google thất bại');
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
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
                  const SizedBox(height: 20),
                  // App Title & Tagline
                  Text(
                    'Mewmory',
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.72,
                      color: colors.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.loginSubtitle ?? 'Sổ tay từ vựng tiếng Anh thông minh',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.smoke,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

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
                    hintText: '••••••••',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleEmailLogin(),
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
                  const SizedBox(height: 28),

                  // Sign In Button
                  MewButton.filled(
                    label: _syncMessage ?? (l10n?.signIn ?? 'Đăng nhập'),
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleEmailLogin,
                  ),
                  const SizedBox(height: 16),

                  // Divider with "hoặc"
                  Row(
                    children: [
                      Expanded(child: Divider(color: colors.stone)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'hoặc',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: colors.ash,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colors.stone)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign-In Button
                  MewButton.outlined(
                    label: 'Đăng nhập với Google',
                    isLoading: _isGoogleLoading,
                    icon: Icon(Icons.g_mobiledata, size: 24, color: colors.ink),
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
                          color: colors.smoke,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          l10n?.signUp ?? 'Đăng ký',
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
