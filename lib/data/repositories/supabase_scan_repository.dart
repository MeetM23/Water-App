import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/scan_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_scan_repository.g.dart';

/// Writes scan telemetry to `scan_events`.
///
/// `scanned_by` is set from the client but the RLS policy pins it to
/// `auth.uid()` regardless, so a forged attribution is rejected by the
/// database rather than trusted from here.
class SupabaseScanRepository implements ScanRepository {
  /// Creates a repository over an initialised client.
  SupabaseScanRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<void>> logScan({
    required String productId,
    required ScanSource source,
    required UserRole role,
  }) async {
    try {
      await _client.from('scan_events').insert(<String, dynamic>{
        'product_id': productId,
        'scanned_by': _client.auth.currentUser?.id,
        'scanned_role': role.name,
        'source': source.name,
      });
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      // Logged, never surfaced. A dealer holding a phone at a barcode must not
      // be told the scan failed because the telemetry insert did.
      AppLog.warn('Could not record a scan event', error, stackTrace);
      if (error is SocketException || error is HttpException) {
        return ResultFailure<void>(
          NetworkFailure(cause: error, stackTrace: stackTrace),
        );
      }
      return ResultFailure<void>(
        UnexpectedFailure(cause: error, stackTrace: stackTrace),
      );
    }
  }
}

/// The application-wide [ScanRepository].
@Riverpod(keepAlive: true)
ScanRepository scanRepository(Ref<ScanRepository> ref) =>
    SupabaseScanRepository(ref.watch(supabaseClientProvider));
