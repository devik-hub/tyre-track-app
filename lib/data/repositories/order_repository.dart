import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) => OrderRepository());

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _col => _firestore.collection(FirebaseConstants.ordersCollection);

  // ─── Customer: My Orders ───
  Stream<List<OrderModel>> streamUserOrders(String customerId) {
    return _col.where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  // ─── Admin: All Orders ───
  Stream<List<OrderModel>> streamAllOrders() {
    return _col.orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  // ─── Create ───
  Future<void> createOrder(OrderModel order) async {
    await _col.doc(order.orderId).set(order.toMap());
  }

  // ─── Admin: Update Status ───
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _col.doc(orderId).update({'status': newStatus});
  }

  Future<void> updatePaymentStatus(String orderId, String paymentStatus, {String? paymentId}) async {
    final updates = <String, dynamic>{'paymentStatus': paymentStatus};
    if (paymentId != null) updates['paymentId'] = paymentId;
    await _col.doc(orderId).update(updates);
  }
}
