import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) => OrderRepository());

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(OrderModel order) async {
    await _firestore.collection(FirebaseConstants.ordersCollection).doc(order.orderId).set(order.toMap());
  }

  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.ordersCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection(FirebaseConstants.ordersCollection).doc(orderId).update({'status': status});
  }
}
