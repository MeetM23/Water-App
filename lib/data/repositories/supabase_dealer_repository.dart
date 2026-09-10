import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/enums/account_status.dart';
import '../../domain/enums/dealer_segment.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/models/dealer_activity.dart';
import '../../domain/models/dealer_query.dart';
import '../../domain/models/profile.dart';
import '../../domain/repositories/dealer_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_dealer_repository.g.dart';

/// Supabase-backed dealer administration.
///
/// Every mutation is an RPC that re-asserts `is_owner()` inside the database
/// and raises 42501 otherwise. The app's role check decides what to draw; the
/// database decides what is permitted.
class SupabaseDealerRepository implements DealerRepository {
  /// Creates a repository over an initialised client.
  SupabaseDealerRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<Profile>>> fetchByStatus(AccountStatus status) async {
    try {
      final rows = await _client
          .from('profiles')
          .select()
          .eq('status', status.name)
          .neq('role', UserRole.owner.name)
          .order('created_at', ascending: false);
      return Success<List<Profile>>(rows.map(Profile.fromJson).toList());
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<Profile>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<Profile>>> search(DealerQuery query) async {
    try {
      var filter = _client
          .from('profiles')
          .select()
          .eq('status', query.segment.status.name)
          .neq('role', UserRole.owner.name);

      final role = query.segment.role;
      if (role != null) {
        filter = filter.eq('role', role.name);
      }

      final term = _escapeForOrFilter(query.searchTerm.trim());
      if (term.isNotEmpty) {
        filter = filter.or(
          'firm_name.ilike.%$term%,'
          'full_name.ilike.%$term%,'
          'phone.ilike.%$term%,'
          'city.ilike.%$term%',
        );
      }

      final rows = await filter.order('firm_name');
      return Success<List<Profile>>(rows.map(Profile.fromJson).toList());
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<Profile>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Profile>> fetchById(String userId) async {
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (row == null) {
        return const ResultFailure<Profile>(ServerFailure());
      }
      return Success<Profile>(Profile.fromJson(row));
    } on Object catch (error, stackTrace) {
      return ResultFailure<Profile>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<DealerCounts>> counts() async {
    try {
      final rows = await _client.rpc<List<dynamic>>('dealer_counts');
      if (rows.isEmpty) {
        return const Success<DealerCounts>(DealerCounts.zero);
      }
      final row = rows.first as Map<String, dynamic>;
      return Success<DealerCounts>(
        DealerCounts(
          pending: (row['pending'] as num?)?.toInt() ?? 0,
          wholesalers: (row['wholesalers'] as num?)?.toInt() ?? 0,
          retailers: (row['retailers'] as num?)?.toInt() ?? 0,
          suspended: (row['suspended'] as num?)?.toInt() ?? 0,
        ),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure<DealerCounts>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<DealerActivity>> activity(String userId) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'dealer_activity',
        params: <String, dynamic>{'p_user': userId},
      );
      if (rows.isEmpty) {
        return const Success<DealerActivity>(DealerActivity(totalScans: 0));
      }
      final row = rows.first as Map<String, dynamic>;
      final lastActive = row['last_active'] as String?;
      return Success<DealerActivity>(
        DealerActivity(
          totalScans: (row['total_scans'] as num?)?.toInt() ?? 0,
          lastActive: lastActive == null ? null : DateTime.parse(lastActive),
        ),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure<DealerActivity>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<DealerActivityEntry>>> recentActivity({
    int limit = 8,
  }) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'recent_dealer_activity',
        params: <String, dynamic>{'p_limit': limit},
      );
      return Success<List<DealerActivityEntry>>(<DealerActivityEntry>[
        for (final row in rows.cast<Map<String, dynamic>>())
          DealerActivityEntry(
            id: row['id'] as String,
            action: row['action'] as String,
            firmName: (row['firm_name'] as String?) ?? '',
            fullName: (row['full_name'] as String?) ?? '',
            createdAt: DateTime.parse(row['created_at'] as String),
          ),
      ]);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<DealerActivityEntry>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<String>> emailFor(String userId) async {
    try {
      final email = await _client.rpc<String>(
        'dealer_email',
        params: <String, dynamic>{'p_user': userId},
      );
      return Success<String>(email);
    } on Object catch (error, stackTrace) {
      return ResultFailure<String>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<int>> pendingCount() async {
    try {
      final response = await _client
          .from('profiles')
          .select('id')
          .eq('status', AccountStatus.pending.name)
          .neq('role', UserRole.owner.name)
          .count(CountOption.exact);
      return Success<int>(response.count);
    } on Object catch (error, stackTrace) {
      return ResultFailure<int>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Profile>> approve(String userId, UserRole role) => _rpc(
    'approve_dealer',
    <String, dynamic>{'p_user': userId, 'p_role': role.name},
  );

  @override
  Future<Result<Profile>> reject(String userId, String reason) => _rpc(
    'reject_dealer',
    <String, dynamic>{'p_user': userId, 'p_reason': reason},
  );

  @override
  Future<Result<Profile>> setRole(String userId, UserRole role) => _rpc(
    'set_dealer_role',
    <String, dynamic>{'p_user': userId, 'p_role': role.name},
  );

  @override
  Future<Result<Profile>> suspend(String userId) =>
      _rpc('suspend_dealer', <String, dynamic>{'p_user': userId});

  @override
  Future<Result<Profile>> reactivate(String userId) =>
      _rpc('reactivate_dealer', <String, dynamic>{'p_user': userId});

  Future<Result<Profile>> _rpc(String name, Map<String, dynamic> params) async {
    try {
      final row = await _client.rpc<Map<String, dynamic>>(name, params: params);
      return Success<Profile>(Profile.fromJson(row));
    } on Object catch (error, stackTrace) {
      return ResultFailure<Profile>(_map(error, stackTrace));
    }
  }

  /// Strips the characters PostgREST treats as structure inside an `or`
  /// filter, so a firm name containing a comma cannot be parsed as extra
  /// filter clauses.
  static String _escapeForOrFilter(String term) =>
      term.replaceAll(RegExp(r'[,()%\\]'), ' ').trim();

  AppFailure _map(Object error, StackTrace stackTrace) {
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is PostgrestException) {
      // 42501 is what the owner assertion inside each RPC raises.
      if (error.code == '42501') {
        return PermissionFailure(cause: error, stackTrace: stackTrace);
      }
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    AppLog.error('Unmapped dealer repository error', error, stackTrace);
    return UnexpectedFailure(cause: error, stackTrace: stackTrace);
  }
}

/// The application-wide [DealerRepository].
@Riverpod(keepAlive: true)
DealerRepository dealerRepository(Ref<DealerRepository> ref) =>
    SupabaseDealerRepository(ref.watch(supabaseClientProvider));
