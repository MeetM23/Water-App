/// A pricing problem that blocks saving.
enum PriceError {
  /// Wholesale price is missing or not a number.
  wholesaleMissing,

  /// Retail price is missing or not a number.
  retailMissing,

  /// Wholesale price is zero or negative.
  wholesaleNotPositive,

  /// Retail price is zero or negative.
  retailNotPositive,

  /// Retail is below wholesale, which would sell the dealer a loss.
  retailBelowWholesale,

  /// MRP was entered but is not a number.
  mrpMalformed,

  /// MRP was entered as zero or negative.
  mrpNotPositive,
}

/// A pricing oddity worth surfacing that does not block saving.
enum PriceWarning {
  /// Wholesale price is above the printed maximum retail price.
  wholesaleAboveMrp,

  /// Retail price is above the printed maximum retail price.
  retailAboveMrp,

  /// Retail equals wholesale, leaving the dealer no margin at all.
  zeroMargin,
}

/// The outcome of checking a product's three prices against each other.
class PriceValidation {
  /// Creates a validation result.
  const PriceValidation({required this.errors, required this.warnings});

  /// Problems that must be fixed before the product can be saved.
  final Set<PriceError> errors;

  /// Things the owner should see but may deliberately accept.
  final Set<PriceWarning> warnings;

  /// Whether the prices are good enough to save.
  bool get isValid => errors.isEmpty;
}

/// The pricing rules, isolated from any widget so they can be tested directly.
///
/// Selling above MRP is a legal problem in India, not merely an odd price, so
/// it is surfaced prominently; it is a warning rather than an error because the
/// owner may be correcting a stale MRP rather than mispricing.
abstract final class PriceRules {
  /// Checks the three raw field values as the owner typed them.
  static PriceValidation check({
    required String wholesale,
    required String retail,
    String mrp = '',
  }) {
    final errors = <PriceError>{};
    final warnings = <PriceWarning>{};

    final wholesaleValue = _parse(wholesale);
    final retailValue = _parse(retail);
    final trimmedMrp = mrp.trim();
    final mrpValue = trimmedMrp.isEmpty ? null : _parse(trimmedMrp);

    if (wholesale.trim().isEmpty) {
      errors.add(PriceError.wholesaleMissing);
    } else if (wholesaleValue == null) {
      errors.add(PriceError.wholesaleMissing);
    } else if (wholesaleValue <= 0) {
      errors.add(PriceError.wholesaleNotPositive);
    }

    if (retail.trim().isEmpty) {
      errors.add(PriceError.retailMissing);
    } else if (retailValue == null) {
      errors.add(PriceError.retailMissing);
    } else if (retailValue <= 0) {
      errors.add(PriceError.retailNotPositive);
    }

    if (trimmedMrp.isNotEmpty) {
      if (mrpValue == null) {
        errors.add(PriceError.mrpMalformed);
      } else if (mrpValue <= 0) {
        errors.add(PriceError.mrpNotPositive);
      }
    }

    if (wholesaleValue != null &&
        retailValue != null &&
        wholesaleValue > 0 &&
        retailValue > 0) {
      if (retailValue < wholesaleValue) {
        errors.add(PriceError.retailBelowWholesale);
      } else if (retailValue == wholesaleValue) {
        warnings.add(PriceWarning.zeroMargin);
      }

      if (mrpValue != null && mrpValue > 0) {
        if (wholesaleValue > mrpValue) {
          warnings.add(PriceWarning.wholesaleAboveMrp);
        }
        if (retailValue > mrpValue) {
          warnings.add(PriceWarning.retailAboveMrp);
        }
      }
    }

    return PriceValidation(errors: errors, warnings: warnings);
  }

  static double? _parse(String raw) => double.tryParse(raw.trim());
}
