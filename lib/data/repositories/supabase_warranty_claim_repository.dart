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

      final insertData = <String, dynamic>{
        'unit_id': unitId,
        'user_id': userId,
        'claim_type': claimType,
        'description': description,
        'contact_phone': contactPhone,
        'status': 'pending',
      };

      final response = await _client
          .from('warranty_claims')
          .insert(insertData)
          .select()
          .single();

      final claimId = response['id'] as String;
      final detailsRes = await fetchClaimById(claimId);

      return detailsRes.fold(
        onSuccess: (claim) =>
            Success<WarrantyClaim>(claim ?? _mapRowToClaim(response)),
        onFailure: (_) => Success<WarrantyClaim>(_mapRowToClaim(response)),
      );
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
      var query = _client.from('warranty_claims').select();

      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }
      if (status != null) {
        query = query.eq('status', status.name);
      }

      final rows = await query.order('created_at', ascending: false);

      final claims = <WarrantyClaim>[];
      for (final row in rows as List) {
        final rowMap = Map<String, dynamic>.from(row as Map);
        final claimId = rowMap['id'] as String;
        final detailsResult = await fetchClaimById(claimId);
        detailsResult.fold(
          onSuccess: (claim) =>
              claims.add(claim ?? _mapRowToClaim(rowMap)),
          onFailure: (_) => claims.add(_mapRowToClaim(rowMap)),
        );
      }


      return Success<List<WarrantyClaim>>(claims);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<WarrantyClaim>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<WarrantyClaim?>> fetchClaimById(String claimId) async {
    try {
      final rpcRes = await _client.rpc<dynamic>(
        'get_warranty_claim_details',
        params: <String, dynamic>{'p_claim_id': claimId},
      );

      if (rpcRes != null) {
        final data = Map<String, dynamic>.from(rpcRes as Map);
        return Success<WarrantyClaim?>(_mapDetailsToClaim(data));
      }

      final row = await _client
          .from('warranty_claims')
          .select()
          .eq('id', claimId)
          .maybeSingle();

      if (row == null) {
        return const Success<WarrantyClaim?>(null);
      }

      return Success<WarrantyClaim?>(_mapRowToClaim(row));
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

      await _client.from('warranty_claims').update(updateData).eq('id', claimId);
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  WarrantyClaim _mapRowToClaim(Map<String, dynamic> row) {
    return WarrantyClaim(
      id: row['id'] as String,
      claimNumber: row['claim_number'] as String? ?? 'CLM-0000',
      unitId: row['unit_id'] as String,
      userId: row['user_id'] as String,
      claimType: row['claim_type'] as String,
      description: row['description'] as String,
      contactPhone: row['contact_phone'] as String,
      status: _parseStatus(row['status'] as String?),
      adminNotes: row['admin_notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  WarrantyClaim _mapDetailsToClaim(Map<String, dynamic> data) {
    return WarrantyClaim(
      id: data['id'] as String,
      claimNumber: data['claim_number'] as String? ?? 'CLM-0000',
      unitId: data['unit_id'] as String,
      userId: data['user_id'] as String,
      claimType: data['claim_type'] as String,
      description: data['description'] as String,
      contactPhone: data['contact_phone'] as String,
      status: _parseStatus(data['status'] as String?),
      adminNotes: data['admin_notes'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      userFullName: data['user_full_name'] as String?,
      userCompany: data['user_company'] as String?,
      userPhone: data['user_phone'] as String?,
      userRole: data['user_role'] as String?,
      serialNumber: data['serial_number'] as String?,
      productId: data['product_id'] as String?,
      productName: data['product_name'] as String?,
      modelNumber: data['model_number'] as String?,
      category: data['category'] as String?,
    );
  }

  WarrantyClaimStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return WarrantyClaimStatus.pending;
    return WarrantyClaimStatus.values.firstWhere(
      (s) => s.name == statusStr.toLowerCase(),
      orElse: () => WarrantyClaimStatus.pending,
    );
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
