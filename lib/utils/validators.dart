class Validators {
  // Flexible roll number format - any alphanumeric format (at least 3 characters)
  // Works globally for all universities
  static final RegExp rollNumberRegex = RegExp(r'^[A-Za-z0-9\-]{3,}$');
  
  // CNIC format: xxxxx-xxxxxxx-x
  static final RegExp cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1}$');

  static String? validateRollNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter roll number';
    }
    
    if (!rollNumberRegex.hasMatch(value)) {
      return 'Roll number must be at least 3 characters (alphanumeric)';
    }
    return null;
  }

  static String? validateCnic(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CNIC';
    }
    if (!cnicRegex.hasMatch(value)) {
      return 'Please enter CNIC in correct format (xxxxx-xxxxxxx-x)';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validateSubjectName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter subject name';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateSemester(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter semester';
    }
    final sem = int.tryParse(value);
    if (sem == null || sem < 1 || sem > 8) {
      return 'Enter semester between 1-8';
    }
    return null;
  }

  static String? validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter verification code';
    }
    if (value.length != 6 || int.tryParse(value) == null) {
      return 'Please enter a valid 6-digit code';
    }
    return null;
  }
}

