import '../../l10n/generated/app_localizations.dart';
import '../config/app_config.dart';

/// Field-level validation shared by every form.
///
/// Each validator returns null when the value is acceptable, or a localised
/// message to show inline beneath the field.
abstract final class Validators {
  static final RegExp _email = RegExp(
    r'^[\w.!#$%&*+/=?^`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$',
  );

  /// Indian mobile numbers are ten digits and start 6 to 9.
  static final RegExp _indianMobile = RegExp(r'^[6-9][0-9]{9}$');

  /// GSTIN: state code, PAN, entity number, the fixed Z, then a check digit.
  static final RegExp _gstin = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );

  /// Rejects an empty or whitespace-only value.
  static String? required(
    String? value,
    AppLocalizations l10n,
    String fieldLabel,
  ) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationRequired(fieldLabel);
    }
    return null;
  }

  /// Rejects an empty value or one shorter than [minLength] characters.
  static String? name(
    String? value,
    AppLocalizations l10n,
    String fieldLabel, {
    int minLength = 2,
  }) {
    final empty = required(value, l10n, fieldLabel);
    if (empty != null) {
      return empty;
    }
    if (value!.trim().length < minLength) {
      return l10n.validationTooShort(minLength);
    }
    return null;
  }

  /// Rejects anything that is not a plausible email address.
  static String? email(String? value, AppLocalizations l10n) {
    final empty = required(value, l10n, l10n.fieldEmail);
    if (empty != null) {
      return empty;
    }
    if (!_email.hasMatch(value!.trim())) {
      return l10n.validationEmail;
    }
    return null;
  }

  /// Rejects anything that is not a ten-digit Indian mobile number.
  static String? phone(String? value, AppLocalizations l10n) {
    final empty = required(value, l10n, l10n.fieldPhone);
    if (empty != null) {
      return empty;
    }
    if (!_indianMobile.hasMatch(value!.trim())) {
      return l10n.validationPhone;
    }
    return null;
  }

  /// Rejects passwords below the configured minimum length.
  static String? password(String? value, AppLocalizations l10n) {
    final empty = required(value, l10n, l10n.fieldPassword);
    if (empty != null) {
      return empty;
    }
    if (value!.length < AppConfig.minPasswordLength) {
      return l10n.validationPassword;
    }
    return null;
  }

  /// GST is optional, but a value that is present must be well formed.
  static String? optionalGstin(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    if (!_gstin.hasMatch(trimmed.toUpperCase())) {
      return l10n.validationGst;
    }
    return null;
  }
}
