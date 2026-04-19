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
  
  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) return;
    
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(authProvider.notifier).registerUser(name, user.phoneNumber ?? '', email);
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Registration')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address (Optional)',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 32),
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(authState.error!, style: const TextStyle(color: AppColors.mrfOrange)),
              ),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _register,
              child: authState.isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
