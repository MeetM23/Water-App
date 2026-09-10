import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/app_logger.dart';

part 'locale_controller.g.dart';

/// Key the chosen language is stored under.
const String localePreferenceKey = 'app_locale';

/// The language the app runs in.
///
/// Null means "follow the device", which is the right default: a phone already
/// set to Gujarati should not need the app told twice. Once the owner picks a
/// language explicitly, that choice wins and survives a restart, because the
/// most common reason to pick one is that the device language is not the one
/// the person actually reads.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Locale? build() {
    _restore();
    return null;
  }

  Future<void> _restore() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final code = preferences.getString(localePreferenceKey);
      if (code == null) {
        return;
      }
      final restored = Locale(code);
      if (AppConfig.supportedLocales.contains(restored)) {
        state = restored;
      }
    } on Object catch (error, stackTrace) {
      // A language preference that cannot be read is not worth failing a cold
      // start over. The device language is a sound fallback.
      AppLog.warn(
        'Could not restore the language preference',
        error,
        stackTrace,
      );
    }
  }

  /// Switches the app language, or clears the override when [locale] is null.
  Future<void> select(Locale? locale) async {
    state = locale;
    try {
      final preferences = await SharedPreferences.getInstance();
      if (locale == null) {
        await preferences.remove(localePreferenceKey);
      } else {
        await preferences.setString(localePreferenceKey, locale.languageCode);
      }
    } on Object catch (error, stackTrace) {
      // The switch has already taken effect on screen; only persistence
      // failed, so the app is usable and the choice is lost on restart.
      AppLog.warn('Could not save the language preference', error, stackTrace);
    }
  }
}
