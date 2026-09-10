import 'dart:ui';

/// Fixed, non-secret facts about the client and the app shell.
abstract final class AppConfig {
  /// Legal name of the client, used in copy that is not localised per screen.
  static const String companyName = 'Maruti Water Solution';

  /// Client website, shown on the login screen footer.
  static const String websiteUrl = 'https://maruti-water-2.vercel.app/';

  /// Number used by the "Contact us on WhatsApp" action, in international
  /// format without spaces or a leading plus.
  ///
  /// PLACEHOLDER. The client has not supplied their business WhatsApp number
  /// yet; replace this single constant before building a release. Nothing else
  /// in the app hardcodes a phone number.
  static const String supportWhatsAppNumber = '910000000000';

  /// Locale the app starts in. Gujarati is opt-in through device settings.
  static const Locale defaultLocale = Locale('en');

  /// Locales with a complete translation.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
  ];

  /// State pre-filled on the sign-up form, matching the database default.
  static const String defaultState = 'Gujarat';

  /// Town shown under the company name in the brand lockup.
  static const String companyLocation = 'Botad, Gujarat';

  /// Version shown on the About row. Kept in step with pubspec.yaml.
  /// Version shown in the app and reported to Sentry.
  ///
  /// Carries the build number, not just the semantic version, because every
  /// build until now shipped as versionCode 1 and there was no way -- in the
  /// app, in Android's settings, or in a crash report -- to tell which binary
  /// somebody was actually running. That cost a debugging round trip: a fix
  /// was reported as still broken, and the first thing that had to be ruled
  /// out was whether the new build was even installed.
  ///
  /// Must match `version:` in pubspec.yaml. `test/app_version_test.dart`
  /// fails if it drifts.
  static const String appVersion = '0.1.0+3';

  /// Minimum password length accepted at sign-up.
  static const int minPasswordLength = 8;
}
