// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusinessSettingsImpl _$$BusinessSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$BusinessSettingsImpl(
      businessName: json['business_name'] as String,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$BusinessSettingsImplToJson(
        _$BusinessSettingsImpl instance) =>
    <String, dynamic>{
      'business_name': instance.businessName,
      'phone': instance.phone,
      'address': instance.address,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
