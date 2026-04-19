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

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) return;
    
    final formattedPhone = phone.startsWith('+91') ? phone : '+91$phone';
    
    await ref.read(authProvider.notifier).sendOtp(formattedPhone, (verificationId) {
      context.push('/otp', extra: verificationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.mrfRed),
              ),
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+91 ',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(authState.error!, style: const TextStyle(color: AppColors.mrfOrange)),
                ),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _sendOtp,
                child: authState.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Login with OTP'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('New here? Register', style: TextStyle(color: AppColors.mrfRed)),
              ),
              const Divider(height: 48),
              Text(
                 'Developer Testing Shortcuts', 
                 textAlign: TextAlign.center, 
                 style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)
              ),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                    TextButton(
                       onPressed: () async {
                          await ref.read(authProvider.notifier).developerBypass('customer');
                          if (context.mounted) context.go('/home');
                       },
                       child: const Text('Login as Customer', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton(
                       onPressed: () async {
                          await ref.read(authProvider.notifier).developerBypass('admin');
                          if (context.mounted) context.go('/home');
                       },
                       child: const Text('Login as Admin', style: TextStyle(fontSize: 12)),
                    ),
                 ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
