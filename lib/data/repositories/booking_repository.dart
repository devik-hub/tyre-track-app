import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/booking_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository());

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBooking(BookingModel booking) async {
    await _firestore.collection(FirebaseConstants.serviceBookingsCollection).doc(booking.bookingId).set(booking.toMap());
  }

  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.serviceBookingsCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList();
  }
  
  Future<List<BookingModel>> getAllBookings() async {
     final snapshot = await _firestore
        .collection(FirebaseConstants.serviceBookingsCollection)
        .orderBy('createdAt', descending: true)
        .get();
     return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection(FirebaseConstants.serviceBookingsCollection).doc(bookingId).update({'status': status});
  }
}
