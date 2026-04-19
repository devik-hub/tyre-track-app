import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => NotificationRepository());

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> markAsRead(String notifId) async {
    await _firestore.collection(FirebaseConstants.notificationsCollection).doc(notifId).update({'isRead': true});
  }
  
  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
     return _firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList());
  }
}
