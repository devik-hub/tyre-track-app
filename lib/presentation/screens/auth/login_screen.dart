import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_text_field.dart';
import '../../widgets/glass/customer_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showEmailForm = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  String? _validatePassword(String password) {
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'Add at least 1 uppercase letter';
    if (!password.contains(RegExp(r'[a-z]'))) return 'Add at least 1 lowercase letter';
    if (!password.contains(RegExp(r'[0-9]'))) return 'Add at least 1 number';
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) return 'Add at least 1 special character';
    return null;
  }

  void _showSnack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final digits = phone.replaceAll(RegExp(r'^\+91'), '').replaceAll(RegExp(r'\s'), '');
    if (digits.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(digits)) {
      _showSnack('Enter a valid 10-digit mobile number');
      return;
    }
    final formattedPhone = '+91$digits';
    await ref.read(authProvider.notifier).sendOtp(formattedPhone, (verificationId) {
      if (context.mounted) context.push(AppRoutes.otp, extra: verificationId);
    });
  }

  Future<void> _signInEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_isValidEmail(email)) {
      _showSnack('Enter a valid email address');
      return;
    }
    final pwError = _validatePassword(password);
    if (pwError != null) {
      _showSnack(pwError);
      return;
    }
    await ref.read(authProvider.notifier).signInWithEmail(email, password);
  }

  Future<void> _signInGoogle() async => await ref.read(authProvider.notifier).signInWithGoogle();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.userModel != null && !next.isLoading) {
        final user = next.userModel!;
        if (user.role == 'admin') {
          ref.read(authProvider.notifier).logout();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin accounts must use Admin Login.')));
        } else if (user.phone.isEmpty && user.email.isEmpty) {
          context.go(AppRoutes.register);
        } else {
          context.go(AppRoutes.home);
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.roleSelect);
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.92),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.chevronLeft, size: 20, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ),
                const Gap(20),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 72,
                    errorBuilder: (c, e, s) => const Icon(LucideIcons.disc, size: 72, color: AppColors.primary),
                  ),
                ),
                const Gap(12),
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display2.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
                const Gap(4),
                Text(
                  AppConstants.appTagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
                const Gap(32),

                if (authState.error != null)
                  LiquidGlassCard(
                    redAccent: true,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    borderRadius: 16,
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 20),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: AppTextStyles.body2.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Google button
                LiquidGlassButton(
                  label: 'Continue with Google',
                  icon: LucideIcons.globe,
                  variant: GlassButtonVariant.secondary,
                  onPressed: authState.isLoading ? null : _signInGoogle,
                ),
                const Gap(20),

                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE8DCDC))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR CONTINUE WITH', style: AppTextStyles.labelCaps.copyWith(color: AppColors.textSecondary)),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE8DCDC))),
                  ],
                ),
                const Gap(20),

                // Toggle Phone/Email in ClayCard
                LiquidGlassCard(
                  padding: const EdgeInsets.all(4),
                  borderRadius: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showEmailForm = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_showEmailForm ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.phone, size: 18, color: !_showEmailForm ? Colors.white : AppColors.textSecondary),
                                const Gap(8),
                                Text(
                                  'Phone OTP',
                                  style: AppTextStyles.label1.copyWith(
                                    color: !_showEmailForm ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showEmailForm = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _showEmailForm ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.mail, size: 18, color: _showEmailForm ? Colors.white : AppColors.textSecondary),
                                const Gap(8),
                                Text(
                                  'Email',
                                  style: AppTextStyles.label1.copyWith(
                                    color: _showEmailForm ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                if (!_showEmailForm) ...[
                  LiquidGlassTextField(
                    controller: _phoneController,
                    hintText: '10-digit mobile number',
                    prefixIcon: LucideIcons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const Gap(16),
                  LiquidGlassButton(
                    label: 'Send OTP',
                    isLoading: authState.isLoading,
                    onPressed: authState.isLoading ? null : _sendOtp,
                  ),
                ],
                if (_showEmailForm) ...[
                  LiquidGlassTextField(
                    controller: _emailController,
                    hintText: 'Email address',
                    prefixIcon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const Gap(14),
                  LiquidGlassTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: LucideIcons.lock,
                    obscureText: !_isPasswordVisible,
                    suffixWidget: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  const Gap(18),
                  LiquidGlassButton(
                    label: 'Sign In',
                    isLoading: authState.isLoading,
                    onPressed: authState.isLoading ? null : _signInEmail,
                  ),
                  const Gap(10),
                  LiquidGlassButton(
                    label: "Don't have an account? Register",
                    variant: GlassButtonVariant.ghost,
                    height: 44,
                    onPressed: () => context.push(AppRoutes.register),
                  ),
                ],
                const Gap(28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
