import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../firebase/firebase.dart';

Future<void> initializer() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebaseApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
}
