// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warranty_claim.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WarrantyClaimImpl _$$WarrantyClaimImplFromJson(Map<String, dynamic> json) =>
    _$WarrantyClaimImpl(
      id: json['id'] as String,
      claimNumber: json['claim_number'] as String,
      unitId: json['unit_id'] as String,
      userId: json['user_id'] as String,
      claimType: json['claim_type'] as String,
      description: json['description'] as String,
      contactPhone: json['contact_phone'] as String,
      status:
          $enumDecodeNullable(_$WarrantyClaimStatusEnumMap, json['status']) ??
              WarrantyClaimStatus.pending,
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userFullName: json['user_full_name'] as String?,
      userCompany: json['user_company'] as String?,
      userPhone: json['user_phone'] as String?,
      userRole: json['user_role'] as String?,
      serialNumber: json['serial_number'] as String?,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String?,
      modelNumber: json['model_number'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$$WarrantyClaimImplToJson(_$WarrantyClaimImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'claim_number': instance.claimNumber,
      'unit_id': instance.unitId,
      'user_id': instance.userId,
      'claim_type': instance.claimType,
      'description': instance.description,
      'contact_phone': instance.contactPhone,
      'status': _$WarrantyClaimStatusEnumMap[instance.status]!,
      'admin_notes': instance.adminNotes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'user_full_name': instance.userFullName,
      'user_company': instance.userCompany,
      'user_phone': instance.userPhone,
      'user_role': instance.userRole,
      'serial_number': instance.serialNumber,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'model_number': instance.modelNumber,
      'category': instance.category,
    };

const _$WarrantyClaimStatusEnumMap = {
  WarrantyClaimStatus.pending: 'pending',
  WarrantyClaimStatus.approved: 'approved',
  WarrantyClaimStatus.rejected: 'rejected',
  WarrantyClaimStatus.resolved: 'resolved',
};
