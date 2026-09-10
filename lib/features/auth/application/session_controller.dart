import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/supabase_auth_repository.dart';
import '../../../domain/models/profile.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'session_controller.g.dart';

/// Who is using the app right now.
sealed class SessionState {
  const SessionState();
}

/// No valid session. The router sends these users to login.
final class SessionSignedOut extends SessionState {
  /// Creates the signed-out state.
  const SessionSignedOut();
}

/// A valid session and the profile it resolved to.
final class SessionSignedIn extends SessionState {
  /// Creates the signed-in state.
  const SessionSignedIn(this.profile);

  /// Role and approval status for the signed-in user.
  final Profile profile;
}

/// Emits the signed-in user id, starting with whatever the cold start restored.
///
/// Seeding with `currentUserId` before listening is what removes the flash of
/// the login screen on launch: by the time the router runs its first redirect
/// the restored session is already known.
Stream<String?> _userIdStream(AuthRepository repository) async* {
  yield repository.currentUserId;
  yield* repository.userIdChanges;
}

/// The current user id, or null when signed out.
@Riverpod(keepAlive: true)
Stream<String?> authUserId(Ref<AsyncValue<String?>> ref) =>
    _userIdStream(ref.watch(authRepositoryProvider)).distinct();

/// Resolves the signed-in user into a [SessionState] the router can act on.
///
/// While this is loading the router holds the user on the splash screen, so no
/// screen is ever shown to the wrong role even for a frame.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<SessionState> build() async {
    final userId = await ref.watch(authUserIdProvider.future);

    if (userId == null) {
      return const SessionSignedOut();
    }

    final result = await ref.watch(authRepositoryProvider).fetchProfile(userId);

    return result.fold(
      onSuccess: SessionSignedIn.new,
      onFailure: (failure) => throw failure,
    );
  }

  /// Re-reads the profile from the server.
  ///
  /// Used by the pending screen so a dealer can check whether the owner has
  /// approved them without restarting the app, and after a failed load.
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}
