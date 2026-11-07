import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../models/incident_status.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

// Horizontal Submitted -> In Progress -> Resolved tracker
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  static const _steps = [
    IncidentStatus.submitted,
    IncidentStatus.inProgress,
    IncidentStatus.resolved,
  ];

  DateTime? _dateFor(IncidentStatus status) {
    for (final update in incident.statusHistory.reversed) {
      if (update.status == status) return update.changedAt;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (incident.status == IncidentStatus.rejected) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: IncidentStatus.rejected.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.block, color: IncidentStatus.rejected.color),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'This report was rejected by campus staff. See the note below.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _steps.indexOf(incident.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length * 2 - 1, (i) {
        // odd positions are the connecting lines
        if (i.isOdd) {
          final reached = (i ~/ 2) < currentIndex;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 13),
              height: 2,
              color: reached ? AppColors.primary : AppColors.border,
            ),
          );
        }

        final index = i ~/ 2;
        final step = _steps[index];
        final done = index <= currentIndex;
        final date = _dateFor(step);

        return SizedBox(
          width: 76,
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: done ? AppColors.primary : AppColors.border,
                child: Icon(
                  done ? Icons.check : Icons.circle,
                  size: done ? 16 : 8,
                  color: done ? Colors.white : AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                step.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: done ? AppColors.textDark : AppColors.textGrey,
                ),
              ),
              Text(
                date != null ? DateFormatter.short(date) : 'Pending',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
              ),
            ],
          ),
        );
      }),
    );
  }
}
