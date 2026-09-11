import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/owner/settings/application/locale_controller.dart';
import 'l10n/generated/app_localizations.dart';

/// The application widget.
///
/// The locale comes from the controller when the user has picked one and from
/// the device otherwise. English is the fallback for any device language with
/// no translation, because it is the first entry in the supported list.
///
/// Only a light theme is supplied, and [ThemeMode.light] pins it. There is no
/// dark palette in this build: every colour in AppColors is defined for a
/// light surface, and shipping a half-derived dark theme would give the client
/// unreadable grey-on-grey cards. Adding one is a deliberate piece of work,
/// not a switch.
class MarutiWaterApp extends ConsumerWidget {
  /// Creates the app.
  const MarutiWaterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)?.appName ?? 'Maruti Water',
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      locale: ref.watch(localeControllerProvider),
      // IMPORTANT: ref.read, NOT ref.watch.
      //
      // GoRouter owns its own refresh mechanism (RouterRefreshNotifier) which
      // is wired to the session provider inside appRouter(). Watching the
      // provider here would hand MaterialApp.router a brand-new GoRouter
      // instance on every session/locale change, tearing down the old
      // StatefulShellRoute branch navigators while the new ones try to
      // register the same keys — that is the exact source of the
      // '!keyReservation.contains(key)' assertion crash.
      //
      // The router is keepAlive: true, so ref.read returns the same instance
      // for the lifetime of the process, which is exactly what we need.
      routerConfig: ref.read(appRouterProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) {
        // The client's phones are set to large system text far more often than
        // not. Everything is laid out to survive 200%, and the cap stops the
        // 300% and 400% settings some Android skins offer from turning a
        // button label into six lines.
        final scaler = MediaQuery.textScalerOf(
          context,
        ).clamp(minScaleFactor: 0.85, maxScaleFactor: 2);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
