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
        final userModel = await _authRepo.getUserData(user.uid);
        state = state.copyWith(userModel: userModel, isLoading: false);
      } else {
        state = state.copyWith(userModel: null, isLoading: false);
      }
    });
  }

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
          await _authRepo.signInWithCredential(credential);
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
      await _authRepo.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

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

  // Purely for test/debug usage
  Future<void> developerBypass(String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(seconds: 1));
    
    final dummyUser = UserModel(
      uid: 'dev_mock_id_$role',
      name: 'Developer Testing',
      phone: '+919999999999',
      role: role,
      createdAt: DateTime.now(),
    );
    
    state = state.copyWith(isLoading: false, userModel: dummyUser);
  }
}
