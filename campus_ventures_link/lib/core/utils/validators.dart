class Validators {
  Validators._();

  static const String studentEmailDomain = '@alustudent.com';
  static const String staffEmailDomain = '@alueducation.com';

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim().toLowerCase();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    if (email.endsWith(staffEmailDomain)) {
      return 'Staff accounts cannot register through the app';
    }

    if (!email.endsWith(studentEmailDomain)) {
      return 'Only $studentEmailDomain emails can register';
    }

    return null;
  }

  static String? loginEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim().toLowerCase();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    if (!email.endsWith(studentEmailDomain) &&
        !email.endsWith(staffEmailDomain)) {
      return 'Use your ALU email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? optionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final url = value.trim();
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\w-]+\.)+[\w-]+(\/[\w- ./?%&=]*)?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(url)) {
      return 'Enter a valid URL';
    }

    return null;
  }
}
