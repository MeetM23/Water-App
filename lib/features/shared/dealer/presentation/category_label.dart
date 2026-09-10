import '../../../../domain/enums/product_category.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Localised names for [ProductCategory] on the dealer catalogue.
///
/// Defined once rather than switched over at each call site: the card and the
/// filter sheet must agree on the wording, or a dealer taps a chip labelled one
/// thing and gets cards labelled another.
extension CatalogueCategoryLabel on ProductCategory {
  /// The category name shown to a dealer.
  String catalogueLabel(AppLocalizations l10n) => switch (this) {
    ProductCategory.domestic => l10n.categoryDomestic,
    ProductCategory.commercial => l10n.categoryCommercial,
    ProductCategory.industrial => l10n.categoryIndustrial,
    ProductCategory.sparePart => l10n.categorySparePart,
    ProductCategory.accessory => l10n.categoryAccessory,
  };
}
