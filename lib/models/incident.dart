import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident_category.dart';
import 'incident_status.dart';
import 'status_update.dart';

class Incident {
  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final String? imageUrl;
  final String? imagePath; // Cloudinary public_id of the photo
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusUpdate> statusHistory;
  final List<String> upvotes; // uids of students who confirmed "me too"

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.imageUrl,
    this.imagePath,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    this.isAnonymous = false,
    required this.createdAt,
    required this.updatedAt,
    this.statusHistory = const [],
    this.upvotes = const [],
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // Name shown to other students. Staff always see the real name.
  String displayReporter({required bool viewerIsStaff}) {
    if (isAnonymous && !viewerIsStaff) return 'Anonymous student';
    return reporterName;
  }

  factory Incident.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final now = DateTime.now();
    return Incident(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: IncidentCategory.fromString(data['category']),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      imagePath: data['imagePath'],
      status: IncidentStatus.fromString(data['status']),
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? '',
      isAnonymous: data['isAnonymous'] ?? false,
      // serverTimestamp is null locally until the write reaches the server
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? now,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? now,
      statusHistory: (data['statusHistory'] as List<dynamic>? ?? [])
          .map((item) => StatusUpdate.fromMap(item as Map<String, dynamic>))
          .toList(),
      upvotes: (data['upvotes'] as List<dynamic>? ?? [])
          .map((uid) => uid.toString())
          .toList(),
    );
  }

  // for creating a new report in firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'location': location,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'status': status.name,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'isAnonymous': isAnonymous,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': statusHistory.map((update) => update.toMap()).toList(),
      'upvotes': upvotes,
    };
  }

  @override
  String toString() {
    return 'Incident: $title (${status.label})';
  }
}
