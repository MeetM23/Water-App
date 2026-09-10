/// Ordering options offered above the product list.
enum ProductSort {
  /// Most recently created first.
  newest,

  /// Alphabetical by product name.
  name,

  /// Cheapest retail price first.
  priceAscending,

  /// Most expensive retail price first.
  priceDescending,
}

/// Maps a sort option onto the column and direction the query needs.
extension ProductSortQuery on ProductSort {
  /// Column to order by.
  String get column => switch (this) {
    ProductSort.newest => 'created_at',
    ProductSort.name => 'name',
    ProductSort.priceAscending || ProductSort.priceDescending => 'retail_price',
  };

  /// Whether the order is ascending.
  bool get isAscending => switch (this) {
    ProductSort.newest || ProductSort.priceDescending => false,
    ProductSort.name || ProductSort.priceAscending => true,
  };
}
