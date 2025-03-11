import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializer() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('url', defaultValue: '');
  const apiKey = String.fromEnvironment('apiKey', defaultValue: '');

  await Supabase.initialize(url: url, anonKey: apiKey);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
}
