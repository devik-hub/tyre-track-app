import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BUG #2 FIX — Customer detail provider — never throws, gracefully null
// ═══════════════════════════════════════════════════════════════════════════

/// Streams a single user document by UID.
/// Returns null (not throws) when the document does not exist.
/// All parse errors are caught and logged.
final customerDetailProvider =
    StreamProvider.family<UserModel?, String>((ref, customerId) {
  if (customerId.isEmpty) {
    print('⚠️ customerDetailProvider: empty customerId — returning null stream');
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(customerId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) {
          print('⚠️ customerDetailProvider: user $customerId not found in Firestore — using denormalized fields');
          return null;
        }
        try {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return UserModel.fromMap(data, doc.id);
        } catch (e, s) {
          print('❌ customerDetailProvider parse error for $customerId: $e\n$s');
          return null;
        }
      })
      .handleError((e, s) {
        print('❌ customerDetailProvider stream error for $customerId: $e\n$s');
        return null;
      });
});
