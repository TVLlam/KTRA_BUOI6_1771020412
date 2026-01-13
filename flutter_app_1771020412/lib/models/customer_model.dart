import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String? customerId;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final List<String> preferences;
  final int loyaltyPoints;
  final DateTime? createdAt;
  final bool isActive;

  CustomerModel({
    this.customerId,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.preferences = const [],
    this.loyaltyPoints = 0,
    this.createdAt,
    this.isActive = true,
  });

  // Chuyển từ Firestore Document -> Object Dart
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      customerId: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      // Xử lý mảng an toàn
      preferences: List<String>.from(data['preferences'] ?? []),
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      // Xử lý Timestamp
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Chuyển từ Object Dart -> Map Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'preferences': preferences,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }
}
