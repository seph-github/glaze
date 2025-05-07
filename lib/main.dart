import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/app.dart';
import 'package:glaze/core/initializer.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      final container = await initializer();

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
    },
    (error, stack) {
      // log('main error: $error');
      // if (kDebugMode) {
      //   log("An unhandled exception occurred", error: error, stackTrace: stack);
      //   Fluttertoast.showToast(msg: "$error");
      // }
    },
  );
}
