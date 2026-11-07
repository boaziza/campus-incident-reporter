import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/empty_state.dart';
import '../components/incident_card.dart';
import '../components/section_header.dart';
import '../components/summary_card.dart';
import '../components/user_avatar.dart';
import '../models/incident_status.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAllReports});

  final VoidCallback onSeeAllReports;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    final provider = context.watch<IncidentProvider>();
    final myReports = provider.myIncidents;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Help make our campus safer.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Text(
                        'Report issues and track their resolution.',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                UserAvatar(initials: user?.initials ?? '?'),
              ],
            ),
            const SizedBox(height: 20),
            const _ReportBanner(),
            const SizedBox(height: 24),
            SectionHeader(title: 'Report Summary', onSeeAll: onSeeAllReports),
            const SizedBox(height: 8),
            Row(
              children: [
                SummaryCard(
                  icon: Icons.description_outlined,
                  count: myReports.length,
                  label: 'My Reports',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                SummaryCard(
                  icon: Icons.schedule,
                  count: provider.countByStatus(
                      myReports, IncidentStatus.inProgress),
                  label: 'In Progress',
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 8),
                SummaryCard(
                  icon: Icons.check_circle_outline,
                  count:
                      provider.countByStatus(myReports, IncidentStatus.resolved),
                  label: 'Resolved',
                  color: IncidentStatus.resolved.color,
                ),
                const SizedBox(width: 8),
                SummaryCard(
                  icon: Icons.error_outline,
                  count: provider.countByStatus(
                      myReports, IncidentStatus.submitted),
                  label: 'Submitted',
                  color: IncidentStatus.rejected.color,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Recent Reports', onSeeAll: onSeeAllReports),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && myReports.isEmpty)
              EmptyState(
                icon: Icons.wifi_off,
                title: 'Something went wrong',
                message: provider.errorMessage!,
              )
            else if (myReports.isEmpty)
              const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No reports yet',
                message: 'Spotted something broken? Tap the + button to report it.',
              )
            else
              ...myReports.take(5).map((i) => IncidentCard(incident: i)),
          ],
        ),
      ),
    );
  }
}

class _ReportBanner extends StatelessWidget {
  const _ReportBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEDE9FE), Color(0xFFD9CFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'See an issue\non campus?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Report it and help improve our learning environment.',
                      style: TextStyle(color: AppColors.textDark, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.location_city_rounded,
                  size: 80, color: AppColors.primary.withValues(alpha: 0.35)),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pushNamed(context, Routes.reportIncident),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Report an Issue',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
