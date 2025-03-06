// firebase.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:glaze/firebase_options_production.dart' as production;
import 'package:glaze/firebase_options_development.dart' as development;

Future<void> initializeFirebaseApp() async {
  // Determine which Firebase options to use based on the flavor
  final firebaseOptions = switch (appFlavor) {
    'production' => production.DefaultFirebaseOptions.currentPlatform,
    'development' => development.DefaultFirebaseOptions.currentPlatform,
    _ => throw UnsupportedError('Invalid flavor: $appFlavor'),
  };
  await Firebase.initializeApp(options: firebaseOptions);
}
