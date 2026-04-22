import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/otp_rate_limit_repository.dart';
import '../../data/models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(otpRateLimitRepositoryProvider),
  );
});

class AuthState {
  final bool isLoading;
  final UserModel? userModel;
  final String? error;

  AuthState({this.isLoading = false, this.userModel, this.error});

  AuthState copyWith({bool? isLoading, UserModel? userModel, String? error, bool clearError = false}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      userModel: userModel ?? this.userModel,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final OtpRateLimitRepository _otpRateLimitRepo;

  AuthNotifier(this._authRepo, this._otpRateLimitRepo) : super(AuthState(isLoading: true)) {
    _init();
  }

  void _init() {
    _authRepo.authStateChanges.listen((User? user) async {
      state = state.copyWith(isLoading: true);
      if (user != null) {
        // ensureUserDocument creates the doc with role:'customer' if it
        // doesn't exist, or reads the existing one (preserving admin roles).
        final userModel = await _authRepo.ensureUserDocument(user);
        state = state.copyWith(userModel: userModel, isLoading: false);
      } else {
        state = state.copyWith(userModel: null, isLoading: false);
      }
    });
  }

  // ─── Force Re-fetch (Fix #2: Auth State Sync) ───
  /// Invalidates the cached UserModel and re-fetches the fresh Firestore
  /// document for the current Firebase Auth user. Call this after any
  /// operation that mutates the Firestore user doc outside the auth listener.
  Future<void> refreshUserData() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      state = state.copyWith(isLoading: true);
      final userModel = await _authRepo.ensureUserDocument(user);
      state = state.copyWith(userModel: userModel, isLoading: false);
    }
  }

  // ─── Phone OTP ───
  Future<void> sendOtp(String phone, Function(String) onCodeSent) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Check OTP rate limit (max 10 per day)
      await _otpRateLimitRepo.checkAndIncrementOtpCount(phone);

      await _authRepo.verifyPhoneNumber(
        phone,
        (verificationId, forceResendingToken) {
          state = state.copyWith(isLoading: false);
          onCodeSent(verificationId);
        },
        (error) {
          state = state.copyWith(isLoading: false, error: error.message);
        },
        (credential) async {
          await _authRepo.signInWithPhoneCredential(credential);
        }
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      await _authRepo.signInWithPhoneCredential(credential);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── Email/Password ───
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Fix #4: If email already exists in Auth, sign in instead of erroring out.
  /// After sign-in, ensureUserDocument (in _init listener) will create the
  /// Firestore doc if it was missing.
  Future<void> registerWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.registerWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Account exists in Auth but user tried to "register" again.
        // Sign them in instead — _init listener will call ensureUserDocument
        // to create/read the Firestore doc automatically.
        try {
          await _authRepo.signInWithEmail(email, password);
        } on FirebaseAuthException catch (signInError) {
          state = state.copyWith(isLoading: false, error: signInError.message);
        }
      } else {
        state = state.copyWith(isLoading: false, error: e.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── Google Sign-In ───
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authRepo.signInWithGoogle();
      if (result == null) {
        state = state.copyWith(isLoading: false); // User cancelled
      }
      // Auth state listener in _init() handles the rest
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── Profile Registration ───
  /// Updates profile fields via merge — never overwrites the 'role' field.
  /// The returned UserModel includes the Firestore-persisted role, so the
  /// router redirect immediately evaluates correctly after this call.
  /// Throws on Firestore failure so callers can guard navigation.
  Future<void> registerUser(String name, String phone, String email) async {
     state = state.copyWith(isLoading: true, clearError: true);
     try {
       final user = _authRepo.currentUser;
       if (user != null) {
         final updatedModel = await _authRepo.updateUserProfile(
           uid: user.uid,
           name: name,
           phone: phone,
           email: email,
         );
         // updatedModel has the correct role from Firestore (admin/customer)
         state = state.copyWith(isLoading: false, userModel: updatedModel);
       }
     } catch (e) {
       state = state.copyWith(isLoading: false, error: e.toString());
       rethrow; // Let the UI catch this to prevent navigation
     }
  }

  Future<void> logout() async {
    await _authRepo.signOut();
  }
}
