import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/product_category.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// A catalogue product exactly as the owner sees it.
///
/// This model carries BOTH prices and is therefore only ever populated from a
/// query the owner made. Wholesalers and retailers never receive this shape:
/// they read catalog_view, which resolves a single entitled price column.
@freezed
class Product with _$Product {
  /// Creates a product.
  const factory Product({
    required String id,
    required String productCode,
    required String name,
    required ProductCategory category,
    required double wholesalePrice,
    required double retailPrice,
    required bool inStock,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(<String, dynamic>{}) Map<String, dynamic> specifications,
    String? modelNumber,
    String? description,
    String? capacity,
    double? mrp,
    int? warrantyMonths,
    String? createdBy,
  }) = _Product;

  const Product._();

  /// Reads a products row.
  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  /// Absolute margin a dealer makes on one unit.
  double get dealerMargin => retailPrice - wholesalePrice;

  /// Margin as a percentage of the retail price, or null when retail is zero.
  double? get dealerMarginPercent =>
      retailPrice <= 0 ? null : (dealerMargin / retailPrice) * 100;
}
