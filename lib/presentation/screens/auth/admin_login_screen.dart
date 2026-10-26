import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_text_field.dart';
import '../../widgets/glass/admin_background.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  String? _validatePassword(String pw) {
    if (pw.length < 8) return 'Password must be at least 8 characters';
    if (!pw.contains(RegExp(r'[A-Z]'))) return 'Add at least 1 uppercase letter';
    if (!pw.contains(RegExp(r'[a-z]'))) return 'Add at least 1 lowercase letter';
    if (!pw.contains(RegExp(r'[0-9]'))) return 'Add at least 1 number';
    if (!pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) return 'Add at least 1 special character';
    return null;
  }

  Future<void> _signIn() async {
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
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.error != null) return;
    final role = authState.userModel?.role ?? '';
    if (role != 'admin') {
      await ref.read(authProvider.notifier).logout();
      _showSnack('Access denied. Admins only.');
      return;
    }
    if (mounted) context.go(AppRoutes.admin);
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.isLoading || next.error != null) return;
      if (next.userModel != null && next.userModel!.role == 'admin') context.go(AppRoutes.admin);
    });

    return Scaffold(
      backgroundColor: AppColors.adminBg1,
      body: AdminBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.chevronLeft, size: 20, color: AppColors.adminTextPrimary),
                      ),
                    ),
                  ),
                ),
                const Gap(24),
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.shieldAlert, size: 42, color: Colors.white),
                  ),
                ).animate().scale(duration: 350.ms),
                const Gap(20),
                Text(
                  'Operations Console',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(color: AppColors.adminTextPrimary),
                ),
                const Gap(4),
                Text(
                  'Restricted to authorised Jagadale Retreads administrators',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2.copyWith(color: AppColors.adminTextSec),
                ),
                const Gap(36),
                if (authState.error != null)
                  LiquidGlassCard(
                    isDark: true,
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
                LiquidGlassTextField(
                  controller: _emailController,
                  hintText: 'Admin Email',
                  prefixIcon: LucideIcons.mail,
                  isDark: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                const Gap(16),
                LiquidGlassTextField(
                  controller: _passwordController,
                  hintText: 'Admin Password',
                  prefixIcon: LucideIcons.lock,
                  isDark: true,
                  obscureText: !_isPasswordVisible,
                  suffixWidget: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: AppColors.adminTextTert,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                const Gap(28),
                LiquidGlassButton(
                  label: 'Access Admin Console',
                  isLoading: authState.isLoading,
                  isDark: true,
                  onPressed: authState.isLoading ? null : _signIn,
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
