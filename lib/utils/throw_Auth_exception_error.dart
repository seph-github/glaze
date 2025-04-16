import 'package:flutter/material.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void throwAuthExceptionError(BuildContext context, dynamic next) {
  String errorMessage = 'An error occurred. Please try again.';

  // Check the type of the error
  if (next.error is AuthApiException) {
    final error = next.error as AuthApiException;
    errorMessage = error.message;
  } else if (next.error is AuthException) {
    final error = next.error as AuthException;
    errorMessage = error.message;
  } else if (next.error is String) {
    errorMessage = next.error as String;
  }

  // Show the error message in a SnackBar
  CustomSnackBar.showSnackBar(
    context,
    message: errorMessage,
  );
}
