import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../app/theme/app_colors.dart';

/// Admin-only login screen.
/// Accepts email + password. After login, validates that the Firestore
/// role == 'admin'. If not, signs out and shows an error.
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

  // ── Validation helpers ────────────────────────────────────────────────
  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  String? _validatePassword(String password) {
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'Add at least 1 uppercase letter';
    if (!password.contains(RegExp(r'[a-z]'))) return 'Add at least 1 lowercase letter';
    if (!password.contains(RegExp(r'[0-9]'))) return 'Add at least 1 number';
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Add at least 1 special character';
    }
    return null;
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // ── Client-side validation ──
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

    // After Firebase auth, check role in Firestore via authProvider
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.error != null) return; // Error already shown in UI

    final role = authState.userModel?.role ?? '';
    if (role != 'admin') {
      // Not an admin — sign out immediately and show error
      await ref.read(authProvider.notifier).logout();
      _showSnack('Access denied. This login is for Admins only.');
      return;
    }

    // Role confirmed — navigate to admin dashboard
    if (mounted) context.go('/admin');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Reactive navigation: if admin logs in successfully, go to /admin
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.isLoading || next.error != null) return;
      if (next.userModel != null && next.userModel!.role == 'admin') {
        context.go('/admin');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.admin_panel_settings,
                size: 72,
                color: AppColors.mrfRed,
              ),
              const SizedBox(height: 12),
              const Text(
                'Admin Access',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Restricted to authorised administrators only',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 40),

              // ── Error Banner ──────────────────────────────────────────
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.mrfOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.mrfOrange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          color: AppColors.mrfOrange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: const TextStyle(
                              color: AppColors.mrfOrange, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Email ─────────────────────────────────────────────────
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Admin Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),

              // ── Password ──────────────────────────────────────────────
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 28),

              // ── Sign In Button ────────────────────────────────────────
              ElevatedButton(
                onPressed: authState.isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Sign In as Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
