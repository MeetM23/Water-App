// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImageImpl _$$ProductImageImplFromJson(Map<String, dynamic> json) =>
    _$ProductImageImpl(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      storagePath: json['storage_path'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      isPrimary: json['is_primary'] as bool,
    );

Map<String, dynamic> _$$ProductImageImplToJson(_$ProductImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'storage_path': instance.storagePath,
      'sort_order': instance.sortOrder,
      'is_primary': instance.isPrimary,
    };
