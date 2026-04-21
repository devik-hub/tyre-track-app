import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
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

  AuthNotifier(this._authRepo) : super(AuthState(isLoading: true)) {
    _init();
  }

  void _init() {
    _authRepo.authStateChanges.listen((User? user) async {
      state = state.copyWith(isLoading: true);
      if (user != null) {
        UserModel? userModel = await _authRepo.getUserData(user.uid);
        // Auto-create profile for Google/Email users on first login
        if (userModel == null) {
          userModel = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'User',
            phone: user.phoneNumber ?? '',
            email: user.email ?? '',
            createdAt: DateTime.now(),
          );
          await _authRepo.saveUserData(userModel);
        }
        state = state.copyWith(userModel: userModel, isLoading: false);
      } else {
        state = state.copyWith(userModel: null, isLoading: false);
      }
    });
  }

  // ─── Phone OTP ───
  Future<void> sendOtp(String phone, Function(String) onCodeSent) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
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

  Future<void> registerWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.registerWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
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
  Future<void> registerUser(String name, String phone, String email) async {
     state = state.copyWith(isLoading: true, clearError: true);
     try {
       final user = _authRepo.currentUser;
       if (user != null) {
         final userModel = UserModel(
           uid: user.uid,
           name: name,
           phone: phone,
           email: email,
           createdAt: DateTime.now(),
         );
         await _authRepo.saveUserData(userModel);
         state = state.copyWith(isLoading: false, userModel: userModel);
       }
     } catch (e) {
       state = state.copyWith(isLoading: false, error: e.toString());
     }
  }

  Future<void> logout() async {
    await _authRepo.signOut();
  }


}
