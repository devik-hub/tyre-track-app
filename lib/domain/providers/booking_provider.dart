import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import 'auth_provider.dart';
import 'package:uuid/uuid.dart';

final bookingProvider = StateNotifierProvider<BookingNotifier, AsyncValue<List<BookingModel>>>((ref) {
  return BookingNotifier(ref.read(bookingRepositoryProvider), ref.read(authProvider).userModel?.uid);
});

class BookingNotifier extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final BookingRepository _repo;
  final String? _userId;

  BookingNotifier(this._repo, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadBookings();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadBookings() async {
    if (_userId == null) return;
    state = const AsyncValue.loading();
    try {
      final bookings = await _repo.getCustomerBookings(_userId!);
      state = AsyncValue.data(bookings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> submitBooking({
     required String vehicleId, 
     required String serviceType,
     required List<String> tyrePositions,
     required DateTime preferredDate,
     required String preferredTimeSlot,
     String? description
  }) async {
    if (_userId == null) return;
    try {
      final id = const Uuid().v4();
      final newBooking = BookingModel(
        bookingId: id,
        customerId: _userId!,
        vehicleId: vehicleId,
        serviceType: serviceType,
        tyrePositions: tyrePositions,
        preferredDate: preferredDate,
        preferredTimeSlot: preferredTimeSlot,
        issueDescription: description,
        createdAt: DateTime.now(),
      );
      await _repo.createBooking(newBooking);
      
      if (state is AsyncData) {
         state = AsyncValue.data([newBooking, ...state.value!]);
      } else {
         await loadBookings();
      }
    } catch (e) {
      throw Exception('Failed to book service');
    }
  }
}
