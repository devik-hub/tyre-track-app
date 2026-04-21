import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash for 1.5 seconds minimum
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.isLoading) {
      // Auth is still resolving — wait for the first non-loading state
      ref.listenManual<AuthState>(authProvider, (prev, next) {
        if (!next.isLoading) {
          _routeUser(next);
        }
      });
    } else {
      _routeUser(authState);
    }
  }

  void _routeUser(AuthState authState) {
    if (!mounted) return;
    if (authState.userModel != null) {
      final user = authState.userModel!;
      // If phone is missing (Google/Email user first login), complete profile
      if (user.phone.isEmpty) {
        context.go(AppRoutes.register);
      } else if (user.role == 'admin') {
        context.go(AppRoutes.admin);
      } else {
        context.go(AppRoutes.home);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mrfWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 16),
            const Text(
              'Jagadale Retreads',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
