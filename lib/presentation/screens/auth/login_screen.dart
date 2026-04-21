import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showEmailForm = false;
  bool _isPasswordVisible = false;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    // Strip leading +91 if user typed it, then check we have 10 digits
    final digits = phone.replaceAll(RegExp(r'^\+91'), '').replaceAll(RegExp(r'\s'), '');
    if (digits.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(digits)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    final formattedPhone = '+91$digits';
    await ref.read(authProvider.notifier).sendOtp(formattedPhone, (verificationId) {
      if (context.mounted) context.push('/otp', extra: verificationId);
    });
  }

  Future<void> _signInEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    // Validate before hitting Firebase
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address')),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your password')),
      );
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

    // Auto-navigate on successful auth
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.userModel != null && !next.isLoading) {
        final user = next.userModel!;
        if (user.role == 'admin') {
          // Admin accidentally used user login — sign out and show error
          ref.read(authProvider.notifier).logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin accounts must use Admin Login.'),
            ),
          );
        } else if (user.phone.isEmpty && user.email.isEmpty) {
          // New user — complete profile
          context.go('/register');
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // ─── Logo & Branding ───
              Image.asset('assets/images/logo.png', height: 80,
                  errorBuilder: (c, e, s) => const Icon(Icons.tire_repair, size: 80, color: AppColors.mrfRed)),
              const SizedBox(height: 12),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.mrfRed),
              ),
              Text(
                AppConstants.appTagline,
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
                label: const Text('Continue with Google'),
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
                  onPressed: authState.isLoading ? null : _sendOtp,
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
                    labelText: 'Email Address',
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
                  onPressed: authState.isLoading ? null : _signInEmail,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: authState.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text("Don't have an account? Register", style: TextStyle(color: AppColors.mrfRed, fontSize: 13)),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
