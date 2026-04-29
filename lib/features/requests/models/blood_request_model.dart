import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a blood request made by a receiver
class BloodRequestModel {
  final String id;
  final String requesterId;
  final String requesterName;
  final String bloodGroup;
  final String location;
  final DateTime neededDate;
  final String contactInfo;
  final String status; // 'pending', 'fulfilled', 'cancelled'
  final DateTime createdAt;

  const BloodRequestModel({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.bloodGroup,
    required this.location,
    required this.neededDate,
    required this.contactInfo,
    this.status = 'pending',
    required this.createdAt,
  });

  factory BloodRequestModel.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return BloodRequestModel(
      id: doc.id,
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      location: map['location'] ?? '',
      neededDate:
          (map['neededDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contactInfo: map['contactInfo'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'requesterId': requesterId,
        'requesterName': requesterName,
        'bloodGroup': bloodGroup,
        'location': location,
        'neededDate': Timestamp.fromDate(neededDate),
        'contactInfo': contactInfo,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
