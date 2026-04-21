import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/service_availability_model.dart';

final serviceAvailabilityRepositoryProvider =
    Provider<ServiceAvailabilityRepository>((ref) => ServiceAvailabilityRepository());

class ServiceAvailabilityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _col =>
      _firestore.collection(FirebaseConstants.serviceAvailabilityCollection);

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Real-time stream of today's service availability
  Stream<Map<String, bool>> streamTodayAvailability() {
    return _col.doc(_todayKey).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        // Return defaults — all enabled
        return ServiceAvailabilityModel.defaultAvailability(_todayKey).services;
      }
      return ServiceAvailabilityModel.fromMap(
        snapshot.data() as Map<String, dynamic>,
        snapshot.id,
      ).services;
    });
  }

  /// Toggle a single service on/off for today
  Future<void> toggleService(String serviceName, bool isEnabled) async {
    await _col.doc(_todayKey).set(
      {serviceName: isEnabled},
      SetOptions(merge: true),
    );
  }
}
