import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/inventory_settings_model.dart';

/// Real-time stream of /config/inventorySettings
final inventorySettingsProvider = StreamProvider<InventorySettingsModel>((ref) {
  return FirebaseFirestore.instance
      .doc('config/inventorySettings')
      .snapshots()
      .map((snap) {
        if (!snap.exists) return InventorySettingsModel();
        return InventorySettingsModel.fromMap(snap.data() as Map<String, dynamic>);
      });
});
