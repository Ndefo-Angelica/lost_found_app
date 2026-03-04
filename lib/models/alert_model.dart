import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String userId;
  final String type; // 'match', 'claimed', 'nearby', 'update'
  final String title;
  final String description;
  final String location;
  final String? itemId;
  final String? imageUrl;
  final bool read;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    this.itemId,
    this.imageUrl,
    required this.read,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'location': location,
      'itemId': itemId,
      'imageUrl': imageUrl,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      itemId: data['itemId'],
      imageUrl: data['imageUrl'],
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}