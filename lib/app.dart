import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/core/styles/theme.dart';
import 'package:glaze/feature/settings/providers/settings_theme_provider.dart';
import 'package:glaze/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(settingsThemeProvider);

    return MaterialApp.router(
      themeMode: ThemeMode.system,
      theme: lightTheme,
      darkTheme: darkTheme,
      title: 'Glaze',
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: L10n.all,
      locale: const Locale('en'),
    );
  }
}
