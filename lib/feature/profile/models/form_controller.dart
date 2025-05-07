import 'package:flutter/material.dart';

class FormControllers {
  final TextEditingController fullname;
  final TextEditingController email;
  final TextEditingController code;
  final TextEditingController phone;
  final TextEditingController organization;

  FormControllers({
    required this.fullname,
    required this.email,
    required this.code,
    required this.phone,
    required this.organization,
  });

  void dispose() {
    fullname.dispose();
    email.dispose();
    code.dispose();
    phone.dispose();
    organization.dispose();
  }
}
