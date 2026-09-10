import 'package:json_annotation/json_annotation.dart';

/// Catalogue division. Determines the prefix inside the product code.
enum ProductCategory {
  /// Household RO purifiers.
  @JsonValue('domestic')
  domestic,

  /// Commercial plants for shops, schools and small hotels.
  @JsonValue('commercial')
  commercial,

  /// Large industrial plants.
  @JsonValue('industrial')
  industrial,

  /// Replacement parts: membranes, pumps, filters.
  @JsonValue('spare_part')
  sparePart,

  /// Accessories sold alongside a system.
  @JsonValue('accessory')
  accessory,
}

/// The three-letter code the database uses when generating a product code.
extension ProductCategoryCode on ProductCategory {
  /// Prefix segment of the product code, matching generate_product_code().
  String get codePrefix => switch (this) {
    ProductCategory.domestic => 'DOM',
    ProductCategory.commercial => 'COM',
    ProductCategory.industrial => 'IND',
    ProductCategory.sparePart => 'SPR',
    ProductCategory.accessory => 'ACC',
  };

  /// Value as stored in the product_category Postgres enum.
  String get wireValue => switch (this) {
    ProductCategory.domestic => 'domestic',
    ProductCategory.commercial => 'commercial',
    ProductCategory.industrial => 'industrial',
    ProductCategory.sparePart => 'spare_part',
    ProductCategory.accessory => 'accessory',
  };
}
