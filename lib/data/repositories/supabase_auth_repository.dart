import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/sign_up_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_auth_repository.g.dart';

/// Supabase-backed implementation of [AuthRepository].
///
/// Every driver exception is translated into an [AppFailure] here, so nothing
/// above this class ever sees an [AuthException] or a [PostgrestException].
class SupabaseAuthRepository implements AuthRepository {
  /// Creates a repository over an initialised [SupabaseClient].
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentSession?.user.id;

  @override
  Stream<String?> get userIdChanges => _client.auth.onAuthStateChange.transform(
    StreamTransformer<AuthState, String?>.fromHandlers(
      handleData: (AuthState state, EventSink<String?> sink) =>
          sink.add(state.session?.user.id),
      handleError:
          (Object error, StackTrace stackTrace, EventSink<String?> sink) {
            // A failed token refresh arrives here. Treat it as a sign-out so
            // the router sends the user to login rather than leaving them on a
            // screen whose queries will all fail.
            AppLog.warn(
              'Authentication stream failed; treating session as ended',
              error,
              stackTrace,
            );
            unawaited(_client.auth.signOut());
            sink.add(null);
          },
    ),
  );

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_mapError(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> signUp(SignUpRequest request) async {
    try {
      await _client.auth.signUp(
        email: request.email.trim(),
        password: request.password,
        data: request.toUserMetadata(),
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_mapError(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      // A sign-out that fails on the server has still cleared the local
      // session, so the user is out either way; report it and move on.
      AppLog.warn('Sign-out did not complete cleanly', error, stackTrace);
      return const Success<void>(null);
    }
  }

  @override
  Future<Result<void>> changePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_mapError(error, stackTrace));
    }
  }

  @override
  Future<Result<Profile>> fetchProfile(String userId) async {
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (row == null) {
        return const ResultFailure<Profile>(
          AuthFailure(AuthFailureReason.missingProfile),
        );
      }

      return Success<Profile>(Profile.fromJson(row));
    } on Object catch (error, stackTrace) {
      return ResultFailure<Profile>(_mapError(error, stackTrace));
    }
  }

  AppFailure _mapError(Object error, StackTrace stackTrace) {
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }

    if (error is AuthException) {
      return AuthFailure(
        reasonFor(error),
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is PostgrestException) {
      // 42501 is the SQL state raised by the RLS policies and by every owner
      // assertion inside the dealer administration functions.
      if (error.code == '42501') {
        return PermissionFailure(cause: error, stackTrace: stackTrace);
      }
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }

    AppLog.error('Unmapped repository error', error, stackTrace);
    return UnexpectedFailure(cause: error, stackTrace: stackTrace);
  }

  /// Classifies a GoTrue error into the reason the UI shows.
  ///
  /// Static and visible for testing: it reads nothing but the exception, and
  /// the alternative is standing up a whole [SupabaseClient] to exercise a
  /// pure branch.
  @visibleForTesting
  static AuthFailureReason reasonFor(AuthException error) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return AuthFailureReason.invalidCredentials;
    }
    if (code == 'user_already_exists' ||
        code == 'email_exists' ||
        message.contains('already registered')) {
      return AuthFailureReason.emailAlreadyRegistered;
    }
    if (code == 'weak_password' || message.contains('password should be')) {
      return AuthFailureReason.weakPassword;
    }
    // Every 429 from GoTrue: `over_email_send_rate_limit` when a project's
    // mail quota is spent, `over_request_rate_limit` otherwise. Without this
    // branch both fell through to `unknown`, which renders as "Something
    // went wrong" -- a message that names neither the cause nor the one
    // detail that makes it solvable, which is that waiting fixes it.
    if (code.startsWith('over_') && code.endsWith('_rate_limit') ||
        error.statusCode == '429' ||
        message.contains('rate limit')) {
      return AuthFailureReason.rateLimited;
    }
    if (code == 'session_expired' ||
        code == 'refresh_token_not_found' ||
        message.contains('jwt expired')) {
      return AuthFailureReason.sessionExpired;
    }
    return AuthFailureReason.unknown;
  }
}

/// The application-wide [AuthRepository].
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref<AuthRepository> ref) =>
    SupabaseAuthRepository(ref.watch(supabaseClientProvider));
