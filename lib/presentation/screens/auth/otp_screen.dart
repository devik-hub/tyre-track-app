import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/customer_background.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _verifyPressed = false;
  int _resendCountdown = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _focusNode.addListener(() => setState(() {}));
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _focusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the 6-digit OTP')));
      return;
    }
    setState(() => _verifyPressed = true);
    await ref.read(authProvider.notifier).verifyOtp(widget.verificationId, code);
  }

  void _resendCode() {
    if (_resendCountdown > 0) return;
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Requesting a new verification code...')),
    );
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (!_verifyPressed) return;
      if (next.isLoading) return;
      if (next.userModel != null) {
        final user = next.userModel!;
        if (user.phone.isEmpty) {
          context.go(AppRoutes.register);
        } else if (user.role == 'admin') {
          context.go(AppRoutes.admin);
        } else {
          context.go(AppRoutes.home);
        }
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
        setState(() => _verifyPressed = false);
      } else if (!next.isLoading) {
        final firebaseUser = ref.read(authRepositoryProvider).currentUser;
        if (firebaseUser != null) context.go(AppRoutes.register);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar with Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _navigateBack,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.92),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 12,
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
                const Gap(32),
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.92),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                    ),
                    child: const Icon(LucideIcons.messageSquare, size: 40, color: AppColors.primary),
                  ),
                ).animate().scale(duration: 350.ms),
                const Gap(24),
                Text(
                  'Verification Code',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
                ),
                const Gap(8),
                Text(
                  'Enter the 6-digit SMS code sent to your mobile',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
                const Gap(28),
                _buildSegmentedPinInput(authState).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                const Gap(24),
                if (authState.error != null && _verifyPressed)
                  LiquidGlassCard(
                    redAccent: true,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    borderRadius: 14,
                    child: Text(
                      authState.error!,
                      style: AppTextStyles.body2.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                LiquidGlassButton(
                  label: 'Verify OTP',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading ? null : _verify,
                ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                const Gap(24),
                // Resend OTP & Edit Number options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _resendCountdown > 0
                          ? 'Resend code in ${_resendCountdown}s'
                          : "Didn't receive the code?",
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                    ),
                    if (_resendCountdown == 0) ...[
                      const Gap(6),
                      GestureDetector(
                        onTap: _resendCode,
                        child: Text(
                          'Resend OTP',
                          style: AppTextStyles.label1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(16),
                Center(
                  child: TextButton.icon(
                    onPressed: _navigateBack,
                    icon: const Icon(LucideIcons.edit2, size: 14, color: AppColors.textSecondary),
                    label: Text(
                      'Change mobile number',
                      style: AppTextStyles.label2.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedPinInput(AuthState authState) {
    final text = _otpController.text;
    final isFocused = _focusNode.hasFocus;

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            final isCurrent = isFocused && (index == text.length || (index == 5 && text.length == 6));
            final hasValue = index < text.length;
            final digit = hasValue ? text[index] : '';

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary
                      : (hasValue ? AppColors.primary.withValues(alpha: 0.4) : const Color(0xFFE8DCDC)),
                  width: isCurrent ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCurrent
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: isCurrent ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  digit,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ),
        Opacity(
          opacity: 0.0,
          child: TextField(
            controller: _otpController,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
            cursorColor: Colors.transparent,
            enableInteractiveSelection: false,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (val) {
              setState(() {});
              if (val.length == 6 && !authState.isLoading) {
                _verify();
              }
            },
          ),
        ),
      ],
    );
  }
}
