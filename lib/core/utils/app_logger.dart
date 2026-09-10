import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Application logger.
///
/// `print` is banned by the analysis options. Everything that would have been
/// a print goes through here, which is silent below warning level in release
/// builds so that a dealer phone does not spend cycles formatting debug text.
abstract final class AppLog {
  static final Logger _logger = Logger(
    level: kReleaseMode ? Level.warning : Level.debug,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      printEmojis: false,
    ),
  );

  /// Verbose detail useful only while developing.
  static void debug(String message) => _logger.d(message);

  /// Notable but expected events, such as a completed sign-in.
  static void info(String message) => _logger.i(message);

  /// Recoverable problems that did not stop the user.
  static void warn(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  /// Failures the user was told about.
  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
