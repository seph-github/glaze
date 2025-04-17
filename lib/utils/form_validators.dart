import 'package:glaze/utils/common_reg_exp.dart';

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }

  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a username';
  } else if (value.length < 3) {
    return 'Username must be at least 3 characters long';
  } else if (value.length > 20) {
    return 'Username must be less than 20 characters long';
  } else if (RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
    return null;
  } else {
    return 'Can only contain letters, numbers, and underscores';
  }
}

String? validateFullname(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your full name';
  }
  return null;
}

String? validatePhone(String? value) {
  final phoneRegex = phoneNumberRegExp;
  if (!phoneRegex.hasMatch(value!)) {
    return 'Please enter a valid phone number';
  }

  return null;
}

String? validateOrganization(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your organization';
  }
  return null;
}
