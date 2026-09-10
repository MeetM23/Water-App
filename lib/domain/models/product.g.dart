// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      productCode: json['product_code'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$ProductCategoryEnumMap, json['category']),
      wholesalePrice: (json['wholesale_price'] as num).toDouble(),
      retailPrice: (json['retail_price'] as num).toDouble(),
      inStock: json['in_stock'] as bool,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      specifications: json['specifications'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      modelNumber: json['model_number'] as String?,
      description: json['description'] as String?,
      capacity: json['capacity'] as String?,
      mrp: (json['mrp'] as num?)?.toDouble(),
      warrantyMonths: (json['warranty_months'] as num?)?.toInt(),
      createdBy: json['created_by'] as String?,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_code': instance.productCode,
      'name': instance.name,
      'category': _$ProductCategoryEnumMap[instance.category]!,
      'wholesale_price': instance.wholesalePrice,
      'retail_price': instance.retailPrice,
      'in_stock': instance.inStock,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'specifications': instance.specifications,
      'model_number': instance.modelNumber,
      'description': instance.description,
      'capacity': instance.capacity,
      'mrp': instance.mrp,
      'warranty_months': instance.warrantyMonths,
      'created_by': instance.createdBy,
    };

const _$ProductCategoryEnumMap = {
  ProductCategory.domestic: 'domestic',
  ProductCategory.commercial: 'commercial',
  ProductCategory.industrial: 'industrial',
  ProductCategory.sparePart: 'spare_part',
  ProductCategory.accessory: 'accessory',
};
