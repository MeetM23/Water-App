import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/models/business_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_settings_repository.g.dart';

/// Supabase-backed business settings.
///
/// The table holds exactly one row, pinned by a boolean primary key, so both
/// operations here address `id = true` rather than carrying an identifier
/// around the app.
class SupabaseSettingsRepository implements SettingsRepository {
  /// Creates a repository over an initialised client.
  SupabaseSettingsRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'business_settings';

  @override
  Future<Result<BusinessSettings>> fetch() async {
    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', true)
          .maybeSingle();
      if (row == null) {
        // The seed row is created by the migration. Its absence means the
        // migration has not run, which is a deployment fault, not a state the
        // owner can fix from the app.
        return const ResultFailure<BusinessSettings>(ServerFailure());
      }
      return Success<BusinessSettings>(BusinessSettings.fromJson(row));
    } on Object catch (error, stackTrace) {
      return ResultFailure<BusinessSettings>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<BusinessSettings>> save(BusinessSettings settings) async {
    try {
      final row = await _client
          .from(_table)
          .update(<String, dynamic>{
            'business_name': settings.businessName.trim(),
            'phone': settings.phone.trim(),
            'address': settings.address.trim(),
          })
          .eq('id', true)
          .select()
          .single();
      return Success<BusinessSettings>(BusinessSettings.fromJson(row));
    } on Object catch (error, stackTrace) {
      return ResultFailure<BusinessSettings>(_map(error, stackTrace));
    }
  }

  AppFailure _map(Object error, StackTrace stackTrace) {
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is PostgrestException) {
      if (error.code == '42501') {
        return PermissionFailure(cause: error, stackTrace: stackTrace);
      }
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    AppLog.error('Unmapped settings repository error', error, stackTrace);
    return UnexpectedFailure(cause: error, stackTrace: stackTrace);
  }
}

/// The application-wide [SettingsRepository].
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref<SettingsRepository> ref) =>
    SupabaseSettingsRepository(ref.watch(supabaseClientProvider));
