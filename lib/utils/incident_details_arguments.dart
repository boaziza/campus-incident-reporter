class IncidentDetailsArguments {
  // We pass only the id so the details screen always reads the live
  // version of the incident from IncidentProvider.
  final String incidentId;

  IncidentDetailsArguments({required this.incidentId});
}
