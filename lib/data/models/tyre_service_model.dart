import 'package:cloud_firestore/cloud_firestore.dart';

class TyreServiceModel {
  final String serviceId;
  final String vehicleId;
  final String customerId;
  final String serviceType;
  final String tyrePosition;
  final DateTime serviceDate;
  final int retreadeingCycleNumber;
  final double treadThickness;
  final String rubberCompound;
  final String technician;
  final double totalCost;
  final String status;
  final bool notification1YrSent;
  final bool notification2YrSent;
  final bool notificationExpirySent;
  final int warrantyMonths;
  final String? notes;
  final String? invoiceUrl;

  TyreServiceModel({
    required this.serviceId,
    required this.vehicleId,
    required this.customerId,
    required this.serviceType,
    required this.tyrePosition,
    required this.serviceDate,
    required this.retreadeingCycleNumber,
    required this.treadThickness,
    required this.rubberCompound,
    required this.technician,
    required this.totalCost,
    required this.status,
    this.notification1YrSent = false,
    this.notification2YrSent = false,
    this.notificationExpirySent = false,
    this.warrantyMonths = 24,
    this.notes,
    this.invoiceUrl,
  });

  factory TyreServiceModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TyreServiceModel(
      serviceId: documentId,
      vehicleId: data['vehicleId'] ?? '',
      customerId: data['customerId'] ?? '',
      serviceType: data['serviceType'] ?? 'retreading',
      tyrePosition: data['tyrePosition'] ?? 'front_left',
      serviceDate: data['serviceDate'] != null ? (data['serviceDate'] as Timestamp).toDate() : DateTime.now(),
      retreadeingCycleNumber: data['retreadeingCycleNumber'] ?? 1,
      treadThickness: (data['treadThickness'] ?? 0.0).toDouble(),
      rubberCompound: data['rubberCompound'] ?? '',
      technician: data['technician'] ?? '',
      totalCost: (data['totalCost'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      notification1YrSent: data['notification1YrSent'] ?? false,
      notification2YrSent: data['notification2YrSent'] ?? false,
      notificationExpirySent: data['notificationExpirySent'] ?? false,
      warrantyMonths: data['warrantyMonths'] ?? 24,
      notes: data['notes'],
      invoiceUrl: data['invoiceUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'vehicleId': vehicleId,
      'customerId': customerId,
      'serviceType': serviceType,
      'tyrePosition': tyrePosition,
      'serviceDate': Timestamp.fromDate(serviceDate),
      'retreadeingCycleNumber': retreadeingCycleNumber,
      'treadThickness': treadThickness,
      'rubberCompound': rubberCompound,
      'technician': technician,
      'totalCost': totalCost,
      'status': status,
      'notification1YrSent': notification1YrSent,
      'notification2YrSent': notification2YrSent,
      'notificationExpirySent': notificationExpirySent,
      'warrantyMonths': warrantyMonths,
      'notes': notes,
      'invoiceUrl': invoiceUrl,
    };
  }
}
