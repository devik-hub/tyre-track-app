import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../../core/constants/firebase_constants.dart';
import '../models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  bool get isGoogleSignInAvailable => true; // Available on all platforms now

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ─── OTP Rate-Limit Check ────────────────────────────────────────────
  // Each phone gets at most 10 OTP requests per calendar day.
  // Counter stored at: otp_counters/{phone}/{yyyyMMdd} → { count: N }
  static const int _maxOtpPerDay = 10;

  Future<void> _checkAndIncrementOtpCount(String phoneNumber) async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    final docRef = _firestore
        .collection('otp_counters')
        .doc(phoneNumber)
        .collection('daily')
        .doc(dateKey);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final current = snap.exists ? (snap.data()?['count'] as int? ?? 0) : 0;
      if (current >= _maxOtpPerDay) {
        throw Exception(
            'OTP limit exceeded for today. Try again tomorrow.');
      }
      tx.set(docRef, {'count': current + 1}, SetOptions(merge: true));
    });
  }

  // ─── Phone Auth ───
  Future<void> verifyPhoneNumber(
      String phoneNumber,
      Function(String, int?) codeSent,
      Function(FirebaseAuthException) verificationFailed,
      Function(PhoneAuthCredential) verificationCompleted) async {
    // Rate-limit check before calling Firebase
    await _checkAndIncrementOtpCount(phoneNumber);

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  // ─── Email/Password Auth ───
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // ─── Google Auth ───
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // On web, use Firebase Auth's built-in popup — no extra config needed
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // On mobile, use google_sign_in package (reads from google-services.json)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // ─── Common ───
  Future<void> signOut() async {
    try { await _googleSignIn.signOut(); } catch (_) {}
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection(FirebaseConstants.usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> saveUserData(UserModel user) async {
    await _firestore.collection(FirebaseConstants.usersCollection).doc(user.uid).set(user.toMap());
  }
}
