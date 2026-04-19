import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String vehicleId;
  final String ownerId;
  final String registrationNumber;
  final String make;
  final String model;
  final int year;
  final String vehicleType;
  final DateTime createdAt;

  VehicleModel({
    required this.vehicleId,
    required this.ownerId,
    required this.registrationNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.vehicleType,
    required this.createdAt,
  });

  factory VehicleModel.fromMap(Map<String, dynamic> data, String documentId) {
    return VehicleModel(
      vehicleId: documentId,
      ownerId: data['ownerId'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      vehicleType: data['vehicleType'] ?? 'car',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'ownerId': ownerId,
      'registrationNumber': registrationNumber.toUpperCase(),
      'make': make,
      'model': model,
      'year': year,
      'vehicleType': vehicleType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
