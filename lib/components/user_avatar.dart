import 'package:flutter/material.dart';

import '../utils/constants.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.initials, this.radius = 22});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
