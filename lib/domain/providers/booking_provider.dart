import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import 'auth_provider.dart';

/// Real-time stream of current user's bookings
final userBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final user = ref.watch(authProvider).userModel;
  if (user == null) return Stream.value([]);
  return ref.read(bookingRepositoryProvider).streamUserBookings(user.uid);
});

/// Admin: Real-time stream of ALL bookings
final allBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  return ref.read(bookingRepositoryProvider).streamAllBookings();
});
