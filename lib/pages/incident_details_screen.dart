import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/empty_state.dart';
import '../components/incident_thumbnail.dart';
import '../components/primary_button.dart';
import '../components/status_badge.dart';
import '../components/status_timeline.dart';
import '../components/status_update_sheet.dart';
import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../utils/incident_details_arguments.dart';
import '../utils/report_incident_arguments.dart';

class IncidentDetailsScreen extends StatelessWidget {
  const IncidentDetailsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Incident incident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text(
            'This removes the report and its photo permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final success = await provider.deleteIncident(incident);
    messenger.showSnackBar(SnackBar(
      content: Text(success
          ? 'Report deleted.'
          : provider.errorMessage ?? 'Could not delete report.'),
    ));
    if (success) navigator.pop();
  }

  void _openPhoto(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(child: Image.network(url)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as IncidentDetailsArguments;
    final provider = context.watch<IncidentProvider>();
    final isStaff = context.watch<AuthProvider>().isStaff;
    final uid = context.watch<AuthProvider>().appUser?.uid;

    // Read the live incident so status changes show instantly
    final incident = provider.getById(args.incidentId);

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: const EmptyState(
          icon: Icons.search_off,
          title: 'Report not found',
          message: 'It may have been deleted.',
        ),
      );
    }

    final isOwner = incident.reporterId == uid;
    final canEdit = provider.canEdit(incident);
    final canDelete = provider.canDelete(incident);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canEdit || canDelete)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.pushNamed(
                    context,
                    Routes.reportIncident,
                    arguments: ReportIncidentArguments(incidentToEdit: incident),
                  );
                } else if (value == 'delete') {
                  _confirmDelete(context, incident);
                }
              },
              itemBuilder: (context) => [
                if (canEdit)
                  const PopupMenuItem(value: 'edit', child: Text('Edit report')),
                if (canDelete)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete report',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IncidentThumbnail(incident: incident, size: 72),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            incident.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${incident.category.label} • ${incident.location}',
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StatusBadge(status: incident.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: 'Submitted on ${DateFormatter.full(incident.createdAt)}',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.person_outline,
                  text:
                      'Reported by ${isOwner ? 'you' : incident.displayReporter(viewerIsStaff: isStaff)}'
                      '${incident.isAnonymous && (isOwner || isStaff) ? ' (hidden from students)' : ''}',
                ),
                if (incident.upvotes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.people_alt_outlined,
                    text:
                        '${incident.upvotes.length} other student${incident.upvotes.length == 1 ? '' : 's'} also affected',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Heading('Status Timeline'),
                const SizedBox(height: 14),
                StatusTimeline(incident: incident),
                if (incident.statusHistory.length > 1) ...[
                  const Divider(height: 28),
                  const _Heading('Updates from staff'),
                  const SizedBox(height: 8),
                  ...incident.statusHistory.skip(1).toList().reversed.map(
                        (update) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: CircleAvatar(
                            radius: 6,
                            backgroundColor: update.status.color,
                          ),
                          title: Text(
                            '${update.status.label} • ${DateFormatter.short(update.changedAt)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(update.note.isEmpty
                              ? 'Updated by ${update.changedByName}'
                              : '"${update.note}" — ${update.changedByName}'),
                        ),
                      ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Heading('Description'),
                const SizedBox(height: 8),
                Text(
                  incident.description,
                  style: const TextStyle(height: 1.5, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          if (incident.hasImage) ...[
            const SizedBox(height: 16),
            const _Heading('Attached Photo'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _openPhoto(context, incident.imageUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  incident.imageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          height: 220,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (context, error, stack) => const SizedBox(
                    height: 120,
                    child: Center(child: Text('Could not load photo')),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (isStaff)
            PrimaryButton(
              label: 'Update Status',
              icon: Icons.edit_note,
              onPressed: () => StatusUpdateSheet.show(context, incident),
            )
          else if (!isOwner && !incident.status.isClosed)
            _MeTooButton(
              active: provider.hasUpvoted(incident),
              onPressed: () => provider.toggleUpvote(incident),
            ),
        ],
      ),
    );
  }
}

class _MeTooButton extends StatelessWidget {
  const _MeTooButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(active ? Icons.check_circle : Icons.add_circle_outline),
        label: Text(active
            ? 'You confirmed this issue'
            : 'I am affected too'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: active ? AppColors.primaryLight : Colors.white,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
