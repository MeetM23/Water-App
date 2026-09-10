import '../../../../core/config/app_config.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/models/business_settings.dart';
import '../../../../domain/models/catalog_product.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// How many specification lines a shared message carries.
///
/// Capped because the message is read on a phone in a conversation: past five
/// lines the recipient scrolls instead of reading, and the price at the top
/// scrolls away with everything else.
const int shareSpecificationLimit = 5;

/// The business details used until the real ones have loaded.
///
/// Sharing must never wait on a settings round trip — a dealer taps share with
/// a customer standing in front of them. The legal name is a constant anyway,
/// so a slow load costs the message only its phone line.
const BusinessSettings fallbackShareBusiness = BusinessSettings(
  businessName: AppConfig.companyName,
);

/// WhatsApp has no list markup, so the bullet is a literal character. A hyphen
/// would read as a minus sign next to the numbers it precedes.
const String _bullet = '\u2022';

/// Builds the message a dealer forwards to their own customer.
///
/// Pure on purpose. This text is the only part of the app a customer ever
/// sees, and it is laid out the way a person writes a message — who it is
/// from, what the product is, what it costs, a few facts, a number to ring —
/// rather than as a dump of every field on the record. Being free of context
/// and providers is what lets that layout be pinned down by a test.
String buildShareMessage({
  required CatalogProduct product,
  required BusinessSettings business,
  required AppLocalizations l10n,
}) {
  final model = product.modelNumber?.trim() ?? '';
  final phone = business.phone.trim();

  final lines = <String>[
    l10n.shareHeading(business.businessName),
    '',
    // WhatsApp renders *text* bold. The name is what the recipient scrolls
    // back up to find later, so it is the one line that gets the emphasis.
    '*${product.name}*',
    if (model.isNotEmpty) model,
    '${l10n.shareCodeLabel}: ${product.productCode}',
    '${l10n.sharePriceLabel}: ${AppFormat.rupees(product.price)}',
  ];

  final specifications = _specificationLines(product: product, l10n: l10n);
  if (specifications.isNotEmpty) {
    lines
      ..add('')
      ..addAll(specifications);
  }

  if (phone.isNotEmpty) {
    lines
      ..add('')
      ..add('${l10n.labelPhone}: $phone');
  }

  return lines.join('\n');
}

/// The message WhatsApp opens with when a dealer enquires about a product.
///
/// Separate from [buildShareMessage] because it travels the other way: this
/// one is addressed to Maruti Water Solution, so it names the product and
/// stops, rather than describing it back to the people who stock it.
String buildEnquiryMessage({
  required CatalogProduct product,
  required AppLocalizations l10n,
}) => l10n.shareEnquiry(product.name, product.productCode);

/// The bullet lines that sit between the price and the phone number.
///
/// Capacity leads because it is the figure a customer actually chooses on, and
/// warranty closes because it is the one that settles the sale.
List<String> _specificationLines({
  required CatalogProduct product,
  required AppLocalizations l10n,
}) {
  final capacity = product.capacity?.trim() ?? '';
  final warrantyMonths = product.warrantyMonths;
  final rows = <MapEntry<String, String>>[
    if (capacity.isNotEmpty)
      MapEntry<String, String>(l10n.fieldCapacity, capacity),
    ...product.specificationRows,
  ];

  return <String>[
    for (final row in rows.take(shareSpecificationLimit))
      '$_bullet ${row.key}: ${row.value}',
    if (warrantyMonths != null)
      '$_bullet ${l10n.productWarranty(warrantyMonths)}',
  ];
}
