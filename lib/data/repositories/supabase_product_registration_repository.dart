import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/models/product_lookup.dart';
import '../../domain/repositories/product_registration_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_product_registration_repository.g.dart';

/// Communication layer with Supabase for product warranty registrations and product lookup.
class SupabaseProductRegistrationRepository implements ProductRegistrationRepository {
  /// Creates a repository over an initialised client.
  SupabaseProductRegistrationRepository(this._client);

  final SupabaseClient _client;
  final Set<String> _deletedRegistrationIds = <String>{};

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
      'seller_name': raw['seller_name']?.toString() ?? raw['dealer_name']?.toString(),
      'seller_phone': raw['seller_phone']?.toString() ?? raw['dealer_phone']?.toString(),
      'registered_by': raw['registered_by']?.toString(),
      'created_at': raw['created_at']?.toString(),
    };
  }

  static bool isUuidString(String str) {
    return RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(str.trim());
  }

  static String buildProductFilter(String input) {
    final clean = input.trim();
    if (isUuidString(clean)) {
      return 'id.eq.$clean,product_code.eq.$clean,model_number.eq.$clean';
    }
    return 'product_code.eq.$clean,model_number.eq.$clean';
  }

  static String buildRegFilter(String input) {
    final clean = input.trim();
    return isUuidString(clean)
        ? 'id.eq.$clean,unit_id.eq.$clean'
        : 'unit_id.eq.$clean';
  }

  static String detectCategoryFromSerial(String serial, {String? defaultCategory, String? productName}) {
    if (defaultCategory != null && defaultCategory.isNotEmpty) {
      return defaultCategory.toLowerCase();
    }
    if (productName != null && productName.isNotEmpty) {
      final pUpper = productName.toUpperCase();
      if (pUpper.contains('PUMP') || pUpper.contains('ACCESSORY') || pUpper.contains('ACCESSORIES') || pUpper.contains('ADAPTER') || pUpper.contains('SMPS') || pUpper.contains('TWISTER')) {
        return 'accessory';
      }
      if (pUpper.contains('SPARE') || pUpper.contains('FILTER') || pUpper.contains('MEMBRANE') || pUpper.contains('CARTRIDGE') || pUpper.contains('FITTING')) {
        return 'spare_part';
      }
    }
    final s = serial.toUpperCase();
    if (s.contains('-ACC-') || s.contains('ACCESSORY') || s.contains('ACCESSORIES') || s.startsWith('ACC-') || s.startsWith('ACC')) {
      return 'accessory';
    }
    if (s.contains('-SPR-') || s.contains('SPARE') || s.contains('SPARES') || s.startsWith('SPR-') || s.startsWith('SPR')) {
      return 'spare_part';
    }
    if (s.contains('-DOM-') || s.contains('DOMESTIC') || s.startsWith('DOM-') || s.startsWith('DOM')) {
      return 'domestic';
    }
    if (s.contains('-COM-') || s.contains('COMMERCIAL') || s.startsWith('COM-') || s.startsWith('COM')) {
      return 'commercial';
    }
    if (s.contains('-IND-') || s.contains('INDUSTRIAL') || s.startsWith('IND-') || s.startsWith('IND')) {
      return 'industrial';
    }
    return defaultCategory?.toLowerCase() ?? 'domestic';
  }

  static Map<String, dynamic> sanitizeUnitJson(Map<String, dynamic> raw) {
    final nowIso = DateTime.now().toIso8601String();
    var serial = raw['serial_number']?.toString() ??
        raw['product_code']?.toString() ??
        raw['model_number']?.toString() ??
        '';
    final unitId = raw['unit_id']?.toString() ?? raw['id']?.toString() ?? serial;

    Map<String, dynamic>? regMap;
    final rawReg = raw['registration'] ?? raw['unit_registrations'];
    if (rawReg is Map) {
      regMap = sanitizeRegistrationJson(Map<String, dynamic>.from(rawReg));
    } else if (rawReg is List && rawReg.isNotEmpty) {
      regMap = sanitizeRegistrationJson(Map<String, dynamic>.from(rawReg.first as Map));
    }

    final rawProdName = raw['product_name']?.toString();
    final cleanProdName = (rawProdName != null && rawProdName.isNotEmpty && !isUuidString(rawProdName))
        ? rawProdName
        : null;

    final rawCategory = raw['category']?.toString();
    final category = (rawCategory != null && rawCategory.isNotEmpty)
        ? rawCategory.toLowerCase()
        : 'domestic';

    if (isUuidString(serial)) {
      final codeCandidate = raw['product_code']?.toString() ?? raw['model_number']?.toString();
      if (codeCandidate != null && codeCandidate.isNotEmpty && !isUuidString(codeCandidate)) {
        serial = codeCandidate;
      } else {
        serial = '';
      }
    }

    final productId = raw['product_id']?.toString() ?? '';

    return <String, dynamic>{
      'unit_id': unitId,
      'serial_number': serial,
      'product_id': productId,
      'product_name': cleanProdName ?? (serial.isNotEmpty ? serial : 'Unresolved Product'),
      'category': category,
      'status': raw['status']?.toString() ?? (regMap != null ? 'registered' : 'available'),
      'manufactured_at': raw['manufactured_at']?.toString() ?? nowIso,
      'model_number': raw['model_number']?.toString() ?? serial,
      'product_code': raw['product_code']?.toString() ?? serial,
      'stock_quantity': (raw['stock_quantity'] as num?)?.toInt() ?? 0,
      'default_warranty_months': (raw['default_warranty_months'] as num?)?.toInt() ?? 12,
      'registration': regMap,
    };
  }

  @override
  Future<Result<List<ProductLookup>>> fetchRegistrations({String? userId}) async {
    try {
      final dbUnits = <ProductLookup>[];
      try {
        var query = _client.from('unit_registrations').select('*, products(*)');
        if (userId != null && userId.isNotEmpty) {
          query = query.eq('registered_by', userId);
        }

        final rows = await query.order('created_at', ascending: false);

        for (final row in rows as List) {
          final regMap = Map<String, dynamic>.from(row as Map);
          final regId = regMap['id']?.toString() ?? '';
          final uId = regMap['unit_id']?.toString() ?? regId;
          final regProductId = regMap['product_id']?.toString();

          if (_deletedRegistrationIds.contains(regId) || _deletedRegistrationIds.contains(uId)) {
            continue;
          }

          Map<String, dynamic>? prod = regMap['products'] as Map<String, dynamic>?;

          if (prod == null && regProductId != null && regProductId.isNotEmpty && isUuidString(regProductId)) {
            try {
              prod = await _client
                  .from('products')
                  .select('*')
                  .eq('id', regProductId)
                  .maybeSingle();
            } catch (_) {}
          }

          if (prod == null && uId.isNotEmpty) {
            try {
              final qrRows = await _client
                  .from('product_qr_labels')
                  .select('product_id')
                  .eq('qr_code', uId)
                  .limit(1);
              if (qrRows.isNotEmpty) {
                final qrProdId = qrRows.first['product_id'] as String;
                prod = await _client
                    .from('products')
                    .select('*')
                    .eq('id', qrProdId)
                    .maybeSingle();
              }
            } catch (_) {}
          }

          if (prod == null && uId.isNotEmpty && !isUuidString(uId)) {
            try {
              prod = await _client
                  .from('products')
                  .select('*')
                  .or('product_code.eq.$uId,model_number.eq.$uId')
                  .maybeSingle();
            } catch (_) {}
          }

          final String displayProductCode = prod?['product_code']?.toString() ??
              prod?['model_number']?.toString() ??
              (!isUuidString(uId) ? uId : '');

          if (displayProductCode.isNotEmpty &&
              (_deletedRegistrationIds.contains(displayProductCode) ||
               _deletedRegistrationIds.contains(displayProductCode.toUpperCase()))) {
            continue;
          }

          final categoryStr = prod?['category']?.toString() ?? 'domestic';
          final prodName = prod?['name']?.toString() ??
              (displayProductCode.isNotEmpty ? displayProductCode : 'Unresolved Product');

          final combined = <String, dynamic>{
            'unit_id': uId,
            'serial_number': displayProductCode,
            'manufactured_at': regMap['created_at'] ?? DateTime.now().toIso8601String(),
            'product_id': prod?['id'] ?? regProductId ?? uId,
            'product_name': prodName,
            'model_number': displayProductCode,
            'product_code': displayProductCode,
            'category': categoryStr,
            'default_warranty_months': prod?['warranty_months'] ?? 12,
            'stock_quantity': (prod?['stock_quantity'] as num?)?.toInt() ?? 0,
            'registration': regMap,
          };
          dbUnits.add(ProductLookup.fromJson(sanitizeUnitJson(combined)));
        }
      } catch (dbError) {
        AppLog.warn('Failed to query DB unit_registrations: $dbError');
      }

      return Success<List<ProductLookup>>(dbUnits);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<ProductLookup>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<ProductLookup?>> findProductByBarcode(String barcode) async {
    try {
      final cleanBarcode = barcode.trim().toUpperCase();
      if (cleanBarcode.isEmpty) {
        return const Success<ProductLookup?>(null);
      }

      // 1. Try authoritative RPC lookup first
      try {
        final response = await _client.rpc<dynamic>(
          'lookup_product_by_barcode',
          params: <String, dynamic>{'p_barcode': cleanBarcode},
        );

        if (response != null) {
          final data = Map<String, dynamic>.from(response as Map);
          final unit = ProductLookup.fromJson(sanitizeUnitJson(data));
          return Success<ProductLookup?>(unit);
        }
      } catch (rpcError) {
        AppLog.warn('lookup_product_by_barcode RPC call failed, falling back to direct query: $rpcError');
      }

      // 2. Direct fallback query (exact matches only)
      try {
        Map<String, dynamic>? matchedProduct;

        // Check persistent product_qr_labels table
        try {
          final qrRows = await _client
              .from('product_qr_labels')
              .select('product_id')
              .eq('qr_code', cleanBarcode)
              .limit(1);
          if (qrRows.isNotEmpty) {
            final qrProdId = qrRows.first['product_id'] as String;
            final prodRows = await _client
                .from('products')
                .select('*')
                .eq('id', qrProdId)
                .limit(1);
            if (prodRows.isNotEmpty) {
              matchedProduct = Map<String, dynamic>.from(prodRows.first as Map);
            }
          }
        } catch (_) {}

        // If not in QR labels, check exact product_code, model_number, or id
        if (matchedProduct == null) {
          final isUuid = isUuidString(cleanBarcode);
          final filter = isUuid
              ? 'id.eq.$cleanBarcode,product_code.eq.$cleanBarcode,model_number.eq.$cleanBarcode'
              : 'product_code.eq.$cleanBarcode,model_number.eq.$cleanBarcode';

          final exactProds = await _client
              .from('products')
              .select('*')
              .or(filter)
              .limit(1);

          if (exactProds.isNotEmpty) {
            matchedProduct = Map<String, dynamic>.from(exactProds.first as Map);
          }
        }

        if (matchedProduct != null) {
          final prodId = matchedProduct['id'] as String;
          final categoryStr = matchedProduct['category'] as String? ?? 'domestic';
          final prodName = matchedProduct['name'] as String? ?? cleanBarcode;
          final modelNum = matchedProduct['model_number'] as String? ?? matchedProduct['product_code'] as String? ?? cleanBarcode;
          final warranty = (matchedProduct['warranty_months'] as num?)?.toInt() ?? 12;

          Map<String, dynamic>? regMap;
          try {
            final regRow = await _client
                .from('unit_registrations')
                .select('*')
                .eq('unit_id', cleanBarcode)
                .maybeSingle();
            if (regRow != null) {
              regMap = sanitizeRegistrationJson(Map<String, dynamic>.from(regRow));
            }
          } catch (_) {}

          final combined = <String, dynamic>{
            'unit_id': cleanBarcode,
            'serial_number': cleanBarcode,
            'manufactured_at': DateTime.now().toIso8601String(),
            'product_id': prodId,
            'product_name': prodName,
            'product_code': matchedProduct['product_code'] as String?,
            'model_number': modelNum,
            'category': categoryStr,
            'description': matchedProduct['description'] as String?,
            'stock_quantity': (matchedProduct['stock_quantity'] as num?)?.toInt() ?? 0,
            'default_warranty_months': warranty,
            'registration': regMap,
          };

          final unit = ProductLookup.fromJson(sanitizeUnitJson(combined));
          return Success<ProductLookup?>(unit);
        }
      } catch (prodSearchErr) {
        AppLog.warn('Products direct query error: $prodSearchErr');
      }

      // If no exact match is found, return null (NO fake fallback)
      return const Success<ProductLookup?>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<ProductLookup?>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<ProductRegistrationInfo>> registerUnit({
    required String unitId,
    required String customerName,
    required String customerPhone,
    required DateTime purchaseDate,
    required DateTime installationDate,
    required int warrantyMonths,
    String? customerCity,
    String? customerAddress,
    String? invoiceNumber,
    String? sellerName,
    String? sellerPhone,
    String? registeredRole,
  }) async {
    final userId = _client.auth.currentUser?.id;
    final cleanUnitId = unitId.trim().toUpperCase();

    final warrantyStartDate = installationDate;

    try {
      String? realProductId;

      try {
        Map<String, dynamic>? matchedProd;

        // 1. Check exact QR label
        try {
          final qrRows = await _client
              .from('product_qr_labels')
              .select('product_id')
              .eq('qr_code', cleanUnitId)
              .limit(1);
          if (qrRows.isNotEmpty) {
            final qrProdId = qrRows.first['product_id'] as String;
            final prodRows = await _client
                .from('products')
                .select('*')
                .eq('id', qrProdId)
                .limit(1);
            if (prodRows.isNotEmpty) {
              matchedProd = Map<String, dynamic>.from(prodRows.first as Map);
            }
          }
        } catch (_) {}

        // 2. Check exact product_code or model_number or id
        if (matchedProd == null) {
          final isUuid = isUuidString(cleanUnitId);
          final filter = isUuid
              ? 'id.eq.$cleanUnitId,product_code.eq.$cleanUnitId,model_number.eq.$cleanUnitId'
              : 'product_code.eq.$cleanUnitId,model_number.eq.$cleanUnitId';

          final exactProds = await _client
              .from('products')
              .select('*')
              .or(filter)
              .limit(1);

          if (exactProds.isNotEmpty) {
            matchedProd = Map<String, dynamic>.from(exactProds.first as Map);
          }
        }

        if (matchedProd != null) {
          realProductId = matchedProd['id'] as String;
        }
      } catch (prodErr) {
        AppLog.warn('Product resolution error for registration: $prodErr');
      }

      final insertData = <String, dynamic>{
        'unit_id': cleanUnitId,
        'registered_by': userId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_city': customerCity,
        'customer_address': customerAddress,
        'seller_name': sellerName,
        'seller_phone': sellerPhone,
        'purchase_date': purchaseDate.toIso8601String().substring(0, 10),
        'installation_date': installationDate.toIso8601String().substring(0, 10),
        'warranty_start_date': warrantyStartDate.toIso8601String().substring(0, 10),
        'warranty_months': warrantyMonths,
        'invoice_number': invoiceNumber,
      };
      if (realProductId != null) {
        insertData['product_id'] = realProductId;
      }

      final payload = Map<String, dynamic>.from(insertData);
      if (registeredRole != null) {
        payload['registered_role'] = registeredRole;
      }

      final res = await _client
          .from('unit_registrations')
          .insert(payload)
          .select()
          .single();

      final sanitizedReg = sanitizeRegistrationJson(Map<String, dynamic>.from(res));
      final regInfo = ProductRegistrationInfo.fromJson(sanitizedReg);

      return Success<ProductRegistrationInfo>(regInfo);
    } on Object catch (error, stackTrace) {
      AppLog.error('Unit registration error', error, stackTrace);
      return ResultFailure<ProductRegistrationInfo>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<ProductRegistrationInfo>> updateRegistration({
    required String registrationId,
    required String customerName,
    required String customerPhone,
    String? customerCity,
    String? customerAddress,
    String? invoiceNumber,
    String? sellerName,
    String? sellerPhone,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'customer_name': customerName,
        'customer_phone': customerPhone,
        if (customerCity != null) 'customer_city': customerCity,
        if (customerAddress != null) 'customer_address': customerAddress,
        if (invoiceNumber != null) 'invoice_number': invoiceNumber,
        if (sellerName != null) 'seller_name': sellerName,
        if (sellerPhone != null) 'seller_phone': sellerPhone,
      };

      final res = await _client
          .from('unit_registrations')
          .update(updateData)
          .eq('id', registrationId)
          .select()
          .maybeSingle();

      if (res != null) {
        final sanitizedReg = sanitizeRegistrationJson(Map<String, dynamic>.from(res));
        final regInfo = ProductRegistrationInfo.fromJson(sanitizedReg);
        return Success<ProductRegistrationInfo>(regInfo);
      }

      final fallbackReg = ProductRegistrationInfo(
        id: registrationId,
        customerName: customerName,
        customerPhone: customerPhone,
        customerCity: customerCity,
        customerAddress: customerAddress,
        invoiceNumber: invoiceNumber,
        sellerName: sellerName,
        sellerPhone: sellerPhone,
        purchaseDate: DateTime.now(),
        installationDate: DateTime.now(),
        warrantyStartDate: DateTime.now(),
        warrantyMonths: 12,
        warrantyEndDate: DateTime.now().add(const Duration(days: 365)),
      );
      return Success<ProductRegistrationInfo>(fallbackReg);
    } on Object catch (error, stackTrace) {
      return ResultFailure<ProductRegistrationInfo>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteRegistration(String registrationId) async {
    try {
      final cleanId = registrationId.trim();
      _deletedRegistrationIds.add(cleanId);
      _deletedRegistrationIds.add(cleanId.toUpperCase());

      try {
        await _client
            .from('unit_registrations')
            .delete()
            .or(buildRegFilter(cleanId));
      } catch (dbErr) {
        AppLog.warn('Failed to delete unit_registrations from DB: $dbErr');
      }

      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  AppFailure _map(Object error, StackTrace stackTrace) {
    AppLog.error('Product registration repository operation failed', error, stackTrace);
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

/// The application-wide [ProductRegistrationRepository].
@Riverpod(keepAlive: true)
ProductRegistrationRepository productRegistrationRepository(Ref<ProductRegistrationRepository> ref) =>
    SupabaseProductRegistrationRepository(ref.watch(supabaseClientProvider));
