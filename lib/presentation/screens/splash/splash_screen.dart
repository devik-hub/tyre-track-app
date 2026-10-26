import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _navigateToNext();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isLoading) {
      ref.listenManual<AuthState>(authProvider, (prev, next) {
        if (!next.isLoading) _routeUser(next);
      });
    } else {
      _routeUser(authState);
    }
  }

  void _routeUser(AuthState authState) {
    if (!mounted) return;
    if (authState.userModel != null) {
      final user = authState.userModel!;
      if (user.phone.isEmpty && user.email.isEmpty) {
        context.go(AppRoutes.register);
      } else if (user.role == 'admin') {
        context.go(AppRoutes.admin);
      } else {
        context.go(AppRoutes.home);
      }
    } else {
      context.go(AppRoutes.roleSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E0205),
              Color(0xFF0F0F12),
              Color(0xFF280408),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) => Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(child: child),
                ),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      width: 80,
                      errorBuilder: (c, e, s) => const Icon(LucideIcons.disc, size: 64, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const Gap(24),
              Text(
                'MRF Retreads',
                style: AppTextStyles.labelCaps.copyWith(color: AppColors.secondary, letterSpacing: 2.0),
              ),
              const Gap(6),
              Text(
                'Jagadale Retreads',
                style: AppTextStyles.display2.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const Gap(8),
              Text(
                'Authorized MRF Retreading Franchise',
                style: AppTextStyles.body2.copyWith(color: Colors.white70),
              ),
              const Gap(36),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary.withValues(alpha: 0.85)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
