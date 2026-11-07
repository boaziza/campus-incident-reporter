import 'constants.dart';

class Validators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your full name';
    if (value.trim().length < 3) return 'Name is too short';
    return null;
  }

  static bool isAluEmail(String email) {
    final domain = email.trim().toLowerCase().split('@').last;
    return AppConstants.allowedEmailDomains.contains(domain);
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    if (!isAluEmail(value)) return 'Use your ALU email (@alustudent.com)';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please give the issue a title';
    if (value.trim().length < 5) return 'Title must be at least 5 characters';
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please describe the issue';
    if (value.trim().length < 15) {
      return 'Add a bit more detail (at least 15 characters)';
    }
    return null;
  }

  static String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Please select a $field';
    return null;
  }
}
