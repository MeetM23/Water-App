/// Validation for the permanent product codes the database issues.
///
/// The app never *generates* a code. `generate_product_code()` in
/// `supabase/migrations/0005_product_code.sql` owns that, and the value comes
/// back on the insert response. What lives here is the mirror of the check
/// character, so a code a user typed by hand can be rejected offline instead
/// of costing a round trip that will fail anyway.
///
/// Format: `MWS-<PREFIX>-<NNNNNN>-<C>`, for example `MWS-DOM-001042-Z`.
///
/// Check character: sum each digit multiplied by its 1-based position counted
/// from the left, take modulo 36, and index into `0-9A-Z`. The SQL definition
/// is authoritative; this must match it exactly.
abstract final class ProductCode {
  /// Characters in a well-formed code: `MWS-` + 3 + `-` + 6 + `-` + 1.
  ///
  /// Fixed by the format, so the label renderer can size a barcode for it
  /// before any product exists.
  static const int length = 16;

  static const String _alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  static final RegExp _pattern = RegExp(
    r'^MWS-(DOM|COM|IND|SPR|ACC)-([0-9]{6})-([0-9A-Z])$',
  );

  static final RegExp _unitSerialPattern = RegExp(
    r'^MWS-SN-(DOM|COM|IND|SPR|ACC)-([0-9]{6,12})-([0-9A-Z])$',
  );

  /// Computes the base36 check character for a run of digits.
  ///
  /// Throws [FormatException] if [digits] contains anything but 0-9.
  static String checkCharacter(String digits) {
    var sum = 0;
    for (var index = 0; index < digits.length; index++) {
      final digit = int.tryParse(digits[index]);
      if (digit == null) {
        throw FormatException('Product code digits must be numeric', digits);
      }
      sum += digit * (index + 1);
    }
    return _alphabet[sum % 36];
  }

  /// Whether [code] is a valid catalogue product code.
  static bool isValid(String? code) {
    if (code == null) {
      return false;
    }

    final match = _pattern.firstMatch(code.trim().toUpperCase());
    if (match == null) {
      return false;
    }

    final digits = match.group(2)!;
    final expected = match.group(3)!;
    return checkCharacter(digits) == expected;
  }

  /// Whether [code] is a physical unit serial number.
  static bool isUnitSerial(String? code) {
    if (code == null) {
      return false;
    }
    final candidate = code.trim().toUpperCase();
    return candidate.startsWith('MWS-SN-') ||
        _unitSerialPattern.hasMatch(candidate);
  }

  /// Normalises user input into the canonical form, or null if unusable.
  ///
  /// Trims, upper-cases, and verifies format.
  static String? normalise(String? input) {
    if (input == null) {
      return null;
    }
    final candidate = input.trim().toUpperCase();
    if (isValid(candidate) || isUnitSerial(candidate)) {
      return candidate;
    }
    return null;
  }
}
