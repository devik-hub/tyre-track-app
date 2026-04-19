import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/vehicle_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) => VehicleRepository());

class VehicleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addVehicle(VehicleModel vehicle) async {
    await _firestore.collection(FirebaseConstants.vehiclesCollection).doc(vehicle.vehicleId).set(vehicle.toMap());
  }

  Future<List<VehicleModel>> getUserVehicles(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.vehiclesCollection)
        .where('ownerId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => VehicleModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _firestore.collection(FirebaseConstants.vehiclesCollection).doc(vehicleId).delete();
  }
}
