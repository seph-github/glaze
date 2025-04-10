import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/core/routing/router.dart';
import 'package:glaze/feature/settings/providers/settings_theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(settingsThemeProviderProvider);
    return MaterialApp.router(
      themeMode: ThemeMode.dark,
      title: 'Glaze',
      theme: theme,
      routerConfig: router,
    );
  }
}
