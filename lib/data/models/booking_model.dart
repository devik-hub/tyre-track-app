import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String customerId;
  final String serviceType;
  final String status;
  final DateTime createdAt;

  // ─── Tyre Details ───
  final String tyreBrand;
  final int quantity;

  // ─── Location & Contact ───
  final String location;
  final String contactNumber;
  final String receiverName;

  // ─── Legacy fields (kept for backward-compat) ───
  final String vehicleId;
  final List<String> tyrePositions;
  final DateTime preferredDate;
  final String preferredTimeSlot;
  final double? currentTreadDepth;
  final String? issueDescription;
  final List<String>? tyreImages;
  final String? assignedTechnician;
  final String? adminNotes;

  BookingModel({
    required this.bookingId,
    required this.customerId,
    required this.serviceType,
    this.status = 'pending',
    required this.createdAt,
    this.tyreBrand = '',
    this.quantity = 1,
    this.location = '',
    this.contactNumber = '',
    this.receiverName = '',
    this.vehicleId = '',
    this.tyrePositions = const [],
    DateTime? preferredDate,
    this.preferredTimeSlot = '',
    this.currentTreadDepth,
    this.issueDescription,
    this.tyreImages,
    this.assignedTechnician,
    this.adminNotes,
  }) : preferredDate = preferredDate ?? DateTime.now();

  factory BookingModel.fromMap(Map<String, dynamic> data, String documentId) {
    return BookingModel(
      bookingId: documentId,
      customerId: data['customerId'] ?? '',
      serviceType: data['serviceType'] ?? 'retreading',
      status: data['status'] ?? 'pending',
      createdAt: _parseDate(data['createdAt']),
      tyreBrand: data['tyreBrand'] ?? '',
      quantity: data['quantity'] ?? 1,
      location: data['location'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      receiverName: data['receiverName'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      tyrePositions: List<String>.from(data['tyrePositions'] ?? []),
      preferredDate: _parseDate(data['preferredDate']),
      preferredTimeSlot: data['preferredTimeSlot'] ?? '',
      currentTreadDepth: data['currentTreadDepth'] != null ? (data['currentTreadDepth'] as num).toDouble() : null,
      issueDescription: data['issueDescription'],
      tyreImages: data['tyreImages'] != null ? List<String>.from(data['tyreImages']) : null,
      assignedTechnician: data['assignedTechnician'],
      adminNotes: data['adminNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'serviceType': serviceType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'tyreBrand': tyreBrand,
      'quantity': quantity,
      'location': location,
      'contactNumber': contactNumber,
      'receiverName': receiverName,
      'vehicleId': vehicleId,
      'tyrePositions': tyrePositions,
      'preferredDate': Timestamp.fromDate(preferredDate),
      'preferredTimeSlot': preferredTimeSlot,
      'currentTreadDepth': currentTreadDepth,
      'issueDescription': issueDescription,
      'tyreImages': tyreImages,
      'assignedTechnician': assignedTechnician,
      'adminNotes': adminNotes,
    };
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
