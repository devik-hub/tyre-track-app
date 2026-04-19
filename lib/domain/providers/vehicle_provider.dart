import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repositories/vehicle_repository.dart';
import 'auth_provider.dart';
import 'package:uuid/uuid.dart';

final vehicleProvider = StateNotifierProvider<VehicleNotifier, AsyncValue<List<VehicleModel>>>((ref) {
  return VehicleNotifier(ref.read(vehicleRepositoryProvider), ref.read(authProvider).userModel?.uid);
});

class VehicleNotifier extends StateNotifier<AsyncValue<List<VehicleModel>>> {
  final VehicleRepository _repo;
  final String? _userId;

  VehicleNotifier(this._repo, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadVehicles();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadVehicles() async {
    if (_userId == null) return;
    state = const AsyncValue.loading();
    try {
      final vehicles = await _repo.getUserVehicles(_userId!);
      state = AsyncValue.data(vehicles);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addVehicle({required String regNum, required String make, required String model, required int year, required String type}) async {
    if (_userId == null) return;
    try {
      final id = const Uuid().v4();
      final newVec = VehicleModel(
        vehicleId: id, ownerId: _userId!, registrationNumber: regNum, 
        make: make, model: model, year: year, vehicleType: type, createdAt: DateTime.now()
      );
      await _repo.addVehicle(newVec);
      
      if (state is AsyncData) {
         state = AsyncValue.data([...state.value!, newVec]);
      } else {
         await loadVehicles();
      }
    } catch (e) {
      // Handle error gracefully
      throw Exception('Failed to add vehicle');
    }
  }
  
  Future<void> deleteVehicle(String id) async {
     try {
       await _repo.deleteVehicle(id);
       if (state is AsyncData) {
         state = AsyncValue.data(state.value!.where((v) => v.vehicleId != id).toList());
       }
     } catch (e) {
       throw Exception('Failed to delete');
     }
  }
}
