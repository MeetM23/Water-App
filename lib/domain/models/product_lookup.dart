import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/product_category.dart';

part 'product_lookup.freezed.dart';
part 'product_lookup.g.dart';

/// Product details and registration state returned by product barcode lookups.
@freezed
class ProductLookup with _$ProductLookup {
  /// Creates a product lookup model.
  const factory ProductLookup({
    required String unitId,
    required String serialNumber,
    required String productId,
    required String productName,
    required ProductCategory category,
    required DateTime manufacturedAt,
    @Default('available') String status,
    String? modelNumber,
    String? productCode,
    @Default(0) int stockQuantity,
    int? defaultWarrantyMonths,
    ProductRegistrationInfo? registration,
  }) = _ProductLookup;

  /// Deserializes a product lookup JSON response from Supabase RPC.
  factory ProductLookup.fromJson(Map<String, dynamic> json) =>
      _$ProductLookupFromJson(json);
}

/// Active warranty registration details for a product.
@freezed
class ProductRegistrationInfo with _$ProductRegistrationInfo {
  /// Creates product registration info.
  const factory ProductRegistrationInfo({
    required String id,
    String? customerName,
    String? customerPhone,
    required DateTime purchaseDate,
    required DateTime installationDate,
    required DateTime warrantyStartDate,
    required int warrantyMonths,
    required DateTime warrantyEndDate,
    String? customerCity,
    String? customerAddress,
    String? invoiceNumber,
    String? sellerName,
    String? sellerPhone,
    String? registeredBy,
    DateTime? createdAt,
  }) = _ProductRegistrationInfo;

  const ProductRegistrationInfo._();

  /// Whether the warranty period has passed.
  bool get isExpired => DateTime.now().isAfter(warrantyEndDate);

  /// Deserializes product registration info from JSON.
  factory ProductRegistrationInfo.fromJson(Map<String, dynamic> json) =>
      _$ProductRegistrationInfoFromJson(json);
}
