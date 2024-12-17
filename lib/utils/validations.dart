class Validations {
  static String? validateFullName(String fullName) {
    if (fullName.isEmpty) {
      return 'Full name is required.';
    }
    if (fullName.length < 3) {
      return 'Full name must be at least 3 characters long.';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(fullName)) {
      return 'Full name can only contain letters and spaces.';
    }
    return null; // Valid
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Please enter a valid email.';
    }
    return null; // Valid
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null; // Valid
  }
}
