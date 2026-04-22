import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  /// When true, the screen verifies the user has role == 'admin' after login.
  /// If not, it signs out and shows an access-denied message.
  final bool isAdminLogin;

  const LoginScreen({super.key, this.isAdminLogin = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showEmailForm = false;
  bool _isPasswordVisible = false;

  bool get _isAdminLogin => widget.isAdminLogin;

  // ── Validation helpers ──
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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

  Future<void> _signInGoogle() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // ── Reactive navigation after auth completes ──
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.userModel != null && !next.isLoading) {
        final user = next.userModel!;

        if (_isAdminLogin) {
          // Admin path: verify the Firestore role
          if (user.role == 'admin') {
            context.go(AppRoutes.admin);
          } else {
            // Not an admin — sign out and show error
            ref.read(authProvider.notifier).logout();
            _showSnack('Access Denied: You do not have administrator privileges.');
          }
        } else {
          // Customer path
          if (user.role == 'admin') {
            // Admin logged in via customer path — route to admin dashboard
            context.go(AppRoutes.admin);
          } else if (user.phone.isEmpty && user.email.isEmpty) {
            // New user — complete profile
            context.go(AppRoutes.register);
          } else {
            context.go(AppRoutes.home);
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // ─── Logo & Branding ───
              Icon(
                _isAdminLogin ? Icons.admin_panel_settings : Icons.tire_repair,
                size: 80,
                color: AppColors.mrfRed,
              ),
              const SizedBox(height: 12),
              Text(
                _isAdminLogin ? 'Admin Access' : AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.mrfRed),
              ),
              Text(
                _isAdminLogin
                    ? 'Restricted to authorised administrators only'
                    : AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 36),

              // ─── Error Banner ───
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.mrfOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.mrfOrange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.mrfOrange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(authState.error!, style: const TextStyle(color: AppColors.mrfOrange, fontSize: 13))),
                    ],
                  ),
                ),

              // ─── Google Sign-In Button ───
              OutlinedButton.icon(
                onPressed: authState.isLoading ? null : _signInGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                label: Text(_isAdminLogin ? 'Sign in with Google' : 'Continue with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Divider ───
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Toggle: Phone / Email ───
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showEmailForm = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_showEmailForm ? AppColors.mrfRed : Colors.grey.shade100,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, size: 18, color: !_showEmailForm ? Colors.white : Colors.grey),
                            const SizedBox(width: 6),
                            Text('Phone', style: TextStyle(
                                color: !_showEmailForm ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showEmailForm = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _showEmailForm ? AppColors.mrfRed : Colors.grey.shade100,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.email, size: 18, color: _showEmailForm ? Colors.white : Colors.grey),
                            const SizedBox(width: 6),
                            Text('Email', style: TextStyle(
                                color: _showEmailForm ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Phone Form ───
              if (!_showEmailForm) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixText: '+91 ',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (authState.isLoading) return;
                    _sendOtp();
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: authState.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Send OTP'),
                ),
              ],

              // ─── Email Form ───
              if (_showEmailForm) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: _isAdminLogin ? 'Admin Email' : 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (authState.isLoading) return;
                    _signInEmail();
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: authState.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isAdminLogin ? 'Sign In as Admin' : 'Sign In'),
                ),
                if (!_isAdminLogin) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text("Don't have an account? Register", style: TextStyle(color: AppColors.mrfRed, fontSize: 13)),
                  ),
                ],
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
