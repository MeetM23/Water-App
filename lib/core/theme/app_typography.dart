import 'package:flutter/widgets.dart';

/// The named type scale.
///
/// Widgets read styles from `Theme.of(context).textTheme` or from the extension
/// in `core/extensions`; they never construct a [TextStyle] inline.
///
/// Latin glyphs come from bundled Inter. Gujarati glyphs are not present in
/// Inter, so every style falls back to bundled Noto Sans Gujarati. The fallback
/// is a variable font shipped at its default weight, so heavy Gujarati headings
/// are synthetically emboldened; Latin weights are true cut weights.
abstract final class AppTypography {
  /// Family used for Latin text.
  static const String latin = 'Inter';

  /// Family used for Gujarati text and any glyph Inter does not carry.
  static const String gujarati = 'NotoSansGujarati';

  /// Family used for product codes, where digit alignment matters.
  static const String monospace = 'monospace';

  static const List<String> _fallback = <String>[gujarati];

  /// Screen titles on dashboards and empty states.
  static const TextStyle displayLg = TextStyle(
    fontFamily: latin,
    fontFamilyFallback: _fallback,
    fontSize: 32,
    height: 1.20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// App bar titles and section headers.
  static const TextStyle titleLg = TextStyle(
    fontFamily: latin,
    fontFamilyFallback: _fallback,
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  /// Card headings and dialog titles.
  static const TextStyle titleMd = TextStyle(
    fontFamily: latin,
    fontFamilyFallback: _fallback,
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  /// Lead paragraphs and prominent list rows.
  static const TextStyle bodyLg = TextStyle(
    fontFamily: latin,
    fontFamilyFallback: _fallback,
    fontSize: 16,
    height: 1.50,
    fontWeight: FontWeight.w400,
  );

  /// Default body copy.
  static const TextStyle bodyMd = TextStyle(
    fontFamily: latin,
    fontFamilyFallback: _fallback,
    fontSize: 14,
    height: 1.50,
    fontWeight: FontWeight.w400,
  );

  /// Captions, helper text and timestamps.
  static const TextStyle bodySm = TextStyle(
    fontFamily: latin,
    fontFamilyFallback: _fallback,
    fontSize: 12,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  /// Button labels and field labels.
  static const TextStyle labelLg = TextStyle(
    fontFamily: latin,
    fontFamilyFallback: _fallback,
    fontSize: 14,
    height: 1.20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// Badge text and overline labels.
  static const TextStyle labelSm = TextStyle(
    fontFamily: latin,
    fontFamilyFallback: _fallback,
    fontSize: 12,
    height: 1.20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Product codes and any other fixed-width identifier.
  static const TextStyle mono = TextStyle(
    fontFamily: monospace,
    fontSize: 14,
    height: 1.40,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}
