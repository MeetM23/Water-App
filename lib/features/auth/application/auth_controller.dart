import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../data/repositories/supabase_auth_repository.dart';
import '../../../domain/models/sign_up_request.dart';
import 'session_controller.dart';

part 'auth_controller.g.dart';

/// Drives the sign-in, sign-up and sign-out forms.
///
/// The controller owns the in-flight flag that disables submit buttons, which
/// is what makes a double submit impossible: the second tap arrives while
/// `state.isLoading` is true and the button is already disabled.
///
/// Each action returns the [AppFailure] to show, or null on success. Routing
/// after a successful sign-in is not done here: the session stream updates and
/// the router redirect reacts to it.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  /// Signs in with email and password.
  Future<AppFailure?> signIn({
    required String email,
    required String password,
  }) async {
    final failure = await _run(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );

    if (failure != null) {
      return failure;
    }

    try {
      await ref.read(sessionControllerProvider.notifier).reload();
      return null;
    } on AppFailure catch (e) {
      return e;
    } catch (e, st) {
      return UnexpectedFailure(cause: e, stackTrace: st);
    }
  }

  /// Registers a new dealer.
  Future<AppFailure?> signUp(SignUpRequest request) =>
      _run(() => ref.read(authRepositoryProvider).signUp(request));

  /// Ends the session.
  Future<AppFailure?> signOut() =>
      _run(() => ref.read(authRepositoryProvider).signOut());

  Future<AppFailure?> _run(Future<Result<void>> Function() action) async {
    if (state.isLoading) {
      return null;
    }

    state = const AsyncValue<void>.loading();
    final result = await action();

    return result.fold(
      onSuccess: (_) {
        try {
          state = const AsyncValue<void>.data(null);
        } catch (_) {}
        return null;
      },
      onFailure: (failure) {
        try {
          state = AsyncValue<void>.error(
            failure,
            failure.stackTrace ?? StackTrace.current,
          );
        } catch (_) {}
        return failure;
      },
    );
  }
}
