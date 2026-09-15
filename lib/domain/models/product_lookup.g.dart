// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_lookup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductLookupImpl _$$ProductLookupImplFromJson(Map<String, dynamic> json) =>
    _$ProductLookupImpl(
      unitId: json['unit_id'] as String,
      serialNumber: json['serial_number'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      category: $enumDecode(_$ProductCategoryEnumMap, json['category']),
      manufacturedAt: DateTime.parse(json['manufactured_at'] as String),
      status: json['status'] as String? ?? 'available',
      modelNumber: json['model_number'] as String?,
      productCode: json['product_code'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      defaultWarrantyMonths: (json['default_warranty_months'] as num?)?.toInt(),
      registration: json['registration'] == null
          ? null
          : ProductRegistrationInfo.fromJson(
              json['registration'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProductLookupImplToJson(_$ProductLookupImpl instance) =>
    <String, dynamic>{
      'unit_id': instance.unitId,
      'serial_number': instance.serialNumber,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'category': _$ProductCategoryEnumMap[instance.category]!,
      'manufactured_at': instance.manufacturedAt.toIso8601String(),
      'status': instance.status,
      'model_number': instance.modelNumber,
      'product_code': instance.productCode,
      'stock_quantity': instance.stockQuantity,
      'default_warranty_months': instance.defaultWarrantyMonths,
      'registration': instance.registration,
    };

const _$ProductCategoryEnumMap = {
  ProductCategory.domestic: 'domestic',
  ProductCategory.commercial: 'commercial',
  ProductCategory.industrial: 'industrial',
  ProductCategory.sparePart: 'spare_part',
  ProductCategory.accessory: 'accessory',
};

_$ProductRegistrationInfoImpl _$$ProductRegistrationInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductRegistrationInfoImpl(
      id: json['id'] as String,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      installationDate: DateTime.parse(json['installation_date'] as String),
      warrantyStartDate: DateTime.parse(json['warranty_start_date'] as String),
      warrantyMonths: (json['warranty_months'] as num).toInt(),
      warrantyEndDate: DateTime.parse(json['warranty_end_date'] as String),
      customerCity: json['customer_city'] as String?,
      customerAddress: json['customer_address'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      sellerName: json['seller_name'] as String?,
      sellerPhone: json['seller_phone'] as String?,
      registeredBy: json['registered_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ProductRegistrationInfoImplToJson(
        _$ProductRegistrationInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'purchase_date': instance.purchaseDate.toIso8601String(),
      'installation_date': instance.installationDate.toIso8601String(),
      'warranty_start_date': instance.warrantyStartDate.toIso8601String(),
      'warranty_months': instance.warrantyMonths,
      'warranty_end_date': instance.warrantyEndDate.toIso8601String(),
      'customer_city': instance.customerCity,
      'customer_address': instance.customerAddress,
      'invoice_number': instance.invoiceNumber,
      'seller_name': instance.sellerName,
      'seller_phone': instance.sellerPhone,
      'registered_by': instance.registeredBy,
      'created_at': instance.createdAt?.toIso8601String(),
    };
