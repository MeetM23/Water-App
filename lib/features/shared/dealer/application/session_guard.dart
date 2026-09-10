import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/application/session_controller.dart';

part 'session_guard.g.dart';

/// Detects that the owner revoked this dealer's access while the app was open.
///
/// This is subtler than it looks. `catalog_view` has `where is_approved()`
/// baked into it, so a suspended dealer does not get a permission error from
/// the catalogue — they get **zero rows**, which is indistinguishable from an
/// empty catalogue. Only two calls fail loudly:
///
/// * storage, whose read policy is `is_approved()`, returns 403; and
/// * `scan_events` inserts, whose policy is the same, return 42501.
///
/// So the guard works from both directions: a loud failure reports straight
/// in, and a suspiciously empty catalogue triggers a profile re-read. Either
/// way the session controller reloads, the profile comes back suspended, and
/// the router sends the dealer to the blocked screen with the right words on
/// it rather than a generic error.
class SessionGuard {
  /// Creates a guard that re-reads the profile through [_reloadSession].
  ///
  /// Takes a callback rather than a `Ref` so it can be constructed in a test
  /// with no container at all.
  const SessionGuard(this._reloadSession);

  final Future<void> Function() _reloadSession;

  /// Called when a request failed in a way only revocation explains.
  void reportRevoked() {
    AppLog.warn('Session revoked mid-use; reloading the profile');
    // Reloading rather than signing out: the profile read tells the router
    // whether this is a suspension, a rejection, or a transient blip, and each
    // has its own screen. Guessing here would show the wrong one.
    unawaited(_reloadSession());
  }

  /// Called when the catalogue came back empty.
  ///
  /// An empty catalogue is ambiguous: a brand-new project genuinely has no
  /// products. So this re-reads the profile rather than assuming, and the
  /// router acts only if the status actually changed. The cost of being wrong
  /// is one profile query.
  void verifyStillApproved() => unawaited(_reloadSession());

  /// Classifies a failure and reports it if it means revocation.
  ///
  /// Returns true when the failure was handled as a revocation, so callers can
  /// skip their own error UI.
  bool handle(AppFailure failure) {
    if (failure is SessionRevokedFailure) {
      reportRevoked();
      return true;
    }
    return false;
  }
}

/// The application-wide [SessionGuard].
@Riverpod(keepAlive: true)
SessionGuard sessionGuard(Ref<SessionGuard> ref) => SessionGuard(
  () => ref.read(sessionControllerProvider.notifier).reload(),
);
