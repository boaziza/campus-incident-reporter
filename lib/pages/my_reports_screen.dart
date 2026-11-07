import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/empty_state.dart';
import '../components/filter_chips_row.dart';
import '../components/incident_card.dart';
import '../components/user_avatar.dart';
import '../models/incident_status.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  // Which tab is selected is only UI state, so setState is fine here
  IncidentStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    final provider = context.watch<IncidentProvider>();
    final myReports = provider.myIncidents;
    final visible = provider.myIncidentsByStatus(_selectedStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    UserAvatar(initials: user?.initials ?? '?', radius: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (user?.isStaff ?? false) ? 'Staff' : 'Student',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Stat(count: myReports.length, label: 'Total Reports'),
                    _Stat(
                      count: provider.countByStatus(
                          myReports, IncidentStatus.inProgress),
                      label: 'In Progress',
                    ),
                    _Stat(
                      count: provider.countByStatus(
                          myReports, IncidentStatus.resolved),
                      label: 'Resolved',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilterChipsRow<IncidentStatus>(
            options: IncidentStatus.values,
            selected: _selectedStatus,
            labelOf: (s) => s.label,
            onSelected: (status) => setState(() => _selectedStatus = status),
          ),
          const SizedBox(height: 16),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (visible.isEmpty)
            EmptyState(
              icon: Icons.description_outlined,
              title: _selectedStatus == null
                  ? 'No reports yet'
                  : 'No ${_selectedStatus!.label.toLowerCase()} reports',
              message: 'Reports you submit will show up here.',
            )
          else
            ...visible.map((incident) => IncidentCard(incident: incident)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
