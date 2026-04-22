import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Admin login — delegates to the unified LoginScreen with isAdminLogin: true.
/// This provides the same Google / Phone / Email auth methods, but verifies
/// the user's Firestore role == 'admin' after authentication.
class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(isAdminLogin: true);
  }
}
