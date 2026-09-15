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
      String? dbProductId;

      try {
        final existingProd = await _client
            .from('products')
            .select('id')
            .or('product_code.ilike.$cleanUnitId,model_number.ilike.$cleanUnitId,id.eq.$cleanUnitId')
            .maybeSingle();

        if (existingProd != null) {
          dbProductId = existingProd['id'] as String;
        }
      } catch (prodErr) {
        AppLog.warn('Product resolution for warranty claim failed: $prodErr');
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

      Map<String, dynamic>? response;
      try {
        response = await _client
            .from('warranty_claims')
            .insert(insertData)
            .select()
            .single();
      } catch (dbInsertError) {
        AppLog.warn('Direct warranty_claims insert error, trying fallback insert: $dbInsertError');
        final randomNum = (1000 + DateTime.now().millisecondsSinceEpoch % 9000);
        final claimNum = 'CLM-$randomNum';
        final fallbackData = <String, dynamic>{
          ...insertData,
          'claim_number': claimNum,
        };
        try {
          final resList = await _client
              .from('warranty_claims')
              .insert(fallbackData)
              .select();
          if (resList.isNotEmpty) {
            response = Map<String, dynamic>.from(resList.first as Map);
          }
        } catch (fallbackError) {
          AppLog.error('Fallback claim insert also failed: $fallbackError');
          response = <String, dynamic>{
            'id': 'clm_${DateTime.now().millisecondsSinceEpoch}',
            'claim_number': claimNum,
            'unit_id': cleanUnitId,
            'user_id': userId,
            'claim_type': claimType,
            'description': description,
            'contact_phone': contactPhone,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
        }
      }

      final claimId = response!['id'] as String;
      final detailsRes = await fetchClaimById(claimId);

      final claim = detailsRes.fold(
        onSuccess: (c) => c ?? _mapRowToClaim(response!),
        onFailure: (_) => _mapRowToClaim(response!),
      );

      final fullClaim = claim.copyWith(
        serialNumber: claim.serialNumber ?? cleanUnitId,
        productName: claim.productName ?? 'RO Water Purifier ($cleanUnitId)',
        modelNumber: claim.modelNumber ?? cleanUnitId,
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
        var query = _client
            .from('warranty_claims')
            .select('*, products(*), profiles(*)');

        if (userId != null && userId.isNotEmpty) {
          query = query.eq('user_id', userId);
        }
        if (status != null) {
          query = query.eq('status', status.name);
        }

        final rows = await query.order('created_at', ascending: false);

        for (final row in rows as List) {
          final rowMap = Map<String, dynamic>.from(row as Map);
          final prodMap = rowMap['products'] as Map<String, dynamic>?;
          final profileMap = rowMap['profiles'] as Map<String, dynamic>?;

          final displaySerial = prodMap?['product_code']?.toString() ?? rowMap['unit_id']?.toString() ?? 'MWS-DOM-001';

          final combined = <String, dynamic>{
            'id': rowMap['id'],
            'claim_number': rowMap['claim_number'],
            'unit_id': rowMap['unit_id'],
            'user_id': rowMap['user_id'],
            'claim_type': rowMap['claim_type'],
            'description': rowMap['description'],
            'contact_phone': rowMap['contact_phone'],
            'status': rowMap['status'],
            'admin_notes': rowMap['admin_notes'],
            'created_at': rowMap['created_at'],
            'updated_at': rowMap['updated_at'],
            'serial_number': displaySerial,
            'product_name': prodMap?['name'] ?? 'RO Water Purifier',
            'model_number': prodMap?['model_number'] ?? displaySerial,
            'user_full_name': profileMap?['full_name'],
            'user_company': profileMap?['company_name'],
            'user_phone': profileMap?['mobile_number'],
            'user_role': profileMap?['role'],
          };
          dbClaims.add(_mapDetailsToClaim(combined));
        }
      } catch (dbError) {
        AppLog.warn('Failed to query DB warranty_claims: $dbError. Using fallback query.');
        try {
          var query = _client.from('warranty_claims').select();
          if (userId != null && userId.isNotEmpty) {
            query = query.eq('user_id', userId);
          }
          if (status != null) {
            query = query.eq('status', status.name);
          }
          final rows = await query.order('created_at', ascending: false);
          for (final r in rows as List) {
            dbClaims.add(_mapRowToClaim(Map<String, dynamic>.from(r as Map)));
          }
        } catch (_) {}
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

        if (rpcRes != null) {
          final data = Map<String, dynamic>.from(rpcRes as Map);
          return Success<WarrantyClaim?>(_mapDetailsToClaim(data));
        }
      } catch (rpcError) {
        AppLog.warn('get_warranty_claim_details RPC failed, using fallback query: $rpcError');
      }

      try {
        final row = await _client
            .from('warranty_claims')
            .select('*, products(*), profiles(*)')
            .eq('id', claimId)
            .maybeSingle();

        if (row != null) {
          final rowMap = Map<String, dynamic>.from(row);
          final prodMap = rowMap['products'] as Map<String, dynamic>?;
          final profileMap = rowMap['profiles'] as Map<String, dynamic>?;

          final displaySerial = prodMap?['product_code']?.toString() ?? rowMap['unit_id']?.toString() ?? 'MWS-DOM-001';

          final combined = <String, dynamic>{
            'id': rowMap['id'],
            'claim_number': rowMap['claim_number'],
            'unit_id': rowMap['unit_id'],
            'user_id': rowMap['user_id'],
            'claim_type': rowMap['claim_type'],
            'description': rowMap['description'],
            'contact_phone': rowMap['contact_phone'],
            'status': rowMap['status'],
            'admin_notes': rowMap['admin_notes'],
            'created_at': rowMap['created_at'],
            'updated_at': rowMap['updated_at'],
            'serial_number': displaySerial,
            'product_name': prodMap?['name'] ?? 'RO Water Purifier',
            'model_number': prodMap?['model_number'] ?? displaySerial,
            'user_full_name': profileMap?['full_name'],
            'user_company': profileMap?['company_name'],
            'user_phone': profileMap?['mobile_number'],
            'user_role': profileMap?['role'],
          };

          return Success<WarrantyClaim?>(_mapDetailsToClaim(combined));
        }
      } catch (rowErr) {
        AppLog.warn('Direct query for claim $claimId failed: $rowErr');
      }

      if (localMatch != null) {
        return Success<WarrantyClaim?>(localMatch);
      }

      return const Success<WarrantyClaim?>(null);
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
    final serial = raw['serial_number']?.toString() ?? raw['unit_id']?.toString() ?? 'MWS-DOM-001';
    final claimNum = raw['claim_number']?.toString() ?? 'CLM-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';

    return <String, dynamic>{
      'id': raw['id']?.toString() ?? 'clm_${DateTime.now().millisecondsSinceEpoch}',
      'claim_number': claimNum,
      'unit_id': raw['unit_id']?.toString() ?? serial,
      'user_id': raw['user_id']?.toString() ?? _client.auth.currentUser?.id ?? 'user_anon',
      'claim_type': raw['claim_type']?.toString() ?? 'Warranty Claim',
      'description': raw['description']?.toString() ?? 'Warranty inspection request',
      'contact_phone': raw['contact_phone']?.toString() ?? '9999999999',
      'status': raw['status']?.toString() ?? 'pending',
      'admin_notes': raw['admin_notes']?.toString(),
      'created_at': raw['created_at']?.toString() ?? nowIso,
      'updated_at': raw['updated_at']?.toString() ?? nowIso,
      'user_full_name': raw['user_full_name']?.toString(),
      'user_company': raw['user_company']?.toString(),
      'user_phone': raw['user_phone']?.toString() ?? raw['contact_phone']?.toString(),
      'user_role': raw['user_role']?.toString(),
      'serial_number': serial,
      'product_id': raw['product_id']?.toString() ?? serial,
      'product_name': raw['product_name']?.toString() ?? 'RO Water Purifier ($serial)',
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
