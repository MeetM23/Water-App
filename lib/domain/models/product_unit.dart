import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/product_category.dart';

part 'product_unit.freezed.dart';
part 'product_unit.g.dart';

/// An individual physical RO machine instance identified by its unique serial number.
@freezed
class ProductUnit with _$ProductUnit {
  /// Creates a physical product unit.
  const factory ProductUnit({
    required String unitId,
    required String serialNumber,
    required String productId,
    required String productName,
    required ProductCategory category,
    required DateTime manufacturedAt,
    String? modelNumber,
    int? defaultWarrantyMonths,
    UnitRegistrationInfo? registration,
  }) = _ProductUnit;

  /// Deserializes a physical unit JSON response from Supabase RPC.
  factory ProductUnit.fromJson(Map<String, dynamic> json) =>
      _$ProductUnitFromJson(json);
}

/// Active warranty registration details for a physical unit.
@freezed
class UnitRegistrationInfo with _$UnitRegistrationInfo {
  /// Creates unit registration info.
  const factory UnitRegistrationInfo({
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
    String? registeredBy,
    DateTime? createdAt,
  }) = _UnitRegistrationInfo;

  const UnitRegistrationInfo._();

  /// Whether the warranty period has passed.
  bool get isExpired => DateTime.now().isAfter(warrantyEndDate);

  /// Deserializes unit registration info from JSON.
  factory UnitRegistrationInfo.fromJson(Map<String, dynamic> json) =>
      _$UnitRegistrationInfoFromJson(json);
}
