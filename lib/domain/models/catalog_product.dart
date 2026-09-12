import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/product_category.dart';

part 'catalog_product.freezed.dart';
part 'catalog_product.g.dart';

/// A product exactly as a dealer sees it.
///
/// This is the shape of `catalog_view`, and it carries ONE price. The view
/// resolves which one from the caller's role inside the database, so there is
/// no second price on this object to leak, no filtering step in Dart that
/// could be bypassed, and no way for a wholesaler build to render a retail
/// figure it never received.
///
/// Contrast with `Product`, which carries both prices and is only ever
/// populated from an owner query.
@freezed
class CatalogProduct with _$CatalogProduct {
  /// Creates a catalogue entry.
  const factory CatalogProduct({
    required String id,
    required String productCode,
    required String name,
    required ProductCategory category,
    required double price,
    required bool inStock,
    @Default(<String, dynamic>{}) Map<String, dynamic> specifications,
    String? modelNumber,
    String? description,
    String? capacity,
    double? mrp,
    int? warrantyMonths,
    String? primaryImagePath,
  }) = _CatalogProduct;

  const CatalogProduct._();

  /// Reads a catalog_view row.
  factory CatalogProduct.fromJson(Map<String, dynamic> json) =>
      _$CatalogProductFromJson(json);

  /// Specification rows in a stable order, ready to render as a table.
  ///
  /// jsonb has no inherent ordering, so this sorts by key: without it the
  /// table reshuffles between loads and the dealer cannot find the row they
  /// were looking at a moment ago.
  List<MapEntry<String, String>> get specificationRows {
    final rows = specifications.entries
        .map((MapEntry<String, dynamic> e) => MapEntry<String, String>(
              e.key,
              '${e.value}',
            ))
        .toList()
      ..sort((MapEntry<String, String> a, MapEntry<String, String> b) =>
          a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    return rows;
  }
}
