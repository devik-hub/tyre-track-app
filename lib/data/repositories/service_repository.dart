import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/tyre_service_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) => ServiceRepository());

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addServiceRecord(TyreServiceModel service) async {
    await _firestore.collection(FirebaseConstants.tyreServicesCollection).doc(service.serviceId).set(service.toMap());
  }

  Future<List<TyreServiceModel>> getCustomerServices(String customerId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.tyreServicesCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('serviceDate', descending: true)
        .get();
    return snapshot.docs.map((doc) => TyreServiceModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<TyreServiceModel>> getActiveServices() async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.tyreServicesCollection)
        .where('status', isNotEqualTo: 'completed')
        .get();
    return snapshot.docs.map((doc) => TyreServiceModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateServiceStatus(String serviceId, String status) async {
    await _firestore.collection(FirebaseConstants.tyreServicesCollection).doc(serviceId).update({'status': status});
  }
}
