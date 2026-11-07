import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/empty_state.dart';
import '../components/filter_chips_row.dart';
import '../components/incident_card.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';

// Browse every campus report with search, category and status filters
class AllReportsScreen extends StatefulWidget {
  const AllReportsScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<AllReportsScreen> createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends State<AllReportsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<IncidentProvider>().searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAll(IncidentProvider provider) {
    _searchController.clear();
    provider.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final results = provider.filteredIncidents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Reports'),
        automaticallyImplyLeading: widget.showBackButton,
        actions: [
          if (provider.hasActiveFilters)
            TextButton(
              onPressed: () => _clearAll(provider),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by title, description or location',
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                suffixIcon: provider.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: FilterChipsRow<IncidentStatus>(
              options: IncidentStatus.values,
              selected: provider.statusFilter,
              labelOf: (s) => s.label,
              allLabel: 'All statuses',
              onSelected: provider.setStatusFilter,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: FilterChipsRow<IncidentCategory>(
              options: IncidentCategory.values,
              selected: provider.categoryFilter,
              labelOf: (c) => c.label,
              allLabel: 'All categories',
              onSelected: provider.setCategoryFilter,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${results.length} report${results.length == 1 ? '' : 's'}',
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
            ),
          ),
          Expanded(child: _buildList(provider, results)),
        ],
      ),
    );
  }

  Widget _buildList(IncidentProvider provider, List<Incident> results) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.incidents.isEmpty) {
      return EmptyState(
        icon: Icons.wifi_off,
        title: 'Could not load reports',
        message: provider.errorMessage!,
      );
    }
    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: provider.hasActiveFilters ? 'No matches' : 'No reports yet',
        message: provider.hasActiveFilters
            ? 'Try a different search or clear the filters.'
            : 'Reports from across campus will appear here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: results.length,
      itemBuilder: (context, index) => IncidentCard(incident: results[index]),
    );
  }
}
