import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.productId, required this.name, required this.quantity, required this.price});

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 1,
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel {
  final String orderId;
  final String customerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String? paymentId;
  final Map<String, dynamic> deliveryAddress;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? invoiceUrl;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.paymentId,
    required this.deliveryAddress,
    required this.createdAt,
    this.estimatedDelivery,
    this.invoiceUrl,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    final itemsList = (data['items'] as List<dynamic>?) ?? [];
    return OrderModel(
      orderId: documentId,
      customerId: data['customerId'] ?? '',
      items: itemsList.map((item) => OrderItem.fromMap(item as Map<String, dynamic>)).toList(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      paymentId: data['paymentId'],
      deliveryAddress: Map<String, dynamic>.from(data['deliveryAddress'] ?? {}),
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      estimatedDelivery: data['estimatedDelivery'] != null ? (data['estimatedDelivery'] as Timestamp).toDate() : null,
      invoiceUrl: data['invoiceUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'deliveryAddress': deliveryAddress,
      'createdAt': Timestamp.fromDate(createdAt),
      'estimatedDelivery': estimatedDelivery != null ? Timestamp.fromDate(estimatedDelivery!) : null,
      'invoiceUrl': invoiceUrl,
    };
  }
}
