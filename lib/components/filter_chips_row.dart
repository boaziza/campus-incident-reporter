import 'package:flutter/material.dart';

import '../utils/constants.dart';

// Horizontal row of chips with an "All" option, used for status and
// category filters.
class FilterChipsRow<T> extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.allLabel = 'All',
  });

  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T?> onSelected;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(allLabel, selected == null, () => onSelected(null)),
          ...options.map(
            (option) => _chip(
              labelOf(option),
              option == selected,
              () => onSelected(option),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }
}
