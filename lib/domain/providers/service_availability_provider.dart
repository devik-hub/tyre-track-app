import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/service_availability_repository.dart';

/// Real-time stream of today's service availability
/// Returns a Map<String, bool> e.g. {'retreading': true, 'inspection': false}
/// Defaults all services to true if no Firestore doc exists for today
final serviceAvailabilityProvider = StreamProvider<Map<String, bool>>((ref) {
  return ref.read(serviceAvailabilityRepositoryProvider).streamTodayAvailability();
});
