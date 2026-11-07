import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../models/incident_status.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import 'primary_button.dart';

// Bottom sheet that staff use to move a report to a new status
class StatusUpdateSheet extends StatefulWidget {
  const StatusUpdateSheet({super.key, required this.incident});

  final Incident incident;

  static Future<void> show(BuildContext context, Incident incident) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatusUpdateSheet(incident: incident),
    );
  }

  @override
  State<StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends State<StatusUpdateSheet> {
  final _noteController = TextEditingController();
  IncidentStatus? _selected;
  String? _noteError;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected == null) return;

    // A reason is required when rejecting, so the student knows why
    if (_selected == IncidentStatus.rejected &&
        _noteController.text.trim().length < 5) {
      setState(() => _noteError = 'Please explain why it is rejected');
      return;
    }

    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.updateStatus(
      incident: widget.incident,
      newStatus: _selected!,
      note: _noteController.text,
    );
    if (!mounted) return;

    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
      content: Text(success
          ? 'Status changed to ${_selected!.label}'
          : provider.errorMessage ?? 'Could not update status.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<IncidentProvider>().isSubmitting;
    final options = IncidentStatus.values
        .where((s) => s != widget.incident.status)
        .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Update status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Text(
            'Currently: ${widget.incident.status.label}',
            style: const TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((status) {
              final isSelected = status == _selected;
              return ChoiceChip(
                label: Text(status.label),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: status.color,
                backgroundColor: status.background,
                side: BorderSide.none,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : status.color,
                ),
                onSelected: (_) => setState(() {
                  _selected = status;
                  _noteError = null;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Add a note for the student (e.g. "Plumber assigned")',
              errorText: _noteError,
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Save Status',
            isLoading: isSubmitting,
            onPressed: _selected == null ? null : _save,
          ),
        ],
      ),
    );
  }
}
