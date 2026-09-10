import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/product_category.dart';
import '../enums/product_sort.dart';
import '../enums/product_status_filter.dart';

part 'product_query.freezed.dart';

/// The search, filter, sort and paging state of the product list.
///
/// Held as one value object so the list controller can react to any change
/// with a single equality check, and so page zero is refetched whenever a
/// filter moves rather than appending onto a stale list.
@freezed
class ProductQuery with _$ProductQuery {
  /// Creates a query.
  const factory ProductQuery({
    @Default('') String searchTerm,
    ProductCategory? category,
    @Default(ProductStatusFilter.all) ProductStatusFilter status,
    @Default(ProductSort.newest) ProductSort sort,
    @Default(0) int page,
    @Default(20) int pageSize,
  }) = _ProductQuery;

  const ProductQuery._();

  /// Whether anything narrows the full catalogue.
  bool get hasActiveFilters =>
      searchTerm.trim().isNotEmpty ||
      category != null ||
      status != ProductStatusFilter.all;

  /// First row index of the requested page.
  int get rangeFrom => page * pageSize;

  /// Last row index of the requested page, inclusive.
  int get rangeTo => rangeFrom + pageSize - 1;
}
