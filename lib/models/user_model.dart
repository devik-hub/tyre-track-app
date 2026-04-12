class UserModel {
  final String uid;
  final String email;
  final String createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }
}
