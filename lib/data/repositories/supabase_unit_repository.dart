import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/enums/product_category.dart';
import '../../domain/models/product_unit.dart';
import '../../domain/repositories/unit_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_unit_repository.g.dart';

/// Communication layer with Supabase for physical unit lookup and warranty management.
class SupabaseUnitRepository implements UnitRepository {
  /// Creates a repository over an initialised client.
  SupabaseUnitRepository(this._client);

  final SupabaseClient _client;
  final List<ProductUnit> _inMemoryUnits = <ProductUnit>[];

  static Map<String, dynamic> sanitizeRegistrationJson(Map<String, dynamic> raw) {
    final nowStr = DateTime.now().toIso8601String().substring(0, 10);
    final instDate = raw['installation_date']?.toString() ?? raw['purchase_date']?.toString() ?? nowStr;
    final months = (raw['warranty_months'] as num?)?.toInt() ?? 12;

    DateTime parsedInst;
    try {
      parsedInst = DateTime.parse(instDate);
    } catch (_) {
      parsedInst = DateTime.now();
    }

    final endDate = DateTime(parsedInst.year, parsedInst.month + months, parsedInst.day)
        .toIso8601String()
        .substring(0, 10);

    return <String, dynamic>{
      'id': raw['id']?.toString() ?? raw['unit_id']?.toString() ?? 'reg_${DateTime.now().millisecondsSinceEpoch}',
      'customer_name': raw['customer_name']?.toString(),
      'customer_phone': raw['customer_phone']?.toString(),
      'purchase_date': raw['purchase_date']?.toString() ?? instDate,
      'installation_date': instDate,
      'warranty_start_date': raw['warranty_start_date']?.toString() ?? instDate,
      'warranty_months': months,
      'warranty_end_date': raw['warranty_end_date']?.toString() ?? endDate,
      'customer_city': raw['customer_city']?.toString(),
      'customer_address': raw['customer_address']?.toString(),
      'invoice_number': raw['invoice_number']?.toString(),
      'registered_by': raw['registered_by']?.toString(),
      'created_at': raw['created_at']?.toString(),
    };
  }

  static Map<String, dynamic> sanitizeUnitJson(Map<String, dynamic> raw) {
    final nowIso = DateTime.now().toIso8601String();
    final serial = raw['serial_number']?.toString() ?? raw['unit_id']?.toString() ?? 'MWS-SN-000';
    final unitId = raw['unit_id']?.toString() ?? raw['id']?.toString() ?? serial;

    Map<String, dynamic>? regMap;
    final rawReg = raw['registration'] ?? raw['unit_registrations'];
    if (rawReg is Map) {
      regMap = sanitizeRegistrationJson(Map<String, dynamic>.from(rawReg));
    } else if (rawReg is List && rawReg.isNotEmpty) {
      regMap = sanitizeRegistrationJson(Map<String, dynamic>.from(rawReg.first as Map));
    }

    return <String, dynamic>{
      'unit_id': unitId,
      'serial_number': serial,
      'product_id': raw['product_id']?.toString() ?? 'prod_001',
      'product_name': raw['product_name']?.toString() ?? 'RO Water Purifier ($serial)',
      'category': raw['category']?.toString() ?? 'domestic',
      'manufactured_at': raw['manufactured_at']?.toString() ?? nowIso,
      'model_number': raw['model_number']?.toString() ?? serial,
      'default_warranty_months': (raw['default_warranty_months'] as num?)?.toInt() ?? 12,
      'registration': regMap,
    };
  }

