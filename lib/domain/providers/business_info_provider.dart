import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/business_info_model.dart';

/// Real-time stream of /config/businessInfo — shared by customer Help & admin Settings
final businessInfoProvider = StreamProvider<BusinessInfoModel>((ref) {
  return FirebaseFirestore.instance
      .doc('config/businessInfo')
      .snapshots()
      .map((snap) {
        if (!snap.exists) {
          // Return defaults if document not yet seeded
          return BusinessInfoModel.defaults;
        }
        return BusinessInfoModel.fromFirestore(snap);
      });
});

/// Seed /config/businessInfo with defaults if the document doesn't exist yet.
/// Call once at app start from AdminSettingsScreen or a startup hook.
Future<void> seedBusinessInfoIfAbsent() async {
  final doc = FirebaseFirestore.instance.doc('config/businessInfo');
  final snap = await doc.get();
  if (!snap.exists) {
    await doc.set(BusinessInfoModel.defaults.toFirestore());
  }
}
