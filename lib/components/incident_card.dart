import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../utils/incident_details_arguments.dart';
import 'incident_thumbnail.dart';
import 'status_badge.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.details,
              arguments: IncidentDetailsArguments(incidentId: incident.id),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IncidentThumbnail(incident: incident, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        incident.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 13, color: AppColors.textGrey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.timeAgo(incident.createdAt),
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          if (incident.upvotes.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.people_alt_outlined,
                                size: 13, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text(
                              '+${incident.upvotes.length}',
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: incident.status, small: true),
                const Icon(Icons.chevron_right, color: AppColors.textGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
