import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../utils/constants.dart';

// Shows the uploaded photo, or the category icon when there is no photo
class IncidentThumbnail extends StatelessWidget {
  const IncidentThumbnail({super.key, required this.incident, this.size = 64});

  final Incident incident;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.primaryLight,
      child: Icon(incident.category.icon,
          color: AppColors.primary, size: size * 0.45),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: incident.hasImage
          ? Image.network(
              incident.imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : placeholder,
              errorBuilder: (context, error, stack) => placeholder,
            )
          : placeholder,
    );
  }
}
