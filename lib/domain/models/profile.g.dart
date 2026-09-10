// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: json['id'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      status: $enumDecode(_$AccountStatusEnumMap, json['status']),
      fullName: json['full_name'] as String,
      firmName: json['firm_name'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      gstNumber: json['gst_number'] as String?,
      address: json['address'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      rejectionReason: json['rejection_reason'] as String?,
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$AccountStatusEnumMap[instance.status]!,
      'full_name': instance.fullName,
      'firm_name': instance.firmName,
      'phone': instance.phone,
      'city': instance.city,
      'state': instance.state,
      'created_at': instance.createdAt.toIso8601String(),
      'gst_number': instance.gstNumber,
      'address': instance.address,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'rejection_reason': instance.rejectionReason,
    };

const _$UserRoleEnumMap = {
  UserRole.owner: 'owner',
  UserRole.wholesaler: 'wholesaler',
  UserRole.retailer: 'retailer',
};

const _$AccountStatusEnumMap = {
  AccountStatus.pending: 'pending',
  AccountStatus.approved: 'approved',
  AccountStatus.rejected: 'rejected',
  AccountStatus.suspended: 'suspended',
};
