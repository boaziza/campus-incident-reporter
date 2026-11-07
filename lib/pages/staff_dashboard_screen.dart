import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/empty_state.dart';
import '../components/incident_card.dart';
import '../components/section_header.dart';
import '../components/summary_card.dart';
import '../components/user_avatar.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';

// Home screen for campus staff: an overview of every report on campus
class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  void _openFiltered(BuildContext context, IncidentStatus? status) {
    final provider = context.read<IncidentProvider>();
    provider.clearFilters();
    provider.setStatusFilter(status);
    Navigator.pushNamed(context, Routes.allReports);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    final provider = context.watch<IncidentProvider>();
    final all = provider.incidents;

    // New reports first, the ones affecting the most students on top
    final needsAttention = all
        .where((i) => i.status == IncidentStatus.submitted)
        .toList()
      ..sort((a, b) => b.upvotes.length.compareTo(a.upvotes.length));

    final open = all.where((i) => !i.status.isClosed).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user?.firstName ?? ''} 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'Staff dashboard: review and resolve campus issues.',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                UserAvatar(initials: user?.initials ?? '?'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SummaryCard(
                  icon: Icons.inbox_outlined,
                  count: all.length,
                  label: 'Total',
                  color: AppColors.primary,
                  onTap: () => _openFiltered(context, null),
                ),
                const SizedBox(width: 8),
                SummaryCard(
                  icon: Icons.fiber_new_outlined,
                  count: provider.countByStatus(all, IncidentStatus.submitted),
                  label: 'New',
                  color: IncidentStatus.submitted.color,
                  onTap: () => _openFiltered(context, IncidentStatus.submitted),
                ),
                const SizedBox(width: 8),
                SummaryCard(
                  icon: Icons.schedule,
                  count: provider.countByStatus(all, IncidentStatus.inProgress),
                  label: 'In Progress',
                  color: const Color(0xFF3B82F6),
                  onTap: () => _openFiltered(context, IncidentStatus.inProgress),
                ),
                const SizedBox(width: 8),
                SummaryCard(
                  icon: Icons.check_circle_outline,
                  count: provider.countByStatus(all, IncidentStatus.resolved),
                  label: 'Resolved',
                  color: IncidentStatus.resolved.color,
                  onTap: () => _openFiltered(context, IncidentStatus.resolved),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Open issues by category'),
            const SizedBox(height: 8),
            _CategoryBreakdown(
              counts: {
                for (final c in IncidentCategory.values)
                  c: open.where((i) => i.category == c).length,
              },
              total: open.length,
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Needs attention',
              onSeeAll: () => _openFiltered(context, IncidentStatus.submitted),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (needsAttention.isEmpty)
              const EmptyState(
                icon: Icons.celebration_outlined,
                title: 'All caught up',
                message: 'There are no new reports waiting for review.',
              )
            else
              ...needsAttention.take(5).map((i) => IncidentCard(incident: i)),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.counts, required this.total});

  final Map<IncidentCategory, int> counts;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: counts.entries.map((entry) {
          final fraction = total == 0 ? 0.0 : entry.value / total;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Icon(entry.key.icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                SizedBox(
                  width: 82,
                  child: Text(entry.key.label,
                      style: const TextStyle(fontSize: 13)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 8,
                      backgroundColor: AppColors.primaryLight,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 24,
                  child: Text(
                    '${entry.value}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
