import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/booking_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository());

class BookingRepository{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _col => _firestore.collection(FirebaseConstants.serviceBookingsCollection);

  // Customer's My Bookings
  Stream<List<BookingModel>> streamUserBookings(String customerId){
    return _col.where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  // Admin's All Bookings
  Stream<List<BookingModel>> streamAllBookings(){
    return _col.orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  // Create
  Future<void> createBooking(BookingModel booking) async{
    await _col.doc(booking.bookingId).set(booking.toMap());
  }

  // Admin's Update Status
  Future<void> updateBookingStatus(String bookingId, String newStatus, {String? adminNotes, String? technician}) async{
    final updates = <String, dynamic>{'status': newStatus};
    if(adminNotes != null) updates['adminNotes'] = adminNotes;
    if(technician != null) updates['assignedTechnician'] = technician;
    await _col.doc(bookingId).update(updates);
  }

  // Delete
  Future<void> deleteBooking(String bookingId) async{
    await _col.doc(bookingId).delete();
  }
}
