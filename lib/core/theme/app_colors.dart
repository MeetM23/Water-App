import 'package:flutter/material.dart';

/// Brand palette for Maruti Water Solution.
///
/// Every colour used anywhere in the app resolves to one of these constants.
/// Nothing in the widget tree may introduce a literal [Color].
abstract final class AppColors {
  /// Brand blue, taken from the client website. Used for primary actions.
  static const Color primary = Color(0xFF0058D6);

  /// Pressed and hovered states of primary surfaces.
  static const Color primaryDark = Color(0xFF0043A3);

  /// Tinted background for selected rows, badges and icon wells.
  static const Color primaryTint = Color(0xFFE8F0FE);

  /// Primary text colour.
  static const Color ink = Color(0xFF0F1729);

  /// Supporting text, captions and inactive icons.
  static const Color textSecondary = Color(0xFF5B6478);

  /// Cards, sheets and app bars.
  static const Color surface = Color(0xFFFFFFFF);

  /// Page background behind cards.
  static const Color background = Color(0xFFF6F8FB);

  /// Hairline borders and dividers.
  static const Color border = Color(0xFFE3E8EF);

  /// Approved states and positive confirmations.
  static const Color success = Color(0xFF0E9F6E);

  /// Pending states and non-blocking cautions.
  static const Color warning = Color(0xFFD97706);

  /// Rejected states, destructive actions and validation errors.
  static const Color danger = Color(0xFFDC2626);

  /// Disabled control fill.
  static const Color disabledFill = Color(0xFFEDF1F6);

  /// Text on top of a disabled control.
  static const Color disabledInk = Color(0xFF9AA3B2);

  /// Scrim behind modals and dialogs.
  static const Color scrim = Color(0x660F1729);

  /// Base of the shimmer sweep used by skeleton placeholders.
  static const Color skeletonBase = Color(0xFFEDF1F6);

  /// Highlight of the shimmer sweep used by skeleton placeholders.
  static const Color skeletonHighlight = Color(0xFFF7F9FC);
}
