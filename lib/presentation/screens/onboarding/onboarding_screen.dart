import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/customer_background.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.92),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.9),
                          blurRadius: 10,
                          offset: const Offset(-4, -4),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                    ),
                    child: const Icon(LucideIcons.disc, size: 52, color: AppColors.primary),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const Gap(28),
                  Text(
                    'MRF Jagadale Retreads',
                    style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const Gap(8),
                  Text(
                    'Certified MRF Retreading & Premium Tyre Care',
                    style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                  const Gap(44),
                  LiquidGlassButton(
                    label: 'Get Started',
                    icon: LucideIcons.arrowRight,
                    onPressed: () => context.go(AppRoutes.roleSelect),
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
