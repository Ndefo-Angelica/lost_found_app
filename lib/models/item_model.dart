import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String location;
  final String specificLocation;
  final double? latitude;
  final double? longitude;
  final DateTime date;
  final String status; // 'lost' or 'found'
  final String category;
  final String? imageUrl;
  final String reporterName;
  final String reporterPhone;
  final double reporterRating;
  final bool reporterVerified;
  final int reporterReports;
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.specificLocation,
    this.latitude,
    this.longitude,
    required this.date,
    required this.status,
    required this.category,
    this.imageUrl,
    required this.reporterName,
    required this.reporterPhone,
    required this.reporterRating,
    required this.reporterVerified,
    required this.reporterReports,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'location': location,
      'specificLocation': specificLocation,
      'latitude': latitude,
      'longitude': longitude,
      'date': Timestamp.fromDate(date),
      'status': status,
      'category': category,
      'imageUrl': imageUrl,
      'reporterName': reporterName,
      'reporterPhone': reporterPhone,
      'reporterRating': reporterRating,
      'reporterVerified': reporterVerified,
      'reporterReports': reporterReports,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      specificLocation: data['specificLocation'] ?? '',
      latitude: data['latitude'],
      longitude: data['longitude'],
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'lost',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'],
      reporterName: data['reporterName'] ?? '',
      reporterPhone: data['reporterPhone'] ?? '',
      reporterRating: (data['reporterRating'] ?? 0).toDouble(),
      reporterVerified: data['reporterVerified'] ?? false,
      reporterReports: data['reporterReports'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'min' : 'mins'} ago';
    } else {
      return 'Just now';
    }
  }
}