import '../../l10n/generated/app_localizations.dart';
import 'app_failure.dart';

/// Turns an [AppFailure] into copy a dealer can act on.
///
/// The underlying exception is never shown. Every branch returns a plain
/// sentence that says what happened and implies what to do next.
extension AppFailurePresentation on AppFailure {
  /// Short headline for this failure.
  String title(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetworkTitle,
    ServerFailure() => l10n.errorServerTitle,
    AuthFailure(reason: AuthFailureReason.sessionExpired) =>
      l10n.errorSessionExpiredTitle,
    AuthFailure(reason: AuthFailureReason.invalidCredentials) =>
      l10n.loginFailed,
    AuthFailure(reason: AuthFailureReason.emailAlreadyRegistered) =>
      l10n.signupEmailTaken,
    AuthFailure(reason: AuthFailureReason.rateLimited) =>
      l10n.errorRateLimitedTitle,
    AuthFailure() => l10n.errorGenericTitle,
    SessionRevokedFailure() => l10n.errorRevokedTitle,
    PermissionFailure() => l10n.errorGenericTitle,
    UnexpectedFailure() => l10n.errorGenericTitle,
  };

  /// Supporting sentence for this failure.
  String message(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetworkBody,
    ServerFailure() => l10n.errorServerBody,
    AuthFailure(reason: AuthFailureReason.sessionExpired) =>
      l10n.errorSessionExpiredBody,
    AuthFailure(reason: AuthFailureReason.invalidCredentials) =>
      l10n.errorGenericBody,
    AuthFailure(reason: AuthFailureReason.weakPassword) =>
      l10n.validationPassword,
    AuthFailure(reason: AuthFailureReason.rateLimited) =>
      l10n.errorRateLimitedBody,
    AuthFailure() => l10n.errorGenericBody,
    SessionRevokedFailure() => l10n.errorRevokedBody,
    PermissionFailure() => l10n.errorGenericBody,
    UnexpectedFailure() => l10n.errorGenericBody,
  };
}
