import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Shorthand for the three lookups nearly every widget performs.
extension BuildContextX on BuildContext {
  /// Localised strings for the active locale.
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// The active theme.
  ThemeData get theme => Theme.of(this);

  /// The active type scale.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The active colour scheme.
  ColorScheme get colors => Theme.of(this).colorScheme;
}