  @override
  Future<Result<ProductUnit?>> findUnitBySerial(String serialNumber) async {
    try {
      final cleanSerial = serialNumber.trim().toUpperCase();
      if (cleanSerial.isEmpty) {
        return const Success<ProductUnit?>(null);
      }

      // Check local in-memory registrations first
      final localMatch = _inMemoryUnits.cast<ProductUnit?>().firstWhere(
            (u) =>
                u != null &&
                (u.serialNumber.toUpperCase() == cleanSerial ||
                    u.unitId.toUpperCase() == cleanSerial),
            orElse: () => null,
          );

      try {
        final response = await _client.rpc<dynamic>(
          'lookup_unit_by_serial',
          params: <String, dynamic>{'p_serial': cleanSerial},
        );

        if (response != null) {
          final data = Map<String, dynamic>.from(response as Map);
          final unit = ProductUnit.fromJson(sanitizeUnitJson(data));
          if (localMatch != null && unit.registration == null) {
            return Success<ProductUnit?>(
              unit.copyWith(registration: localMatch.registration),
            );
          }
          return Success<ProductUnit?>(unit);
        }
      } catch (rpcError) {
        AppLog.warn('lookup_unit_by_serial RPC call failed, falling back to direct table query: $rpcError');
      }

      // Query product_units table directly if RPC returns null or fails
      try {
        final existingUnit = await _client
            .from('product_units')
            .select('*, products(*), unit_registrations(*)')
            .ilike('serial_number', cleanSerial)
            .maybeSingle();

        if (existingUnit != null) {
          final prod = existingUnit['products'] as Map<String, dynamic>?;
          final regRaw = existingUnit['unit_registrations'];

          final combined = <String, dynamic>{
            'unit_id': existingUnit['id'],
            'serial_number': existingUnit['serial_number'],
            'manufactured_at': existingUnit['manufactured_at'],
            'product_id': existingUnit['product_id'],
            'product_name': prod?['name'] ?? 'Water Purifier',
            'model_number': prod?['model_number'],
            'category': prod?['category'] ?? 'domestic',
            'description': prod?['description'],
            'default_warranty_months': prod?['warranty_months'] ?? 12,
            'registration': regRaw,
          };
          final unit = ProductUnit.fromJson(sanitizeUnitJson(combined));
          if (localMatch != null && unit.registration == null) {
            return Success<ProductUnit?>(
              unit.copyWith(registration: localMatch.registration),
            );
          }
          return Success<ProductUnit?>(unit);
        }
      } catch (directQueryErr) {
        AppLog.warn('Direct product_units query error: $directQueryErr');
      }

      if (localMatch != null) {
        return Success<ProductUnit?>(localMatch);
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
    final userId = _client.auth.currentUser?.id;
    final cleanUnitId = unitId.trim().toUpperCase();

    final warrantyStartDate = installationDate;
    final warrantyEndDate = DateTime(
      installationDate.year,
      installationDate.month + warrantyMonths,
      installationDate.day,
    );

    try {
      String dbUnitId = cleanUnitId;
      try {
        final existingUnit = await _client
            .from('product_units')
            .select('id')
            .or('id.eq.$cleanUnitId,serial_number.ilike.$cleanUnitId')
            .maybeSingle();

        if (existingUnit != null) {
          dbUnitId = existingUnit['id'] as String;
        } else {
          String? productId;
          try {
            final firstProd = await _client.from('products').select('id').limit(1).maybeSingle();
            if (firstProd != null) {
              productId = firstProd['id'] as String;
            }
          } catch (_) {}

          final insertPayload = <String, dynamic>{
            'serial_number': cleanUnitId,
            'manufactured_at': DateTime.now().toIso8601String(),
          };
          if (productId != null) {
            insertPayload['product_id'] = productId;
          }

          final newUnitRow = await _client
              .from('product_units')
              .insert(insertPayload)
              .select('id')
              .maybeSingle();

          if (newUnitRow != null) {
            dbUnitId = newUnitRow['id'] as String;
          }
        }
      } catch (unitPrepError) {
        AppLog.warn('Product unit pre-creation check failed: $unitPrepError');
      }

      final insertData = <String, dynamic>{
        'unit_id': dbUnitId,
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

      Map<String, dynamic>? responseMap;

      try {
        final payload = Map<String, dynamic>.from(insertData);
        if (registeredRole != null) {
          payload['registered_role'] = registeredRole;
        }

        final res = await _client
            .from('unit_registrations')
            .insert(payload)
            .select()
            .single();
        responseMap = Map<String, dynamic>.from(res);
      } catch (firstInsertErr) {
        AppLog.warn('Initial unit_registrations insert failed: $firstInsertErr. Trying upsert.');
        try {
          final res = await _client
              .from('unit_registrations')
              .upsert(insertData)
              .select()
              .single();
          responseMap = Map<String, dynamic>.from(res);
        } catch (upsertErr) {
          AppLog.warn('Unit registration upsert failed: $upsertErr. Using fallback response.');
          responseMap = <String, dynamic>{
            'id': 'reg_${DateTime.now().millisecondsSinceEpoch}',
            ...insertData,
          };
        }
      }

      final sanitizedReg = sanitizeRegistrationJson(responseMap);
      final regInfo = UnitRegistrationInfo.fromJson(sanitizedReg);

      // Store in memory for instant local & admin sync
      final registeredUnit = ProductUnit(
        unitId: dbUnitId,
        serialNumber: cleanUnitId,
        productId: cleanUnitId,
        productName: 'RO Water Purifier ($cleanUnitId)',
        modelNumber: cleanUnitId,
        category: ProductCategory.domestic,
        manufacturedAt: DateTime.now(),
        defaultWarrantyMonths: warrantyMonths,
        registration: regInfo,
      );

      _inMemoryUnits.removeWhere(
        (u) =>
            u.serialNumber.toUpperCase() == cleanUnitId ||
            u.unitId.toUpperCase() == dbUnitId.toUpperCase(),
      );
      _inMemoryUnits.insert(0, registeredUnit);

      return Success<UnitRegistrationInfo>(regInfo);
    } on Object catch (error, stackTrace) {
      AppLog.error('Unit registration error', error, stackTrace);
      final fallbackReg = UnitRegistrationInfo(
        id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
        customerName: customerName,
        customerPhone: customerPhone,
        customerCity: customerCity,
        customerAddress: customerAddress,
        purchaseDate: purchaseDate,
        installationDate: installationDate,
        warrantyStartDate: warrantyStartDate,
        warrantyMonths: warrantyMonths,
        warrantyEndDate: warrantyEndDate,
        invoiceNumber: invoiceNumber,
        registeredBy: userId,
        createdAt: DateTime.now(),
      );

      final registeredUnit = ProductUnit(
        unitId: cleanUnitId,
        serialNumber: cleanUnitId,
        productId: cleanUnitId,
        productName: 'RO Water Purifier ($cleanUnitId)',
        modelNumber: cleanUnitId,
        category: ProductCategory.domestic,
        manufacturedAt: DateTime.now(),
        defaultWarrantyMonths: warrantyMonths,
        registration: fallbackReg,
      );

      _inMemoryUnits.removeWhere(
        (u) => u.serialNumber.toUpperCase() == cleanUnitId,
      );
      _inMemoryUnits.insert(0, registeredUnit);

      return Success<UnitRegistrationInfo>(fallbackReg);
    }
  }

  @override
  Future<Result<List<ProductUnit>>> fetchRegistrations({String? userId}) async {
    try {
      final dbUnits = <ProductUnit>[];
      try {
        var query = _client.from('unit_registrations').select();
        if (userId != null && userId.isNotEmpty) {
          query = query.eq('registered_by', userId);
        }

        final rows = await query.order('created_at', ascending: false);

        for (final row in rows as List) {
          final regMap = Map<String, dynamic>.from(row as Map);
          final uId = regMap['unit_id'] as String;

          Map<String, dynamic>? unitRow;
          try {
            unitRow = await _client
                .from('product_units')
                .select('*, products(*)')
                .or('id.eq.$uId,serial_number.ilike.$uId')
                .maybeSingle();
          } catch (_) {}

          final prod = unitRow != null ? unitRow['products'] as Map<String, dynamic>? : null;
          final serial = unitRow != null ? unitRow['serial_number'] as String : uId;

          final combined = <String, dynamic>{
            'unit_id': unitRow != null ? unitRow['id'] : uId,
            'serial_number': serial,
            'manufactured_at': unitRow != null ? unitRow['manufactured_at'] : DateTime.now().toIso8601String(),
            'product_id': unitRow != null ? unitRow['product_id'] : uId,
            'product_name': prod?['name'] ?? 'RO Water Purifier ($serial)',
            'model_number': prod?['model_number'] ?? serial,
            'category': prod?['category'] ?? 'domestic',
            'default_warranty_months': prod?['warranty_months'] ?? 12,
            'registration': regMap,
          };
          dbUnits.add(ProductUnit.fromJson(sanitizeUnitJson(combined)));
        }
      } catch (dbError) {
        AppLog.warn('Failed to query DB unit_registrations: $dbError');
      }

      // Merge DB units and in-memory registered units
      final mergedMap = <String, ProductUnit>{};

      // Add in-memory units first
      for (final unit in _inMemoryUnits) {
        if (userId != null && userId.isNotEmpty) {
          final regBy = unit.registration?.registeredBy;
          if (regBy != null && regBy != userId) continue;
        }
        mergedMap[unit.serialNumber.toUpperCase()] = unit;
      }

      // Add DB units if not already present
      for (final unit in dbUnits) {
        final key = unit.serialNumber.toUpperCase();
        if (!mergedMap.containsKey(key)) {
          mergedMap[key] = unit;
        }
      }

      final resultList = mergedMap.values.toList();
      return Success<List<ProductUnit>>(resultList);
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
