import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident_status.dart';

// One entry in an incident's status timeline
class StatusUpdate {
  final IncidentStatus status;
  final String note;
  final String changedBy;
  final String changedByName;
  final DateTime changedAt;

  StatusUpdate({
    required this.status,
    this.note = '',
    required this.changedBy,
    required this.changedByName,
    required this.changedAt,
  });

  factory StatusUpdate.fromMap(Map<String, dynamic> map) {
    return StatusUpdate(
      status: IncidentStatus.fromString(map['status']),
      note: map['note'] ?? '',
      changedBy: map['changedBy'] ?? '',
      changedByName: map['changedByName'] ?? '',
      changedAt: (map['changedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // serverTimestamp() is not allowed inside arrays, so we use Timestamp
  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'note': note,
      'changedBy': changedBy,
      'changedByName': changedByName,
      'changedAt': Timestamp.fromDate(changedAt),
    };
  }
}
