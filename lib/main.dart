import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/env.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'data/cache/hive_catalogue_cache.dart';

/// Application entry point.
///
/// Supabase is initialised before the first frame so that a restored session is
/// already available when the router runs its first redirect.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.isConfigured) {
    AppLog.error('Missing build configuration: ${Env.missingDescription}');
    runApp(_MissingConfigurationApp('has no value for ${Env.missingDescription}'));
    return;
  }

  // Refused rather than warned about. A build labelled prod that carries the
  // development Supabase project would install over the client's app and let
  // real dealers write into the wrong database, and it would look completely
  // normal while doing it.
  if (!Env.isFlavorConsistent) {
    AppLog.error('Flavour mismatch: ${Env.flavorMismatchDescription}');
    runApp(_MissingConfigurationApp(Env.flavorMismatchDescription));
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  // Hive opens before the first frame so no screen can reach a cache whose
  // boxes are still opening. On a dealer's phone this is the difference
  // between an instant offline catalogue and an empty one.
  await Hive.initFlutter();
  final cache = HiveCatalogueCache();
  await cache.initialise();

  final overrides = <Override>[
    catalogueCacheProvider.overrideWithValue(cache),
  ];

  // Sentry is opt-in per build. A debug build, or a release built without a
  // DSN, runs the app directly rather than through the wrapper, so nothing is
  // reported from a developer machine and no traffic leaves the device.
  if (Env.sentryDsn.isEmpty) {
    runApp(
      ProviderScope(overrides: overrides, child: const MarutiWaterApp()),
    );
    return;
  }

  await SentryFlutter.init((SentryFlutterOptions options) {
    options
      ..dsn = Env.sentryDsn
      // Release and dist are what make a stack trace attributable to a
      // build. Without them every crash from every version lands in one
      // undifferentiated pile.
      ..release = '${Env.sentryRelease}@${AppConfig.appVersion}'
      ..dist = AppConfig.appVersion
      // The flavour, not the build mode: a release-mode APK built against the
      // development project is exactly the thing that must not file its crashes
      // under 'production'.
      ..environment = Env.isProduction && kReleaseMode
          ? 'production'
          : 'development'
      // A catalogue app for one client does not generate the volume that
      // makes sampling worthwhile, and a dropped crash is a crash nobody
      // fixes.
      ..tracesSampleRate = 0.2
      // Screen names and taps make a report readable without recording what
      // anybody typed.
      ..enableUserInteractionTracing = true
      // The default attaches the device name and the signed-in user where it
      // can find one. Neither is needed to fix a crash, and both are the
      // client's dealers' data.
      ..sendDefaultPii = false;
  }, appRunner: () => runApp(const ProviderScope(child: MarutiWaterApp())));
}

/// Shown when the app was built wrongly: missing dart-defines, or a Gradle
/// flavour that disagrees with the ones it was given.
///
/// This is a developer-facing build error, not a user-facing state, so its text
/// is deliberately not localised: a dealer can never reach it, because a
/// release build with either fault would fail this check on the first run.
class _MissingConfigurationApp extends StatelessWidget {
  const _MissingConfigurationApp(this.problem);

  /// What is wrong with this build, phrased to complete "This build ...".
  final String problem;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(Spacing.x6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.settings_outlined,
                  size: 40,
                  color: AppColors.danger,
                ),
                const SizedBox(height: Spacing.x5),
                Text(
                  'Build configuration missing',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.x2),
                Text(
                  'This build $problem. '
                  'See the build commands in README.md.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
