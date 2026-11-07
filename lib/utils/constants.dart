import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C4CF1);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color background = Color(0xFFF7F7FB);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF1F1D2B);
  static const Color textGrey = Color(0xFF8A8A9E);
  static const Color border = Color(0xFFE7E7F0);
}

class AppConstants {
  // Only ALU accounts can register
  static const List<String> allowedEmailDomains = [
    'alustudent.com',
    'alueducation.com',
  ];

  static const List<String> campusLocations = [
    'Block A',
    'Block B',
    'Block C',
    'Library',
    'Cafeteria',
    'Student Residence',
    'Sports Ground',
    'Parking Lot',
    'Admin Office',
    'Other',
  ];

  static const int maxTitleLength = 60;
  static const int maxDescriptionLength = 500;
}

// Values from your Cloudinary dashboard. They are not secret: an unsigned
// upload preset is designed to be used from client apps.
class CloudinaryConfig {
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'campus_incidents';
  static const String folder = 'incident_images';
}

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String reportIncident = '/report';
  static const String details = '/details';
  static const String allReports = '/all-reports';
}
