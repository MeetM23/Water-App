/// Availability filter applied to the product list.
enum ProductStatusFilter {
  /// No availability constraint.
  all,

  /// Only products flagged active.
  active,

  /// Only products flagged inactive.
  inactive,

  /// Only active products currently out of stock.
  outOfStock,
}
