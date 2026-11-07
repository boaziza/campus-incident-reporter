import 'package:flutter/material.dart';

import '../models/incident_category.dart';
import '../utils/constants.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final IncidentCategory? selected;
  final ValueChanged<IncidentCategory> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: IncidentCategory.values.map((category) {
        final isSelected = category == selected;
        return GestureDetector(
          onTap: enabled ? () => onSelected(category) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const SizedBox(height: 6),
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
