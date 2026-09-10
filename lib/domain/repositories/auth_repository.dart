import '../../core/errors/result.dart';
import '../models/profile.dart';
import '../models/sign_up_request.dart';

/// Authentication and profile reads.
///
/// Implementations return [Result] and never throw across this boundary.
abstract interface class AuthRepository {
  /// Emits the signed-in user id, or null once signed out.
  ///
  /// Also emits null when a token refresh fails, which is how a revoked or
  /// expired session reaches the router.
  Stream<String?> get userIdChanges;

  /// The user id for the restored session, or null on a cold start with none.
  String? get currentUserId;

  /// Signs in with email and password.
  Future<Result<void>> signIn({
    required String email,
    required String password,
  });

  /// Creates an account. The new profile is always pending approval.
  Future<Result<void>> signUp(SignUpRequest request);

  /// Ends the session, clearing the local token.
  Future<Result<void>> signOut();

  /// Loads the profile for [userId].
  Future<Result<Profile>> fetchProfile(String userId);

  /// Changes the signed-in user's own password.
  ///
  /// Supabase requires a live session for this, so it changes the password of
  /// whoever is signed in and cannot be pointed at another account. Resetting
  /// a dealer's password is a separate flow that emails them a link.
  Future<Result<void>> changePassword(String newPassword);
}
