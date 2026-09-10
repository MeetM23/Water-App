import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/models/product_unit.dart';
import '../../domain/repositories/unit_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_unit_repository.g.dart';

/// Communication layer with Supabase for physical unit lookup and warranty management.
class SupabaseUnitRepository implements UnitRepository {
  /// Creates a repository over an initialised client.
  SupabaseUnitRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<ProductUnit?>> findUnitBySerial(String serialNumber) async {
    try {
      final response = await _client.rpc<dynamic>(
        'lookup_unit_by_serial',
        params: <String, dynamic>{'p_serial': serialNumber},
      );

      if (response == null) {
        return const Success<ProductUnit?>(null);
      }

      final data = Map<String, dynamic>.from(response as Map);
      return Success<ProductUnit?>(ProductUnit.fromJson(data));
    } on Object catch (error, stackTrace) {
      return ResultFailure<ProductUnit?>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<String>>> batchGenerateUnits({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _client.rpc<dynamic>(
        'batch_generate_product_units',
        params: <String, dynamic>{
          'p_product_id': productId,
          'p_quantity': quantity,
        },
      );

      final list = (response as List)
          .map((dynamic item) => (item as Map)['serial_number'] as String)
          .toList();

      return Success<List<String>>(list);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<String>>(_map(error, stackTrace));
    }
  }

  AppFailure _map(Object error, StackTrace stackTrace) {
    AppLog.error('Unit repository operation failed', error, stackTrace);
    if (error is PostgrestException) {
      if (error.code == '42501' || error.code == 'P0001') {
        return PermissionFailure(cause: error, stackTrace: stackTrace);
      }
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    return UnexpectedFailure(cause: error, stackTrace: stackTrace);
  }
}

/// The application-wide [UnitRepository].
@Riverpod(keepAlive: true)
UnitRepository unitRepository(Ref<UnitRepository> ref) =>
    SupabaseUnitRepository(ref.watch(supabaseClientProvider));
