import 'package:cloud_firestore/cloud_firestore.dart';

/// Schedule for a single business day
class DaySchedule {
  final bool isOpen;
  final String? openTime;  // "09:00"
  final String? closeTime; // "19:00"

  DaySchedule({required this.isOpen, this.openTime, this.closeTime});

  factory DaySchedule.fromMap(Map<String, dynamic> data) {
    return DaySchedule(
      isOpen:    data['isOpen'] as bool? ?? false,
      openTime:  data['openTime'] as String?,
      closeTime: data['closeTime'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'isOpen':    isOpen,
    'openTime':  openTime,
    'closeTime': closeTime,
  };
}

class BusinessInfoModel {
  final String businessName;
  final String phone;
  final String whatsapp;
  final String email;
  final String address;
  final String googleMapsUrl;
  final Map<String, DaySchedule> businessHours;
  final Map<String, String> socialLinks;

  BusinessInfoModel({
    required this.businessName,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.address,
    required this.googleMapsUrl,
    required this.businessHours,
    required this.socialLinks,
  });

  factory BusinessInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final hoursRaw = data['businessHours'] as Map<String, dynamic>? ?? {};
    final businessHours = hoursRaw.map((k, v) =>
        MapEntry(k, DaySchedule.fromMap(v as Map<String, dynamic>)));

    return BusinessInfoModel(
      businessName:  data['businessName']  as String? ?? 'Jagadale Retreads',
      phone:         data['phone']         as String? ?? '+919822289488',
      whatsapp:      data['whatsapp']      as String? ?? '+919822289488',
      email:         data['email']         as String? ?? 'jagadaleretrads@gmail.com',
      address:       data['address']       as String? ?? 'Near Khed Shivapur Toll Plaza, Pune-Satara Highway, Pune, Maharashtra 412205',
      googleMapsUrl: data['googleMapsUrl'] as String? ?? 'https://maps.google.com/?q=Jagadale+Retreads',
      businessHours: businessHours,
      socialLinks:   Map<String, String>.from(data['socialLinks'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'businessName':  businessName,
    'phone':         phone,
    'whatsapp':      whatsapp,
    'email':         email,
    'address':       address,
    'googleMapsUrl': googleMapsUrl,
    'businessHours': businessHours.map((k, v) => MapEntry(k, v.toMap())),
    'socialLinks':   socialLinks,
  };

  /// Default seed document written if Firestore doc doesn't yet exist
  static BusinessInfoModel get defaults => BusinessInfoModel(
    businessName: 'Jagadale Retreads',
    phone:        '+919822289488',
    whatsapp:     '+919822289488',
    email:        'jagadaleretrads@gmail.com',
    address:      'Near Khed Shivapur Toll Plaza, Pune-Satara Highway, Pune, Maharashtra 412205',
    googleMapsUrl:'https://maps.google.com/?q=Jagadale+Retreads,+Pune-Satara+Highway',
    businessHours: {
      for (final day in ['monday','tuesday','wednesday','thursday','friday','saturday'])
        day: DaySchedule(isOpen: true,  openTime: '09:00', closeTime: '19:00'),
      'sunday': DaySchedule(isOpen: false),
    },
    socialLinks: {},
  );
}
