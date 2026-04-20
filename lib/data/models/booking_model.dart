import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String customerId;
  final String vehicleId;
  final String serviceType;
  final List<String> tyrePositions;
  final DateTime preferredDate;
  final String preferredTimeSlot;
  final double? currentTreadDepth;
  final String? issueDescription;
  final List<String>? tyreImages;
  final String status;
  final String? assignedTechnician;
  final String? adminNotes;
  final DateTime createdAt;

  BookingModel({
    required this.bookingId,
    required this.customerId,
    required this.vehicleId,
    required this.serviceType,
    required this.tyrePositions,
    required this.preferredDate,
    required this.preferredTimeSlot,
    this.currentTreadDepth,
    this.issueDescription,
    this.tyreImages,
    this.status = 'pending',
    this.assignedTechnician,
    this.adminNotes,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> data, String documentId) {
    return BookingModel(
      bookingId: documentId,
      customerId: data['customerId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      serviceType: data['serviceType'] ?? 'retreading',
      tyrePositions: List<String>.from(data['tyrePositions'] ?? []),
      preferredDate: _parseDate(data['preferredDate']),
      preferredTimeSlot: data['preferredTimeSlot'] ?? 'morning',
      currentTreadDepth: data['currentTreadDepth'] != null ? (data['currentTreadDepth'] as num).toDouble() : null,
      issueDescription: data['issueDescription'],
      tyreImages: data['tyreImages'] != null ? List<String>.from(data['tyreImages']) : null,
      status: data['status'] ?? 'pending',
      assignedTechnician: data['assignedTechnician'],
      adminNotes: data['adminNotes'],
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'tyrePositions': tyrePositions,
      'preferredDate': Timestamp.fromDate(preferredDate),
      'preferredTimeSlot': preferredTimeSlot,
      'currentTreadDepth': currentTreadDepth,
      'issueDescription': issueDescription,
      'tyreImages': tyreImages,
      'status': status,
      'assignedTechnician': assignedTechnician,
      'adminNotes': adminNotes,
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
