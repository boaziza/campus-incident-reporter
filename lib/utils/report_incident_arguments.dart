import '../models/incident.dart';

class ReportIncidentArguments {
  // When set, the report screen opens in edit mode
  final Incident incidentToEdit;

  ReportIncidentArguments({required this.incidentToEdit});
}
