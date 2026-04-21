import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';

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

  @override
  void initState() {
    super.initState();
    // Pre-fill with Google / existing Firebase Auth data
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      if (firebaseUser.displayName != null && firebaseUser.displayName!.isNotEmpty) {
        _nameController.text = firebaseUser.displayName!;
      }
      if (firebaseUser.email != null && firebaseUser.email!.isNotEmpty) {
        _emailController.text = firebaseUser.email!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // For users who arrive via Phone OTP or Google (already authenticated, just need profile)
  Future<void> _completeProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(authProvider.notifier).registerUser(name, user.phoneNumber ?? '', email);
      // After registerUser completes, authState.userModel has the correct
      // Firestore role. The router's redirect guard handles navigation.
      if (mounted) {
        final updatedUser = ref.read(authProvider).userModel;
        if (updatedUser != null && updatedUser.role == 'admin') {
          context.go(AppRoutes.admin);
        } else {
          context.go(AppRoutes.home);
        }
      }
    }
  }

  // For brand new email/password signup
  Future<void> _registerWithEmail() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (name.isEmpty || email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields. Password must be 6+ characters.')),
      );
      return;
    }

    await ref.read(authProvider.notifier).registerWithEmail(email, password);
    // After Firebase creates the account, save the profile name
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(authProvider.notifier).registerUser(name, '', email);
      if (mounted) {
        final updatedUser = ref.read(authProvider).userModel;
        if (updatedUser != null && updatedUser.role == 'admin') {
          context.go(AppRoutes.admin);
        } else {
          context.go(AppRoutes.home);
        }
      }
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
                  helperText: 'Minimum 6 characters',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
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
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Already have an account? Login', style: TextStyle(color: AppColors.mrfRed)),
            ),
          ],
        ),
      ),
    );
  }
}
