import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // Show splash for 1.5 seconds min
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    // We need to wait for Riverpod to fetch the user model so we know their role
    final authState = ref.read(authProvider);
    
    if (authState.isLoading) {
      // If it's still loading the Firestore document, wait a little bit
      // Setup a listener that fires once when loading completes
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
        if (user.phone.isEmpty && user.uid != 'dev_mock_id_customer' && user.uid != 'dev_mock_id_admin') {
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
            SizedBox(height: 16),
            Text(
              'Jagadale Retreads',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
