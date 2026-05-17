import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String bloodGroup;
  final String role;
  final String? photoUrl;
  final String? location;
  final bool isAvailable;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.role,
    this.photoUrl,
    this.location,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      role: map['role'] ?? '',
      photoUrl: map['photoUrl'],
      location: map['location'],
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'bloodGroup': bloodGroup,
        'role': role,
        'photoUrl': photoUrl,
        'location': location,
        'isAvailable': isAvailable,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? phone,
    String? bloodGroup,
    String? role,
    String? photoUrl,
    String? location,
    bool? isAvailable,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
    );
  }
}
