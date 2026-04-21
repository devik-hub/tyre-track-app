import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleCategoryModel {
  final String categoryId;
  final String name;
  final String icon;
  final int sortOrder;
  final DateTime createdAt;

  VehicleCategoryModel({
    required this.categoryId,
    required this.name,
    this.icon = 'directions_car',
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory VehicleCategoryModel.fromMap(Map<String, dynamic> data, String documentId) {
    return VehicleCategoryModel(
      categoryId: documentId,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'directions_car',
      sortOrder: data['sortOrder'] ?? 0,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
