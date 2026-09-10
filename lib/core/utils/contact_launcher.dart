import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import 'app_logger.dart';

/// Opens external contact channels.
///
/// The WhatsApp number lives in [AppConfig] alone; nothing else in the app
/// holds a phone number.
abstract final class ContactLauncher {
  /// Dials [phone] in the device dialer.
  ///
  /// The number is not dialled outright: `tel:` opens the dialer with the
  /// number filled in, which is the correct behaviour on Android and leaves
  /// the owner in control of actually placing the call.
  static Future<bool> call(String phone) async {
    final digits = normalise(phone);
    if (digits.isEmpty) {
      return false;
    }
    try {
      return await launchUrl(Uri(scheme: 'tel', path: digits));
    } on Object catch (error, stackTrace) {
      AppLog.warn('Could not open the dialer', error, stackTrace);
      return false;
    }
  }

  /// Opens a WhatsApp chat with [phone].
  ///
  /// wa.me needs an international number with no plus and no separators. A
  /// ten-digit Indian mobile is assumed to be +91, which is what every number
  /// in this client's book actually is; anything already carrying a country
  /// code is passed through untouched.
  static Future<bool> whatsAppTo(
    String phone, {
    String? prefilledMessage,
  }) async {
    final digits = normalise(phone);
    if (digits.isEmpty) {
      return false;
    }

    final international = digits.length == 10 ? '91$digits' : digits;
    final query = prefilledMessage == null
        ? ''
        : '?text=${Uri.encodeComponent(prefilledMessage)}';

    try {
      return await launchUrl(
        Uri.parse('https://wa.me/$international$query'),
        mode: LaunchMode.externalApplication,
      );
    } on Object catch (error, stackTrace) {
      AppLog.warn('Could not open WhatsApp', error, stackTrace);
      return false;
    }
  }

  /// Strips spaces, dashes, brackets and a leading plus from a phone number.
  static String normalise(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '');

  /// Opens a WhatsApp chat with the client.
  ///
  /// Returns false when no handler is installed, so the caller can tell the
  /// user instead of failing silently.
  static Future<bool> openWhatsApp({String? prefilledMessage}) async {
    final query = prefilledMessage == null
        ? ''
        : '?text=${Uri.encodeComponent(prefilledMessage)}';
    final uri = Uri.parse(
      'https://wa.me/${AppConfig.supportWhatsAppNumber}$query',
    );

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object catch (error, stackTrace) {
      AppLog.warn('Could not open WhatsApp', error, stackTrace);
      return false;
    }
  }
}
