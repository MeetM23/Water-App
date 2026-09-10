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
      final cleanSerial = serialNumber.trim();
      if (cleanSerial.isEmpty) {
        return const Success<ProductUnit?>(null);
      }

      final response = await _client.rpc<dynamic>(
        'lookup_unit_by_serial',
        params: <String, dynamic>{'p_serial': cleanSerial},
      );

      if (response != null) {
        final data = Map<String, dynamic>.from(response as Map);
        return Success<ProductUnit?>(ProductUnit.fromJson(data));
      }

      // Fallback: If not found in physical product_units by unit serial,
      // check if cleanSerial is a Product Code (e.g. MWS-DOM-001006-3) in catalog_view
      final productRow = await _client
          .from('catalog_view')
          .select()
          .ilike('product_code', cleanSerial)
          .maybeSingle();

      if (productRow != null) {
        final productId = productRow['id'] as String;

        // Check if a unit record already exists in product_units for this product
        final existingUnit = await _client
            .from('product_units')
            .select('*, unit_registrations(*)')
            .eq('product_id', productId)
            .ilike('serial_number', cleanSerial)
            .maybeSingle();

        if (existingUnit != null) {
          final regList = existingUnit['unit_registrations'] as List?;
          final regMap = (regList != null && regList.isNotEmpty)
              ? Map<String, dynamic>.from(regList.first as Map)
              : null;

          final combined = <String, dynamic>{
            'unit_id': existingUnit['id'],
            'serial_number': existingUnit['serial_number'],
            'manufactured_at': existingUnit['manufactured_at'],
            'product_id': productId,
            'product_name': productRow['name'],
            'model_number': productRow['model_number'],
            'category': productRow['category'],
            'description': productRow['description'],
            'default_warranty_months': productRow['warranty_months'] ?? 12,
            'registration': regMap,
          };
          return Success<ProductUnit?>(ProductUnit.fromJson(combined));
        }

        // If no unit record exists yet in product_units, create one on the fly
        try {
          final newUnit = await _client
              .from('product_units')
              .insert({
                'product_id': productId,
                'serial_number': cleanSerial.toUpperCase(),
              })
              .select()
              .single();

          final combined = <String, dynamic>{
            'unit_id': newUnit['id'],
            'serial_number': newUnit['serial_number'],
            'manufactured_at': newUnit['manufactured_at'],
            'product_id': productId,
            'product_name': productRow['name'],
            'model_number': productRow['model_number'],
            'category': productRow['category'],
            'description': productRow['description'],
            'default_warranty_months': productRow['warranty_months'] ?? 12,
            'registration': null,
          };
          return Success<ProductUnit?>(ProductUnit.fromJson(combined));
        } catch (insertError, st) {
          AppLog.warn('Could not auto-create unit record, using virtual unit', insertError, st);
          final combined = <String, dynamic>{
            'unit_id': productId,
            'serial_number': cleanSerial.toUpperCase(),
            'manufactured_at': DateTime.now().toIso8601String(),
            'product_id': productId,
            'product_name': productRow['name'],
            'model_number': productRow['model_number'],
            'category': productRow['category'],
            'description': productRow['description'],
            'default_warranty_months': productRow['warranty_months'] ?? 12,
            'registration': null,
          };
          return Success<ProductUnit?>(ProductUnit.fromJson(combined));
        }
      }

      return const Success<ProductUnit?>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<ProductUnit?>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<UnitRegistrationInfo>> registerUnit({
    required String unitId,
    required String customerName,
    required String customerPhone,
    required DateTime purchaseDate,
    required DateTime installationDate,
    required int warrantyMonths,
    String? customerCity,
    String? customerAddress,
    String? invoiceNumber,
    String? registeredRole,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final warrantyStartDate = installationDate;
      final warrantyEndDate = DateTime(
        installationDate.year,
        installationDate.month + warrantyMonths,
        installationDate.day,
      );

      final insertData = <String, dynamic>{
        'unit_id': unitId,
        'registered_by': userId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_city': customerCity,
        'customer_address': customerAddress,
        'purchase_date': purchaseDate.toIso8601String().substring(0, 10),
        'installation_date': installationDate.toIso8601String().substring(0, 10),
        'warranty_start_date': warrantyStartDate.toIso8601String().substring(0, 10),
        'warranty_months': warrantyMonths,
        'invoice_number': invoiceNumber,
      };

      if (registeredRole != null) {
        insertData['registered_role'] = registeredRole;
      }

      final response = await _client
          .from('unit_registrations')
          .insert(insertData)
          .select()
          .single();

      final regMap = Map<String, dynamic>.from(response);
      regMap['warranty_end_date'] =
          warrantyEndDate.toIso8601String().substring(0, 10);

      return Success<UnitRegistrationInfo>(
          UnitRegistrationInfo.fromJson(regMap));
    } on Object catch (error, stackTrace) {
      return ResultFailure<UnitRegistrationInfo>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<ProductUnit>>> fetchRegistrations({String? userId}) async {
    try {
      var query = _client.from('unit_registrations').select();
      if (userId != null && userId.isNotEmpty) {
        query = query.eq('registered_by', userId);
      }

      final rows = await query.order('created_at', ascending: false);
      final units = <ProductUnit>[];

      for (final row in rows as List) {
        final regMap = Map<String, dynamic>.from(row as Map);
        final unitId = regMap['unit_id'] as String;

        final unitRow = await _client
            .from('product_units')
            .select('*, products(*)')
            .eq('id', unitId)
            .maybeSingle();

        if (unitRow != null) {
          final prod = unitRow['products'] as Map<String, dynamic>?;
          final combined = <String, dynamic>{
            'unit_id': unitRow['id'],
            'serial_number': unitRow['serial_number'],
            'manufactured_at': unitRow['manufactured_at'],
            'product_id': unitRow['product_id'],
            'product_name': prod?['name'] ?? 'Purifier Machine',
            'model_number': prod?['model_number'],
            'category': prod?['category'] ?? 'domestic',
            'default_warranty_months': prod?['warranty_months'] ?? 12,
            'registration': regMap,
          };
          units.add(ProductUnit.fromJson(combined));
        }
      }

      return Success<List<ProductUnit>>(units);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<ProductUnit>>(_map(error, stackTrace));
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
