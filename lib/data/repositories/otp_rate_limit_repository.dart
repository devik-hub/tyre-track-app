import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/firebase_constants.dart';

final otpRateLimitRepositoryProvider =
    Provider<OtpRateLimitRepository>((ref) => OtpRateLimitRepository());

class OtpRateLimitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const int maxOtpPerDay = 10;

  /// Check the OTP count for a phone number today.
  /// If under the limit, increments the count.
  /// Throws an exception if the limit is reached.
  Future<void> checkAndIncrementOtpCount(String phone) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _firestore
        .collection(FirebaseConstants.otpRateLimitsCollection)
        .doc(phone);

    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(docRef);

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final storedDate = data['date'] as String? ?? '';
        final count = data['count'] as int? ?? 0;

        if (storedDate == today) {
          if (count >= maxOtpPerDay) {
            throw Exception(
              'You have reached the maximum of $maxOtpPerDay OTP requests for today. Please try again tomorrow.',
            );
          }
          tx.update(docRef, {'count': count + 1});
        } else {
          tx.set(docRef, {'date': today, 'count': 1});
        }
      } else {
        tx.set(docRef, {'date': today, 'count': 1});
      }
    });
  }
}
