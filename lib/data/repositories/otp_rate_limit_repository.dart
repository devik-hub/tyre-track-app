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

    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final storedDate = data['date'] as String? ?? '';
      final count = data['count'] as int? ?? 0;

      if (storedDate == today) {
        // Same day — check the limit
        if (count >= maxOtpPerDay) {
          throw Exception(
            'You have reached the maximum of $maxOtpPerDay OTP requests for today. Please try again tomorrow.',
          );
        }
        // Under limit — increment
        await docRef.update({'count': count + 1});
      } else {
        // New day — reset counter
        await docRef.set({'date': today, 'count': 1});
      }
    } else {
      // First ever request for this phone
      await docRef.set({'date': today, 'count': 1});
    }
  }
}
