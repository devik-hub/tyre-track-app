import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tyre_service_model.dart';
import '../../data/repositories/service_repository.dart';
import 'auth_provider.dart';

final serviceProvider = StateNotifierProvider<ServiceNotifier, AsyncValue<List<TyreServiceModel>>>((ref) {
  return ServiceNotifier(ref.read(serviceRepositoryProvider), ref.read(authProvider).userModel?.uid);
});

class ServiceNotifier extends StateNotifier<AsyncValue<List<TyreServiceModel>>> {
  final ServiceRepository _repo;
  final String? _userId;

  ServiceNotifier(this._repo, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadServices();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadServices() async {
    if (_userId == null) return;
    state = const AsyncValue.loading();
    try {
      final services = await _repo.getCustomerServices(_userId!);
      state = AsyncValue.data(services);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
