import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notifId;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? serviceId;
  final String? orderId;
  final bool isRead;
  final DateTime createdAt;
  final String? deepLinkPath;

  NotificationModel({
    required this.notifId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.serviceId,
    this.orderId,
    this.isRead = false,
    required this.createdAt,
    this.deepLinkPath,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String documentId) {
    return NotificationModel(
      notifId: documentId,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'promo',
      serviceId: data['serviceId'],
      orderId: data['orderId'],
      isRead: data['isRead'] ?? false,
      createdAt: _parseDate(data['createdAt']),
      deepLinkPath: data['deepLinkPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifId': notifId,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'serviceId': serviceId,
      'orderId': orderId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'deepLinkPath': deepLinkPath,
    };
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
