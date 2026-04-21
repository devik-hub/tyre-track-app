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
  bool _verifyPressed = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }
    setState(() => _verifyPressed = true);
    await ref.read(authProvider.notifier).verifyOtp(widget.verificationId, code);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // FIX: Use ref.listen to navigate REACTIVELY.
    // The auth state listener in AuthNotifier._init() fetches the Firestore
    // user profile AFTER sign-in. Reading the state immediately after
    // verifyOtp() would always see null userModel. ref.listen fires when
    // the state actually updates, so navigation is reliable.
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (!_verifyPressed) return; // Only navigate if user deliberately pressed Verify
      if (next.isLoading) return;

      if (next.userModel != null) {
        // Logged in — go to home (or register if phone field is empty)
        final user = next.userModel!;
        if (user.phone.isEmpty) {
          context.go('/register');
        } else if (user.role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      } else if (next.error != null) {
        // Show error via SnackBar as well (already visible in the UI, belt-and-suspenders)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        setState(() => _verifyPressed = false);
      } else if (!next.isLoading) {
        // Auth succeeded but no Firestore profile yet → complete registration
        final firebaseUser = ref.read(authRepositoryProvider).currentUser;
        if (firebaseUser != null) {
          context.go('/register');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.sms_outlined, size: 64, color: AppColors.mrfRed),
            const SizedBox(height: 16),
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
              style: const TextStyle(fontSize: 28, letterSpacing: 10, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              // Auto-submit once 6 digits are entered
              onChanged: (val) {
                if (val.length == 6 && !authState.isLoading) _verify();
              },
            ),
            const SizedBox(height: 24),
            // Error message
            if (authState.error != null && _verifyPressed)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.mrfOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  authState.error!,
                  style: const TextStyle(color: AppColors.mrfOrange, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _verify,
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
