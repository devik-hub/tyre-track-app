import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/vehicle_category_model.dart';
import '../../data/repositories/vehicle_category_repository.dart';

/// Real-time stream of all vehicle categories from Firestore
final vehicleCategoryStreamProvider =
    StreamProvider<List<VehicleCategoryModel>>((ref) {
  return ref.read(vehicleCategoryRepositoryProvider).streamCategories();
});
