// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatalogProductImpl _$$CatalogProductImplFromJson(Map<String, dynamic> json) =>
    _$CatalogProductImpl(
      id: json['id'] as String,
      productCode: json['product_code'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$ProductCategoryEnumMap, json['category']),
      price: (json['price'] as num).toDouble(),
      inStock: json['in_stock'] as bool,
      specifications: json['specifications'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      modelNumber: json['model_number'] as String?,
      description: json['description'] as String?,
      capacity: json['capacity'] as String?,
      warrantyMonths: (json['warranty_months'] as num?)?.toInt(),
      primaryImagePath: json['primary_image_path'] as String?,
    );

Map<String, dynamic> _$$CatalogProductImplToJson(
        _$CatalogProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_code': instance.productCode,
      'name': instance.name,
      'category': _$ProductCategoryEnumMap[instance.category]!,
      'price': instance.price,
      'in_stock': instance.inStock,
      'specifications': instance.specifications,
      'model_number': instance.modelNumber,
      'description': instance.description,
      'capacity': instance.capacity,
      'warranty_months': instance.warrantyMonths,
      'primary_image_path': instance.primaryImagePath,
    };

const _$ProductCategoryEnumMap = {
  ProductCategory.domestic: 'domestic',
  ProductCategory.commercial: 'commercial',
  ProductCategory.industrial: 'industrial',
  ProductCategory.sparePart: 'spare_part',
  ProductCategory.accessory: 'accessory',
};
