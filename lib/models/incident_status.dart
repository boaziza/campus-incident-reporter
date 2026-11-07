import 'package:flutter/material.dart';

enum IncidentStatus {
  submitted('Submitted', Color(0xFFF59E0B), Color(0xFFFFF4DE)),
  inProgress('In Progress', Color(0xFF6C4CF1), Color(0xFFEDE9FE)),
  resolved('Resolved', Color(0xFF16A34A), Color(0xFFDCFCE7)),
  rejected('Rejected', Color(0xFFDC2626), Color(0xFFFEE2E2));

  final String label;
  final Color color;
  final Color background;

  const IncidentStatus(this.label, this.color, this.background);

  static IncidentStatus fromString(String? value) {
    return IncidentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => IncidentStatus.submitted,
    );
  }

  // Once a report is resolved or rejected staff cannot move it again
  bool get isClosed =>
      this == IncidentStatus.resolved || this == IncidentStatus.rejected;
}
