import 'package:flutter/services.dart' show appFlavor;

/// Build-time configuration supplied with `--dart-define`.
///
/// Nothing here is read from a file at runtime and nothing is committed. See
/// README.md for the run and build commands, and config/*.json.example for the
/// shape of the values.
abstract final class Env {
  /// Which environment this build points at: `dev` or `prod`.
  ///
  /// Supplied by `--dart-define-from-file=config/<flavour>.json` and checked
  /// against the Gradle flavour by [isFlavorConsistent].
  static const String flavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'dev',
  );

  /// Whether this build points at the production Supabase project.
  static bool get isProduction => flavor == 'prod';

  /// Whether the Gradle flavour and the `--dart-define` set agree.
  ///
  /// Two independent switches select the environment: `--flavor prod` picks the
  /// application id and the app name, and `--dart-define-from-file` picks the
  /// Supabase project. Nothing in the toolchain ties them together, so the way
  /// this goes wrong is a build labelled prod, installed over the client's app,
  /// talking to the development database — with real dealers writing into it.
  ///
  /// [appFlavor] is null under `flutter test` and under a plain `flutter run`
  /// with no flavour, so an unflavoured build is not treated as a mismatch.
  static bool get isFlavorConsistent =>
      appFlavor == null || appFlavor == flavor;
  /// Supabase project URL, for example `https://abcdefgh.supabase.co`.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anon key. This key is public by design and is constrained by the
  /// row level security policies in supabase/migrations. The service_role key
  /// must never be placed here.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Sentry DSN. Empty disables crash reporting.
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Release name reported to Sentry, defaulting to the package id.
  ///
  /// Overridable so a CI build can stamp a commit or a build number into the
  /// release without touching this file.
  static const String sentryRelease = String.fromEnvironment(
    'SENTRY_RELEASE',
    defaultValue: 'com.krishnaailinks.marutiwater',
  );

  /// Whether the Supabase credentials needed to start the app are present.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Human-readable explanation of what is missing, for the startup guard.
  static String get missingDescription {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    return missing.join(', ');
  }

  /// Human-readable explanation of a flavour mismatch, for the startup guard.
  ///
  /// Phrased to complete the sentence "This build ...", like
  /// [missingDescription]'s caller does.
  static String get flavorMismatchDescription =>
      'was made with --flavor $appFlavor '
      'but carries the $flavor dart-defines';
}
