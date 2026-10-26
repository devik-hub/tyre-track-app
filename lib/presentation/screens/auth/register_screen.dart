import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_text_field.dart';
import '../../widgets/glass/customer_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      if (firebaseUser.displayName != null && firebaseUser.displayName!.isNotEmpty) {
        _nameController.text = firebaseUser.displayName!;
      }
      if (firebaseUser.email != null && firebaseUser.email!.isNotEmpty) {
        _emailController.text = firebaseUser.email!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String pw) {
    if (pw.length < 8) return 'Use at least 8 characters';
    if (!pw.contains(RegExp(r'[A-Z]'))) return 'Add at least 1 uppercase letter';
    if (!pw.contains(RegExp(r'[a-z]'))) return 'Add at least 1 lowercase letter';
    if (!pw.contains(RegExp(r'[0-9]'))) return 'Add at least 1 number';
    if (!pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/]'))) return 'Add at least 1 special character';
    return null;
  }

  Map<String, bool> _getPasswordRequirements(String pw) => {
        '8+ characters': pw.length >= 8,
        'Uppercase letter': pw.contains(RegExp(r'[A-Z]')),
        'Lowercase letter': pw.contains(RegExp(r'[a-z]')),
        'Number': pw.contains(RegExp(r'[0-9]')),
        'Special character': pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/]')),
      };

  Future<void> _completeProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your full name')));
      return;
    }
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(authProvider.notifier).registerUser(name, user.phoneNumber ?? '', email);
      if (mounted) {
        final u = ref.read(authProvider).userModel;
        if (u != null && u.role == 'admin') {
          context.go(AppRoutes.admin);
        } else {
          context.go(AppRoutes.home);
        }
      }
    }
  }

  Future<void> _registerWithEmail() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your full name')));
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
      return;
    }
    final pwError = _validatePassword(password);
    if (pwError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pwError)));
      return;
    }
    await ref.read(authProvider.notifier).registerWithEmail(email, password);
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(authProvider.notifier).registerUser(name, '', email);
      if (mounted) {
        final u = ref.read(authProvider).userModel;
        if (u != null && u.role == 'admin') {
          context.go(AppRoutes.admin);
        } else {
          context.go(AppRoutes.home);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAlreadyAuthed = ref.read(authRepositoryProvider).currentUser != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40,
                      height: 40,
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
                const Gap(16),
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.92),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                    ),
                    child: const Icon(LucideIcons.userPlus, size: 36, color: AppColors.primary),
                  ),
                ).animate().scale(duration: 350.ms),
                const Gap(16),
                Text(
                  isAlreadyAuthed ? 'Complete Your Profile' : 'Sign Up with Email',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
                ),
                const Gap(4),
                Text(
                  isAlreadyAuthed ? 'Just a few details to get started' : 'Create your Jagadale Retreads customer account',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
                const Gap(28),
                LiquidGlassTextField(
                  controller: _nameController,
                  labelText: 'Full Name *',
                  prefixIcon: LucideIcons.user,
                ),
                const Gap(16),
                LiquidGlassTextField(
                  controller: _emailController,
                  labelText: isAlreadyAuthed ? 'Email (Optional)' : 'Email Address *',
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                ),
                if (!isAlreadyAuthed) ...[
                  const Gap(16),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _passwordController,
                    builder: (context, value, _) {
                      final reqs = _getPasswordRequirements(value.text);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LiquidGlassTextField(
                            controller: _passwordController,
                            labelText: 'Password *',
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
                          if (value.text.isNotEmpty) ...[
                            const Gap(10),
                            ...reqs.entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      e.value ? LucideIcons.checkCircle2 : LucideIcons.circle,
                                      size: 14,
                                      color: e.value ? AppColors.success : AppColors.textTertiary,
                                    ),
                                    const Gap(8),
                                    Text(
                                      e.key,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: e.value ? AppColors.success : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
                const Gap(24),
                if (authState.error != null)
                  LiquidGlassCard(
                    redAccent: true,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    borderRadius: 14,
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 18),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: AppTextStyles.body2.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                LiquidGlassButton(
                  label: isAlreadyAuthed ? 'Complete Profile' : 'Create Account',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading ? null : (isAlreadyAuthed ? _completeProfile : _registerWithEmail),
                ),
                const Gap(12),
                LiquidGlassButton(
                  label: 'Already have an account? Login',
                  variant: GlassButtonVariant.ghost,
                  height: 42,
                  onPressed: () => context.go(AppRoutes.login),
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
