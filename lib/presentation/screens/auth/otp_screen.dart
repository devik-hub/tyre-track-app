import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/theme/app_colors.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) return;
    
    await ref.read(authProvider.notifier).verifyOtp(widget.verificationId, code);
    if (ref.read(authProvider).userModel != null) {
      if (mounted) context.go('/home');
    } else if (mounted) {
       // If auth succeeded but userModel is empty, they need to register
       if (ref.read(authProvider).error == null && ref.read(authRepositoryProvider).currentUser != null) {
          context.go('/register');
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the 6-digit code sent to your phone',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '000000',
              ),
            ),
            const SizedBox(height: 24),
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(authState.error!, style: const TextStyle(color: AppColors.mrfOrange), textAlign: TextAlign.center),
              ),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _verify,
              child: authState.isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
