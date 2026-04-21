import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/theme/app_colors.dart';

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

  // ── Strong Password Rules ──────────────────────────────────────────
  // Returns null if valid, otherwise an error message.
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Use at least 8 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Add at least 1 uppercase letter (A-Z)';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Add at least 1 lowercase letter (a-z)';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Add at least 1 number (0-9)';
    }
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/]'))) {
      return 'Add at least 1 special character (e.g. @, #, !)';
    }
    return null;
  }

  // Returns a map of each requirement and whether it is satisfied
  Map<String, bool> _getPasswordRequirements(String password) {
    return {
      '8+ characters': password.length >= 8,
      'Uppercase letter': password.contains(RegExp(r'[A-Z]')),
      'Lowercase letter': password.contains(RegExp(r'[a-z]')),
      'Number': password.contains(RegExp(r'[0-9]')),
      'Special character': password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/]')),
    };
  }

  // For users who arrive via Phone OTP (already authenticated, just need profile)
  Future<void> _completeProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(authProvider.notifier).registerUser(name, user.phoneNumber ?? '', email);
      if (mounted) context.go('/home');
    }
  }

  // For brand new email/password signup
  Future<void> _registerWithEmail() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate all fields
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return;
    }

    await ref.read(authProvider.notifier).registerWithEmail(email, password);
    // After Firebase creates the account, save the profile name
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(authProvider.notifier).registerUser(name, '', email);
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAlreadyAuthed = ref.read(authRepositoryProvider).currentUser != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.person_add, size: 64, color: AppColors.mrfRed),
            const SizedBox(height: 12),
            Text(
              isAlreadyAuthed ? 'Complete Your Profile' : 'Sign Up with Email',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isAlreadyAuthed
                  ? 'Just a few details to get started'
                  : 'Create your Jagadale Retreads account',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // ─── Name ───
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Email ───
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: isAlreadyAuthed ? 'Email Address (Optional)' : 'Email Address *',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            // ─── Password (only for new email signups) ───
            if (!isAlreadyAuthed) ...[
              const SizedBox(height: 16),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _passwordController,
                builder: (context, value, _) {
                  final reqs = _getPasswordRequirements(value.text);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      // Live password requirements checklist
                      if (value.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ...reqs.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              Icon(
                                entry.value ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 14,
                                color: entry.value ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: entry.value ? Colors.green : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 24),

            if (authState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.mrfOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(authState.error!, style: const TextStyle(color: AppColors.mrfOrange, fontSize: 13)),
              ),

            ElevatedButton(
              onPressed: authState.isLoading
                  ? null
                  : (isAlreadyAuthed ? _completeProfile : _registerWithEmail),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: authState.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isAlreadyAuthed ? 'Complete Profile' : 'Create Account'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Already have an account? Login', style: TextStyle(color: AppColors.mrfRed)),
            ),
          ],
        ),
      ),
    );
  }
}
