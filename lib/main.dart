import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glaze/app.dart';
import 'package:glaze/core/initializer.dart';
import 'package:glaze/data/local/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      await initializer();
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      runApp(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(sharedPreferences),
          ],
          child: const App(),
        ),
      );
    },
    (error, stack) {
      if (kDebugMode) {
        log("An unhandled exception occurred", error: error, stackTrace: stack);
        Fluttertoast.showToast(msg: "$error");
      }
    },
  );
}
