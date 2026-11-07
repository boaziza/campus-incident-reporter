import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../models/incident_status.dart';
import '../models/status_update.dart';

// All Firestore reads and writes for incident reports
class IncidentService {
  IncidentService._privateConstructor();

  static final IncidentService instance = IncidentService._privateConstructor();

  final CollectionReference<Map<String, dynamic>> _incidents =
      FirebaseFirestore.instance.collection('incidents');

  // READ: live list of every report, newest first
  Stream<List<Incident>> streamIncidents() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Incident.fromFirestore(doc)).toList());
  }

  // CREATE
  Future<void> createIncident(Incident incident) async {
    await _incidents.add(incident.toFirestore());
  }

  // UPDATE (student edits their own report while it is still "submitted")
  Future<void> updateIncidentDetails({
    required String id,
    required String title,
    required String description,
    required String location,
  }) async {
    await _incidents.doc(id).update({
      'title': title,
      'description': description,
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE (staff only, enforced by firestore.rules)
  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required StatusUpdate update,
  }) async {
    await _incidents.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([update.toMap()]),
    });
  }

  // "Me too" confirmations from other students
  Future<void> toggleUpvote({
    required String id,
    required String uid,
    required bool add,
  }) async {
    await _incidents.doc(id).update({
      'upvotes':
          add ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]),
    });
  }

  // DELETE
  Future<void> deleteIncident(String id) async {
    await _incidents.doc(id).delete();
  }
}
