import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/vehicle_category_model.dart';

final vehicleCategoryRepositoryProvider =
    Provider<VehicleCategoryRepository>((ref) => VehicleCategoryRepository());

class VehicleCategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _col =>
      _firestore.collection(FirebaseConstants.vehicleCategoriesCollection);

  /// Real-time stream of all categories ordered by sortOrder
  Stream<List<VehicleCategoryModel>> streamCategories() {
    return _col.orderBy('sortOrder').snapshots().map(
      (snap) => snap.docs
          .map((doc) => VehicleCategoryModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList(),
    );
  }

  Future<void> addCategory(VehicleCategoryModel category) async {
    await _col.doc(category.categoryId).set(category.toMap());
  }

  Future<void> updateCategory(VehicleCategoryModel category) async {
    await _col.doc(category.categoryId).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _col.doc(categoryId).delete();
  }
}
