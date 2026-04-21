import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';

/// Streams the currently authenticated user's role from Firestore.
/// Returns 'customer' by default if no role is found, or null if not logged in.
final userRoleProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);
  return ref.read(authRepositoryProvider).streamUserRole(user.uid);
});
