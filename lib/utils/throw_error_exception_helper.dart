import 'dart:io';

import 'package:flutter/material.dart';
import 'package:glaze/components/dialogs/dialogs.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void throwAuthExceptionError(BuildContext context, dynamic next, {bool useDialog = false}) {
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

  if (useDialog) {
    Dialogs.createContentDialog(
      context,
      title: 'Error',
      content: errorMessage,
      onPressed: () => context.pop(),
    );
  } else {
    // Show the error message in a SnackBar
    CustomSnackBar.showSnackBar(
      context,
      content: Text(
        errorMessage,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

void throwSupabaseExceptionError(
  BuildContext context,
  dynamic next,
) {
  print('throwSupabaseExceptionError: ${next.runtimeType}');
  String errorMessage = 'An error occurred. Please try again.';

  // Check the type of the error
  if (next is StorageException) {
    final error = next.error as StorageException;
    errorMessage = error.message;
  } else if (next.error is PostgrestException) {
    final error = next.error as PostgrestException;
    errorMessage = error.message;
  } else if (next.error is PathNotFoundException) {
    final error = next.error as PathNotFoundException;
    errorMessage = error.message;
  } else if (next.error is FileSystemException) {
    final error = next.error as FileSystemException;
    errorMessage = error.message;
  } else if (next.error is String) {
    errorMessage = next.error as String;
  }

  // Show the error message in a SnackBar
  CustomSnackBar.showSnackBar(
    context,
    content: Text(errorMessage),
  );
}
