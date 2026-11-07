import 'package:flutter/material.dart';

enum IncidentCategory {
  facilities('Facilities', Icons.apartment_rounded),
  water('Water', Icons.water_drop_outlined),
  electricity('Electricity', Icons.bolt_rounded),
  safety('Safety', Icons.shield_outlined),
  sanitation('Sanitation', Icons.delete_outline_rounded),
  furniture('Furniture', Icons.chair_outlined);

  final String label;
  final IconData icon;

  const IncidentCategory(this.label, this.icon);

  // Firestore stores the enum name, e.g. "water"
  static IncidentCategory fromString(String? value) {
    return IncidentCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => IncidentCategory.facilities,
    );
  }
}
