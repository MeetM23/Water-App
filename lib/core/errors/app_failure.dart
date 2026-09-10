/// Why an operation did not succeed.
///
/// Repositories translate every driver exception into one of these before it
/// crosses a layer boundary, so no widget ever sees a PostgrestException, a
/// SocketException or a raw string from the server.
sealed class AppFailure implements Exception {
  const AppFailure({this.cause, this.stackTrace});

  /// The original error, kept for logging and crash reporting only.
  final Object? cause;

  /// Stack trace captured where the failure was created.
  final StackTrace? stackTrace;
}

/// The device could not reach the server.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({super.cause, super.stackTrace});
}

/// The server was reached but could not fulfil the request.
final class ServerFailure extends AppFailure {
  const ServerFailure({super.cause, super.stackTrace});
}

/// The caller is signed in but is not allowed to do this.
final class PermissionFailure extends AppFailure {
  const PermissionFailure({super.cause, super.stackTrace});
}

/// Something authentication-specific went wrong.
final class AuthFailure extends AppFailure {
  const AuthFailure(this.reason, {super.cause, super.stackTrace});

  /// Which authentication problem occurred.
  final AuthFailureReason reason;
}

/// The account was approved when the app opened and is not any more.
///
/// This is its own failure rather than a [PermissionFailure] because the two
/// need opposite handling. A permission failure means "you cannot do that" and
/// the user stays where they are. This means the owner has suspended or
/// rejected the account mid-session, and the only correct response is to stop
/// showing catalogue data and route to the blocked screen — the dealer is no
/// longer entitled to what is already on their screen.
final class SessionRevokedFailure extends AppFailure {
  const SessionRevokedFailure({super.cause, super.stackTrace});
}

/// Anything not covered above. Always reported, never shown verbatim.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({super.cause, super.stackTrace});
}

/// The specific authentication problems the UI distinguishes.
enum AuthFailureReason {
  /// Email or password did not match.
  invalidCredentials,

  /// Sign-up used an email that already has an account.
  emailAlreadyRegistered,

  /// The refresh token was rejected; the user must sign in again.
  sessionExpired,

  /// The chosen password was refused by the server.
  weakPassword,

  /// The profile row for the signed-in user could not be found.
  missingProfile,

  /// The server refused the request for asking too often. Auth is rate
  /// limited per project, and sign-up is limited hardest of all because
  /// every attempt can send a confirmation email.
  rateLimited,

  /// An authentication error with no more specific mapping.
  unknown,
}
