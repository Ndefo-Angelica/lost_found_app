import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final bool verified;
  final double rating;
  final int reports;
  final String location;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.verified,
    required this.rating,
    required this.reports,
    required this.location,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'verified': verified,
      'rating': rating,
      'reports': reports,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['avatarUrl'],
      verified: data['verified'] ?? false,
      rating: (data['rating'] ?? 0).toDouble(),
      reports: data['reports'] ?? 0,
      location: data['location'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Mock user for testing (keep for now)
  static UserModel mockUser() {
    return UserModel(
      id: '1',
      name: 'Ngono Mbida',
      email: 'ngono.mbida@gmail.com',
      phone: '+237 6XX XXX XXX',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      verified: true,
      rating: 4.8,
      reports: 12,
      location: 'Yaoundé',
      createdAt: DateTime.now(),
    );
  }
}