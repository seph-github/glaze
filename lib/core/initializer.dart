import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/data/local/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<ProviderContainer> initializer() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('url', defaultValue: '');
  const apiKey = String.fromEnvironment('apiKey', defaultValue: '');

  await Supabase.initialize(
    url: url,
    anonKey: apiKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
    debug: true,
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 10,
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  // final cachedUser = await SecureCache.load('user_profile', (json) => Profile.fromJson(json));
  // print('🔐 Loaded cached user: $cachedUser');
  return ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(sharedPreferences),
      // userProfileProvider.overrideWith((ref) {
      //   print('✅ userProfileProvider override used with cachedUser: $cachedUser');
      //   return Future.value(cachedUser);
      // }),
    ],
  );
}
