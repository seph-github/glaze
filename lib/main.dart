import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/app.dart';
import 'package:glaze/core/initializer.dart';
import 'package:glaze/features/home/provider/video_feed_provider/video_feed_provider.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      final container = await initializer();

      await container.read(videoFeedNotifierProvider.notifier).loadVideos();

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
