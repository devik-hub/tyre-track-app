import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String? profileImageUrl;
  final String role;
  final String fcmToken;
  final DateTime createdAt;
  final bool isActive;
  final String preferredLanguage;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email = '',
    this.profileImageUrl,
    this.role = 'customer',
    this.fcmToken = '',
    required this.createdAt,
    this.isActive = true,
    this.preferredLanguage = 'en',
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      role: data['role'] ?? 'customer',
      fcmToken: data['fcmToken'] ?? '',
      createdAt: _parseDate(data['createdAt']),
      isActive: data['isActive'] ?? true,
      preferredLanguage: data['preferredLanguage'] ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'preferredLanguage': preferredLanguage,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? profileImageUrl,
    String? role,
    String? fcmToken,
    bool? isActive,
    String? preferredLanguage,
  }) {
    return UserModel(
      uid: uid,
      createdAt: createdAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      isActive: isActive ?? this.isActive,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
