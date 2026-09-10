import 'package:intl/intl.dart';

/// Number and currency formatting.
///
/// Prices use Indian digit grouping throughout: 125000 renders as the lakh
/// form, not the thousand-separated western form.
abstract final class AppFormat {
  static final NumberFormat _rupeesWhole = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  static final NumberFormat _rupeesPrecise = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 2,
  );

  /// Formats a price for display, for example 125000 to the rupee lakh form.
  ///
  /// Paise are shown only when the amount actually carries them, because
  /// catalogue prices are almost always whole rupees.
  static String rupees(num amount) {
    final hasPaise = (amount * 100).round() % 100 != 0;
    return hasPaise
        ? _rupeesPrecise.format(amount)
        : _rupeesWhole.format(amount);
  }
}
