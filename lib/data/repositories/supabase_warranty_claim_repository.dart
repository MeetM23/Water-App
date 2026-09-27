import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/models/warranty_claim.dart';
import '../../domain/repositories/warranty_claim_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_warranty_claim_repository.g.dart';

/// Communication layer with Supabase for warranty claim management.
class SupabaseWarrantyClaimRepository implements WarrantyClaimRepository {
  /// Creates repository instance over initialized SupabaseClient.
  SupabaseWarrantyClaimRepository(this._client);

  final SupabaseClient _client;
  final List<WarrantyClaim> _inMemoryClaims = <WarrantyClaim>[];

  @override
  Future<Result<WarrantyClaim>> submitClaim({
    required String unitId,
    String? productId,
    required String claimType,
    required String description,
    required String contactPhone,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const ResultFailure<WarrantyClaim>(
          AuthFailure(AuthFailureReason.sessionExpired),
        );
      }

      final cleanUnitId = unitId.trim().toUpperCase();
      String? dbProductId = (productId != null && productId.trim().isNotEmpty)
          ? productId.trim()
          : null;

      if (dbProductId == null) {
        try {
          final lookupRes = await _client.rpc<dynamic>(
            'lookup_product_by_barcode',
            params: <String, dynamic>{'p_barcode': cleanUnitId},
          );
          if (lookupRes != null &&
              lookupRes is Map &&
              lookupRes['product_id'] != null) {
            dbProductId = lookupRes['product_id'] as String;
          }
        } catch (lookupErr) {
          AppLog.warn('lookup_product_by_barcode for claim failed: $lookupErr');
        }
      }

      final insertData = <String, dynamic>{
        'unit_id': cleanUnitId,
        'user_id': userId,
        'claim_type': claimType,
        'description': description,
        'contact_phone': contactPhone,
        'status': 'pending',
      };
      if (dbProductId != null) {
        insertData['product_id'] = dbProductId;
      }

      final response = await _client
          .from('warranty_claims')
          .insert(insertData)
          .select()
          .single();

      final claimId = response['id'] as String;
      final detailsRes = await fetchClaimById(claimId);

      final claim = detailsRes.fold(
        onSuccess: (c) => c ?? _mapRowToClaim(response),
        onFailure: (_) => _mapRowToClaim(response),
      );

      String resolvedName = claim.productName ?? '';
      if (resolvedName.isEmpty || resolvedName.startsWith('RO Water Purifier')) {
        try {
          if (dbProductId != null) {
            final p = await _client.from('products').select('name').eq('id', dbProductId).maybeSingle();
            if (p != null && p['name'] != null) resolvedName = p['name'] as String;
          }
        } catch (_) {}
      }
      if (resolvedName.isEmpty) resolvedName = cleanUnitId;

      final fullClaim = claim.copyWith(
        serialNumber: (claim.serialNumber != null && claim.serialNumber!.isNotEmpty) ? claim.serialNumber! : cleanUnitId,
        productName: resolvedName,
        modelNumber: (claim.modelNumber != null && claim.modelNumber!.isNotEmpty) ? claim.modelNumber! : cleanUnitId,
      );

      _inMemoryClaims.removeWhere((c) => c.id == fullClaim.id);
      _inMemoryClaims.insert(0, fullClaim);

      return Success<WarrantyClaim>(fullClaim);
    } on Object catch (error, stackTrace) {
      return ResultFailure<WarrantyClaim>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<WarrantyClaim>>> fetchClaims({
    String? userId,
    WarrantyClaimStatus? status,
  }) async {
    try {
      final dbClaims = <WarrantyClaim>[];

      try {
        var query = _client.from('warranty_claims').select();
        if (userId != null && userId.isNotEmpty) {
          query = query.eq('user_id', userId);
        }
        if (status != null) {
          query = query.eq('status', status.name);
        }

        final rows = await query.order('created_at', ascending: false);
        final rawList = rows as List;

        final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$');
        final userIds = <String>{};
        final directProductIds = <String>{};
        final missingProductUnitIds = <String>{};

        for (final r in rawList) {
          final rowMap = Map<String, dynamic>.from(r as Map);
          final uid = rowMap['user_id']?.toString();
          if (uid != null && uid.isNotEmpty && isUuid.hasMatch(uid)) {
            userIds.add(uid);
          }
          final pid = rowMap['product_id']?.toString();
          if (pid != null && pid.isNotEmpty && isUuid.hasMatch(pid)) {
            directProductIds.add(pid);
          } else {
            final unitId = rowMap['unit_id']?.toString().trim();
            if (unitId != null && unitId.isNotEmpty) {
              missingProductUnitIds.add(unitId);
            }
          }
        }

        final qrToProductIdMap = <String, String>{};
        if (missingProductUnitIds.isNotEmpty) {
          try {
            final qrRows = await _client
                .from('product_qr_labels')
                .select('qr_code, product_id')
                .inFilter('qr_code', missingProductUnitIds.toList());
            for (final qr in qrRows as List) {
              final qrMap = Map<String, dynamic>.from(qr as Map);
              final code = qrMap['qr_code']?.toString();
              final pId = qrMap['product_id']?.toString();
              if (code != null && pId != null) {
                qrToProductIdMap[code] = pId;
                directProductIds.add(pId);
              }
            }
          } catch (e) {
            AppLog.warn('Could not batch fetch QR labels for claims: $e');
          }
        }

        final profilesMap = <String, Map<String, dynamic>>{};
        if (userIds.isNotEmpty) {
          try {
            final profileRows = await _client
                .from('profiles')
                .select('id, full_name, firm_name, phone, role')
                .inFilter('id', userIds.toList());
            for (final p in profileRows as List) {
              final pMap = Map<String, dynamic>.from(p as Map);
              profilesMap[pMap['id'].toString()] = pMap;
            }
          } catch (e) {
            AppLog.warn('Could not batch fetch profiles for claims: $e');
          }
        }

        final productsMap = <String, Map<String, dynamic>>{};
        if (directProductIds.isNotEmpty) {
          try {
            final prodRows = await _client
                .from('products')
                .select('id, name, product_code, model_number, category')
                .inFilter('id', directProductIds.toList());
            for (final pr in prodRows as List) {
              final prMap = Map<String, dynamic>.from(pr as Map);
              productsMap[prMap['id'].toString()] = prMap;
            }
          } catch (e) {
            AppLog.warn('Could not batch fetch products for claims: $e');
          }
        }

        for (final r in rawList) {
          final rowMap = Map<String, dynamic>.from(r as Map);
          final uid = rowMap['user_id']?.toString() ?? '';
          var pid = rowMap['product_id']?.toString() ?? '';
          final unitId = rowMap['unit_id']?.toString() ?? '';

          if (pid.isEmpty && qrToProductIdMap.containsKey(unitId)) {
            pid = qrToProductIdMap[unitId]!;
          }

          final profile = profilesMap[uid];
          final product = productsMap[pid];

          final displaySerial = unitId.isNotEmpty
              ? unitId
              : (product?['product_code']?.toString() ?? '');

          final prodName = product?['name']?.toString() ??
              (displaySerial.isNotEmpty ? displaySerial : '');

          final claimNumber = rowMap['claim_number']?.toString() ?? '';

          final combined = <String, dynamic>{
            'id': rowMap['id'],
            'claim_number': claimNumber,
            'unit_id': unitId,
            'user_id': uid,
            'product_id': pid,
            'claim_type': rowMap['claim_type'],
            'description': rowMap['description'],
            'contact_phone': rowMap['contact_phone'],
            'status': rowMap['status'],
            'admin_notes': rowMap['admin_notes'],
            'created_at': rowMap['created_at'],
            'updated_at': rowMap['updated_at'],
            'serial_number': displaySerial,
            'product_name': prodName,
            'model_number': product?['model_number'] ?? product?['product_code'],
            'category': product?['category'] ?? 'domestic',
            'user_full_name': profile?['full_name'],
            'user_company': profile?['firm_name'],
            'user_phone': profile?['phone'] ?? rowMap['contact_phone'],
            'user_role': profile?['role'],
          };

          dbClaims.add(_mapDetailsToClaim(combined));
        }
      } catch (dbError) {
        AppLog.warn('Failed to query DB warranty_claims: $dbError');
      }

      final mergedMap = <String, WarrantyClaim>{};

      for (final claim in _inMemoryClaims) {
        if (userId != null && userId.isNotEmpty && claim.userId != userId) {
          continue;
        }
        if (status != null && claim.status != status) {
          continue;
        }
        mergedMap[claim.id] = claim;
      }

      for (final claim in dbClaims) {
        if (!mergedMap.containsKey(claim.id)) {
          mergedMap[claim.id] = claim;
        }
      }

      final resultList = mergedMap.values.toList();
      resultList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Success<List<WarrantyClaim>>(resultList);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<WarrantyClaim>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<WarrantyClaim?>> fetchClaimById(String claimId) async {
    try {
      final localMatch = _inMemoryClaims.cast<WarrantyClaim?>().firstWhere(
            (c) => c?.id == claimId,
            orElse: () => null,
          );

      try {
        final rpcRes = await _client.rpc<dynamic>(
          'get_warranty_claim_details',
          params: <String, dynamic>{'p_claim_id': claimId},
        );

        if (rpcRes != null && rpcRes is Map) {
          final data = Map<String, dynamic>.from(rpcRes);
          return Success<WarrantyClaim?>(_mapDetailsToClaim(data));
        }
      } catch (rpcError) {
        AppLog.warn(
            'get_warranty_claim_details RPC failed, using fallback query: $rpcError');
      }

      try {
        final row = await _client
            .from('warranty_claims')
            .select()
            .eq('id', claimId)
            .maybeSingle();

        if (row != null) {
          final rowMap = Map<String, dynamic>.from(row);
          final uid = rowMap['user_id']?.toString() ?? '';
          var pid = rowMap['product_id']?.toString() ?? '';
          final unitId = rowMap['unit_id']?.toString() ?? '';

          if (pid.isEmpty && unitId.isNotEmpty) {
            try {
              final qrRow = await _client
                  .from('product_qr_labels')
                  .select('product_id')
                  .eq('qr_code', unitId)
                  .maybeSingle();
              if (qrRow != null && qrRow['product_id'] != null) {
                pid = qrRow['product_id'].toString();
              }
            } catch (_) {}
          }

          Map<String, dynamic>? profile;
          if (uid.isNotEmpty) {
            try {
              final p = await _client
                  .from('profiles')
                  .select('id, full_name, firm_name, phone, role')
                  .eq('id', uid)
                  .maybeSingle();
              if (p != null) profile = Map<String, dynamic>.from(p);
            } catch (_) {}
          }

          Map<String, dynamic>? product;
          if (pid.isNotEmpty) {
            try {
              final pr = await _client
                  .from('products')
                  .select('id, name, product_code, model_number, category')
                  .eq('id', pid)
                  .maybeSingle();
              if (pr != null) product = Map<String, dynamic>.from(pr);
            } catch (_) {}
          }

          final displaySerial = unitId.isNotEmpty
              ? unitId
              : (product?['product_code']?.toString() ?? '');

          final prodName = product?['name']?.toString() ??
              (displaySerial.isNotEmpty ? displaySerial : '');

          final claimNumber = rowMap['claim_number']?.toString() ?? '';

          final combined = <String, dynamic>{
            'id': rowMap['id'],
            'claim_number': claimNumber,
            'unit_id': unitId,
            'user_id': uid,
            'product_id': pid,
            'claim_type': rowMap['claim_type'],
            'description': rowMap['description'],
            'contact_phone': rowMap['contact_phone'],
            'status': rowMap['status'],
            'admin_notes': rowMap['admin_notes'],
            'created_at': rowMap['created_at'],
            'updated_at': rowMap['updated_at'],
            'serial_number': displaySerial,
            'product_name': prodName,
            'model_number': product?['model_number'] ?? product?['product_code'],
            'category': product?['category'] ?? 'domestic',
            'user_full_name': profile?['full_name'],
            'user_company': profile?['firm_name'],
            'user_phone': profile?['phone'] ?? rowMap['contact_phone'],
            'user_role': profile?['role'],
          };

          return Success<WarrantyClaim?>(_mapDetailsToClaim(combined));
        }
      } catch (rowErr) {
        AppLog.warn('Direct query for claim $claimId failed: $rowErr');
      }

      return Success<WarrantyClaim?>(localMatch);
    } on Object catch (error, stackTrace) {
      return ResultFailure<WarrantyClaim?>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> updateClaimStatus({
    required String claimId,
    required WarrantyClaimStatus status,
    String? adminNotes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (adminNotes != null) {
        updateData['admin_notes'] = adminNotes;
      }

      try {
        await _client.from('warranty_claims').update(updateData).eq('id', claimId);
      } catch (updateErr) {
        AppLog.warn('Update claim status DB write error: $updateErr');
      }

      final idx = _inMemoryClaims.indexWhere((c) => c.id == claimId);
      if (idx != -1) {
        _inMemoryClaims[idx] = _inMemoryClaims[idx].copyWith(
          status: status,
          adminNotes: adminNotes ?? _inMemoryClaims[idx].adminNotes,
          updatedAt: DateTime.now(),
        );
      }

      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  Map<String, dynamic> sanitizeClaimJson(Map<String, dynamic> raw) {
    final nowIso = DateTime.now().toIso8601String();
    final serial = raw['serial_number']?.toString() ?? raw['unit_id']?.toString() ?? '';
    final claimNum = raw['claim_number']?.toString() ?? '';

    return <String, dynamic>{
      'id': raw['id']?.toString() ?? '',
      'claim_number': claimNum,
      'unit_id': raw['unit_id']?.toString() ?? serial,
      'user_id': raw['user_id']?.toString() ?? _client.auth.currentUser?.id ?? '',
      'claim_type': raw['claim_type']?.toString() ?? 'Warranty Claim',
      'description': raw['description']?.toString() ?? '',
      'contact_phone': raw['contact_phone']?.toString() ?? '',
      'status': raw['status']?.toString() ?? 'pending',
      'admin_notes': raw['admin_notes']?.toString(),
      'created_at': raw['created_at']?.toString() ?? nowIso,
      'updated_at': raw['updated_at']?.toString() ?? nowIso,
      'user_full_name': raw['user_full_name']?.toString(),
      'user_company': raw['user_company']?.toString(),
      'user_phone': raw['user_phone']?.toString() ?? raw['contact_phone']?.toString(),
      'user_role': raw['user_role']?.toString(),
      'serial_number': serial,
      'product_id': raw['product_id']?.toString() ?? '',
      'product_name': raw['product_name']?.toString() ?? (serial.isNotEmpty ? serial : ''),
      'model_number': raw['model_number']?.toString() ?? serial,
      'category': raw['category']?.toString() ?? 'domestic',
    };
  }

  WarrantyClaim _mapRowToClaim(Map<String, dynamic> row) {
    return WarrantyClaim.fromJson(sanitizeClaimJson(row));
  }

  WarrantyClaim _mapDetailsToClaim(Map<String, dynamic> data) {
    return WarrantyClaim.fromJson(sanitizeClaimJson(data));
  }

  AppFailure _map(Object error, StackTrace stackTrace) {
    AppLog.error('Warranty claim repository error', error, stackTrace);
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

/// Provider for [WarrantyClaimRepository].
@Riverpod(keepAlive: true)
WarrantyClaimRepository warrantyClaimRepository(
  Ref<WarrantyClaimRepository> ref,
) =>
    SupabaseWarrantyClaimRepository(ref.watch(supabaseClientProvider));
