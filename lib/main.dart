import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glaze/app.dart';
import 'package:glaze/core/initializer.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      await initializer();
      runApp(
        const ProviderScope(
          child: App(),
        ),
      );
    },
    (error, stack) {
      Fluttertoast.showToast(msg: "$error");
      log("An unhandled exception occurred", error: error, stackTrace: stack);
    },
  );
}
